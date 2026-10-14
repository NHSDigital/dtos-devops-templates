#!/bin/bash

################################################################################
# Azure Front Door SSL Certificate Renewal - Process Flow
################################################################################
#
# 1. Receive the Azure subscription, one or more target domains and the
#    certificate expiry threshold as command-line arguments.
#
#    Steps 2-9 are then run independently for each target domain. A failure
#    for one domain does not stop the remaining domains being processed; the
#    script exits non-zero at the end if any domain failed.
#
# 2. Find the Azure Front Door profile containing the requested custom domain.
#
# 3. Read the domain's current Front Door configuration and validation state.
#
# 4. Connect to the target domain over HTTPS and determine the expiry date
#    of the TLS certificate currently being served.
#
# 5. Decide whether certificate renewal/revalidation is required:
#
#      - If forced with -f:
#          Regenerate the Front Door validation token.
#
#      - If Front Door is in PendingRevalidation or InternalError:
#          Regenerate the validation token.
#
#      - If the currently served TLS certificate expires within the configured
#        threshold:
#          Regenerate the Front Door validation token.
#
#      - Otherwise:
#          Make no changes and finish.
#
# 6. When regeneration is required:
#      - Request a new Front Door validation token.
#      - Wait for Front Door to expose the refreshed token.
#      - Retrieve the new token and current validation state.
#
# 7. If DNS validation is required:
#      - Locate the Azure DNS zone for the domain.
#      - Determine the required _dnsauth TXT record.
#      - Check whether the TXT record already exists.
#      - Create the record if it does not exist.
#      - Update it if the existing token differs from the Front Door token.
#      - Leave it unchanged if it already contains the correct token.
#
# 8. If Front Door validation is Pending or PendingRevalidation:
#      - Wait for the validation state to become Approved.
#      - Fail if Front Door enters a terminal error state or the timeout
#        is reached.
#
# 9. Finish after the domain is validated or when no renewal/revalidation
#    was required.
#
# IMPORTANT:
# The renewal decision is based on the expiry of the TLS certificate
# currently served by the domain. The validation-token expiry alone does
# not trigger certificate regeneration.
#
################################################################################


set -euo pipefail

TODAY=$(TZ=Europe/London date -Idate)

################################################################################
# Parse command-line arguments
################################################################################

usage() {
  echo "Usage: $0 -s <subscription> -d <target-domain> [-d <target-domain> ...] -e <expiration-days> [-r <resource-group>]"
  echo
  echo "Required arguments:"
  echo "  -s    Azure subscription name or ID"
  echo "  -d    Target domain. Repeat -d, or pass a comma-separated list, to process multiple domains"
  echo "  -e    TLS certificate expiration threshold in days"
  echo
  echo "Optional arguments:"
  echo "  -f    Force regeneration of TLS certificate (optional)"
  echo "  -r    Resource group filter"
  echo
  echo "Example:"
  echo "  $0 -s my-subscription -d example.nhs.uk -e 30"
  echo "  $0 -s my-subscription -d example.nhs.uk -e 30 -f"
  echo "  $0 -s my-subscription -d example.nhs.uk -d www.example.nhs.uk -e 30"
  echo "  $0 -s my-subscription -d example.nhs.uk,www.example.nhs.uk -e 30"
  exit 1
}

AZ_SUBSCRIPTION_SCOPE=""
TARGET_DOMAINS=()
AFD_DOMAIN_EXPIRATION_DAYS=""
RESOURCE_GROUP_FILTER=""
FORCE_REGENERATION=false

while getopts ":s:d:e:fr:h" opt; do
  case "$opt" in
    s)
      AZ_SUBSCRIPTION_SCOPE="$OPTARG"
      ;;
    d)
      IFS=',' read -r -a DOMAIN_ARGS <<< "$OPTARG"
      for DOMAIN_ARG in "${DOMAIN_ARGS[@]}"; do
        DOMAIN_ARG="${DOMAIN_ARG//[[:space:]]/}"
        if [[ -n "$DOMAIN_ARG" ]]; then
          TARGET_DOMAINS+=("$DOMAIN_ARG")
        fi
      done
      ;;
    e)
      AFD_DOMAIN_EXPIRATION_DAYS="$OPTARG"
      ;;
    f)
      FORCE_REGENERATION=true
      ;;
    r)
      RESOURCE_GROUP_FILTER="$OPTARG"
      ;;
    h)
      usage
      ;;
    :)
      echo "ERROR: Option -$OPTARG requires an argument." >&2
      usage
      ;;
    \?)
      echo "ERROR: Invalid option: -$OPTARG" >&2
      usage
      ;;
    *)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

################################################################################
# Validate configuration
################################################################################

if [[ -z "$AZ_SUBSCRIPTION_SCOPE" ]]; then
  echo "ERROR: Azure subscription is required. Use -s <subscription>." >&2
  usage
fi

if [[ "${#TARGET_DOMAINS[@]}" -eq 0 ]]; then
  echo "ERROR: Target domain is required. Use -d <domain>." >&2
  usage
fi

if [[ -z "$AFD_DOMAIN_EXPIRATION_DAYS" ]]; then
  echo "ERROR: Expiration days is required. Use -e <days>." >&2
  usage
fi

if ! [[ "$AFD_DOMAIN_EXPIRATION_DAYS" =~ ^[0-9]+$ ]]; then
  echo "ERROR: Expiration days must be a positive integer." >&2
  echo "Value supplied: $AFD_DOMAIN_EXPIRATION_DAYS" >&2
  exit 1
fi

echo "TLS certificate expiration threshold: $AFD_DOMAIN_EXPIRATION_DAYS days"
echo "Target domain(s): ${TARGET_DOMAINS[*]}"
echo "Azure subscription: $AZ_SUBSCRIPTION_SCOPE"

if [[ -n "$RESOURCE_GROUP_FILTER" ]]; then
  echo "Resource group filter: $RESOURCE_GROUP_FILTER"
fi

echo

################################################################################
# Find Azure Front Door profiles
################################################################################

echo "Looking for Azure Front Door CDNs..."

AFD_LIST=$(
  az afd profile list \
    --only-show-errors \
    --subscription "$AZ_SUBSCRIPTION_SCOPE" |
  jq -rc '.[] | {
    "name": .name,
    "resourceGroup": .resourceGroup
  }'
)

if [[ -z "$AFD_LIST" ]]; then
  echo "ERROR: No Azure Front Door (Standard/Premium) profiles found in subscription $AZ_SUBSCRIPTION_SCOPE" >&2
  exit 1
fi

AFD_COUNT=$(echo "$AFD_LIST" | wc -l | tr -d ' ')

echo "Found $AFD_COUNT Azure Front Door(s) total:"
echo "$AFD_LIST" | jq -r '"  - \(.name) (Resource Group: \(.resourceGroup))"'
echo

if [[ -n "$RESOURCE_GROUP_FILTER" ]]; then
  echo "Filtering for resource group: $RESOURCE_GROUP_FILTER"
  echo
fi

################################################################################
# Process a single domain
#
# Runs the full renewal/revalidation flow for the domain passed as $1.
# Called in a subshell per domain, so any "exit" only ends that domain's run.
################################################################################

process_domain() {

  local target_domain="$1"

  # Declared separately from assignment so "local" doesn't mask the exit status
  # of command substitutions (checked via $? and "if !" below).
  local azure_front_door afd_name all_custom_domains matching_domain \
    target_afd target_resource_group resource_group \
    domain domain_name resource_id state provisioning_state certificate_type \
    domain_validation_expiry domain_token \
    domain_dns_zone domain_dns_zone_id domain_dns_zone_name domain_dns_zone_rg \
    ssl_timeout_seconds cert_end_date cert_expiry_seconds today_seconds \
    cert_days_until_expiry cert_expiration_threshold_seconds should_regenerate \
    regenerate_result wait_for_pending_seconds wait_for_approved_seconds \
    wait_interval_seconds waited_seconds \
    record_set_name_tmp record_set_name dns_result dns_exit_code record_exists \
    record_set_state record_set_current_token dns_update_result \
    current_domain current_state current_provisioning_state

  ################################################################################
  # Find the Azure Front Door containing target_domain
  ################################################################################

  target_afd=""
  target_resource_group=""
  matching_domain=""

  while IFS= read -r azure_front_door; do

    [[ -z "$azure_front_door" ]] && continue

    resource_group=$(echo "$azure_front_door" | jq -rc '.resourceGroup')
    afd_name=$(echo "$azure_front_door" | jq -rc '.name')

    # Skip if resource group filter is set and doesn't match.
    if [[ -n "$RESOURCE_GROUP_FILTER" ]] && [[ "$resource_group" != "$RESOURCE_GROUP_FILTER" ]]; then
      continue
    fi

    echo "Checking Front Door $afd_name in Resource Group $resource_group..."

    all_custom_domains=$(
      az afd custom-domain list \
        --profile-name "$afd_name" \
        --output json \
        --only-show-errors \
        --subscription "$AZ_SUBSCRIPTION_SCOPE" \
        --resource-group "$resource_group"
    )

    matching_domain=$(
      echo "$all_custom_domains" |
      jq -c --arg TARGET_DOMAIN "$target_domain" '
        .[] |
        select(.hostName == $TARGET_DOMAIN) |
        {
          "domain": .hostName,
          "id": .id,
          "validationProperties": .validationProperties,
          "state": .domainValidationState,
          "provisioningState": .provisioningState,
          "certificateType": .tlsSettings.certificateType,
          "azureDnsZone": .azureDnsZone
        }
      '
    )

    if [[ -n "$matching_domain" ]]; then

      target_afd="$afd_name"
      target_resource_group="$resource_group"

      break

    fi

  done <<< "$AFD_LIST"

  ################################################################################
  # Make sure target domain was found
  ################################################################################

  if [[ -z "$matching_domain" ]]; then

    echo
    echo "ERROR: Target domain was not found:"  >&2
    echo "       $target_domain"
    echo
    echo "Make sure the domain exists in the selected subscription."
    exit 1

  fi

  ################################################################################
  # Extract domain properties
  ################################################################################

  domain="$matching_domain"

  domain_name=$(echo "$domain" | jq -rc '.domain')
  resource_id=$(echo "$domain" | jq -rc '.id')
  state=$(echo "$domain" | jq -rc '.state')
  provisioning_state=$(echo "$domain" | jq -rc '.provisioningState')
  certificate_type=$(echo "$domain" | jq -rc '.certificateType')

  domain_validation_expiry=$(
    echo "$domain" |
    jq -rc '.validationProperties.expirationDate'
  )

  domain_token=$(
    echo "$domain" |
    jq -rc '.validationProperties.validationToken'
  )

  domain_dns_zone_id=$(
    echo "$domain" |
    jq -rc '.azureDnsZone.id'
  )

  echo
  echo "============================================================"
  echo "Processing ONLY the requested domain"
  echo "============================================================"
  echo "Front Door:        $target_afd"
  echo "Resource Group:    $target_resource_group"
  echo "Domain:            $domain_name"
  echo "Certificate Type:  $certificate_type"
  echo "Resource ID:       $resource_id"
  echo "Provisioning state: $provisioning_state"
  echo "Validation state:   $state"
  echo "============================================================"
  echo

  ################################################################################
  # Get currently served TLS certificate expiry
  ################################################################################

  echo "Checking currently served TLS certificate..."

  ssl_timeout_seconds=60

  cert_end_date=$(
    echo | timeout "${ssl_timeout_seconds}s" openssl s_client \
      -connect "${domain_name}:443" \
      -servername "${domain_name}" \
      2>/dev/null |
    openssl x509 -noout -enddate |
    cut -d= -f2
  )

  if [[ $? -eq 124 ]]; then
      echo "ERROR: Timed out after ${ssl_timeout_seconds}s while retrieving TLS certificate."  >&2
      exit 1
  fi

  if [[ -z "$cert_end_date" ]]; then
    echo "ERROR: Unable to determine TLS certificate expiry." >&2
    exit 1
  fi

  cert_expiry_seconds=$(date -d "$cert_end_date" +%s)
  today_seconds=$(date -d "$TODAY" +%s)

  cert_days_until_expiry=$(( (cert_expiry_seconds - today_seconds) / 86400 ))

  echo "TLS certificate expires on: $cert_end_date"
  echo "TLS certificate expires in approximately: $cert_days_until_expiry days"
  echo

  ################################################################################
  # Decide whether validation token regeneration is required
  ################################################################################

  should_regenerate=false

  cert_expiration_threshold_seconds=$(( AFD_DOMAIN_EXPIRATION_DAYS * 86400 ))

  if [[ "$FORCE_REGENERATION" == "true" ]]; then

    should_regenerate=true

    echo "FORCE regeneration enabled."
    echo "Validation token will be regenerated regardless of certificate expiry or validation state."

  elif [[ "$state" == "PendingRevalidation" || "$state" == "InternalError" ]]; then

    should_regenerate=true

    echo "Front Door validation state is $state."
    echo "Validation token regeneration is required."

  elif [[ "$cert_expiry_seconds" -le "$((today_seconds + cert_expiration_threshold_seconds))" ]]; then

    should_regenerate=true

    echo "TLS certificate expires within $AFD_DOMAIN_EXPIRATION_DAYS days."
    echo "Certificate renewal/revalidation is required."

  else

    should_regenerate=false

    echo "TLS certificate has more than $AFD_DOMAIN_EXPIRATION_DAYS days remaining."
    echo "No certificate renewal/revalidation required."

  fi

  # Force regeneration for testing. This bypasses the normal expiry threshold,
  # but deliberately does not submit another request while Front Door is already
  # refreshing/submitting a previous regeneration request.
  if [[ "$FORCE_REGENERATION" == "true" ]]; then
    if [[ "$state" == "RefreshingValidationToken" || "$state" == "Submitting" ]]; then
      should_regenerate=false
      echo "Force regeneration requested, but Front Door is already processing a validation token regeneration."
      echo "No additional regeneration request will be submitted."
    else
      should_regenerate=true
      echo "FORCE regeneration enabled - ignoring validation token expiry threshold."
      echo "Attempting asynchronous validation token regeneration."
    fi
  fi

  ################################################################################
  # Regenerate token and continue through DNS validation in the same run
  ################################################################################

  if [[ "$should_regenerate" == "true" ]]; then

    echo
    echo "Submitting validation token regeneration..."
    echo "Waiting for Front Door to complete regeneration."

    if ! regenerate_result=$(
      az afd custom-domain regenerate-validation-token \
        --ids "$resource_id" \
        --only-show-errors \
        2>&1
    ); then

      echo
      echo "ERROR: Failed to regenerate validation token" >&2
      echo "$regenerate_result"
      echo

      if echo "$regenerate_result" | grep -Eqi "Rate limit exceeded|Too Many Requests|TooManyRequests|429"; then
        echo "WARNING: Azure Front Door rate limit reached."
      fi

      exit 1
    fi

    echo
    echo "Validation token regeneration operation completed."

    ################################################################################
    # Re-read Front Door until the refreshed token is available
    ################################################################################

    wait_for_pending_seconds=2700
    wait_interval_seconds=60
    waited_seconds=0

    echo "Waiting for Front Door to expose the refreshed validation token..."

    while true; do

      domain=$(
        az afd custom-domain show \
          --ids "$resource_id" \
          --output json \
          --only-show-errors
      )

      state=$(echo "$domain" | jq -rc '.domainValidationState')
      provisioning_state=$(echo "$domain" | jq -rc '.provisioningState')
      domain_token=$(echo "$domain" | jq -rc '.validationProperties.validationToken')

      echo "Current validation state: $state"
      echo "Current provisioning state: $provisioning_state"

      if [[ "$state" == "Pending" && -n "$domain_token" && "$domain_token" != "null" ]]; then
        echo "New validation token is available."
        break
      fi

      if [[ "$state" == "Approved" && -n "$domain_token" && "$domain_token" != "null" ]]; then
        echo "Front Door is already Approved after regeneration."
        break
      fi

      if [[ "$state" == "Rejected" || "$state" == "InternalError" || "$state" == "TimedOut" ]]; then
        echo "ERROR: Front Door entered terminal validation state: $state" >&2
        exit 1
      fi

      if [[ "$waited_seconds" -ge "$wait_for_pending_seconds" ]]; then
        echo "ERROR: Timed out waiting for the refreshed validation token." >&2
        exit 1
      fi

      sleep "$wait_interval_seconds"
      waited_seconds=$((waited_seconds + wait_interval_seconds))

    done

    # Refresh values used by the DNS validation section.
    domain_name=$(echo "$domain" | jq -rc '.hostName')
    state=$(echo "$domain" | jq -rc '.domainValidationState')
    provisioning_state=$(echo "$domain" | jq -rc '.provisioningState')
    domain_validation_expiry=$(echo "$domain" | jq -rc '.validationProperties.expirationDate')
    domain_token=$(echo "$domain" | jq -rc '.validationProperties.validationToken')
    domain_dns_zone_id=$(echo "$domain" | jq -rc '.azureDnsZone.id')

    echo "Validation state after regeneration: $state"
    echo "Retrieved current validation token for DNS validation."
    echo

  fi

  ################################################################################
  # Process DNS validation for Pending domains
  ################################################################################

  if [[ "$state" == "Pending" || "$state" == "TimedOut" || "$state" == "PendingRevalidation" || "$state" == "InternalError" ]]; then

    echo
    echo "Processing DNS validation for $domain_name..."

    ##############################################################################
    # Locate DNS zone
    ##############################################################################

    domain_dns_zone=$(
      az network dns zone show \
        --ids "$domain_dns_zone_id" \
        --output json \
        --only-show-errors |
      jq -rc '{
        "name": .name,
        "etag": .etag,
        "resourceGroup": .resourceGroup
      }'
    )

    domain_dns_zone_name=$(
      echo "$domain_dns_zone" |
      jq -rc '.name'
    )

    domain_dns_zone_rg=$(
      echo "$domain_dns_zone" |
      jq -rc '.resourceGroup'
    )

    echo "DNS zone: $domain_dns_zone_name"
    echo "DNS resource group: $domain_dns_zone_rg"

    ##############################################################################
    # Build DNS TXT record name
    ##############################################################################

    record_set_name_tmp=${domain_name//${domain_dns_zone_name}/}

    record_set_name_tmp="_dnsauth.${record_set_name_tmp}"

    record_set_name=${record_set_name_tmp/%./}

    echo "DNS TXT record: $record_set_name"

    ##############################################################################
    # Check whether DNS TXT record exists
    ##############################################################################

    echo
    echo "Checking DNS Record for validation token..."

    dns_result=$(
      az network dns record-set txt show \
        --zone-name "$domain_dns_zone_name" \
        --name "$record_set_name" \
        --output json \
        --subscription "$AZ_SUBSCRIPTION_SCOPE" \
        --resource-group "$domain_dns_zone_rg" \
        --only-show-errors \
        2>&1
    )

    dns_exit_code=$?

    if [[ "$dns_exit_code" -eq 0 ]]; then

      record_exists="$dns_result"

    else

      if echo "$dns_result" | grep -qi "ResourceNotFound\|could not be found\|was not found"; then
        record_exists=""
      else
        echo "ERROR checking DNS TXT record:"  >&2
        echo "$dns_result"

        exit "$dns_exit_code"
      fi
    fi

    ##############################################################################
    # Create DNS record if it doesn't exist
    ##############################################################################

    if [[ -z "$record_exists" ]]; then

      echo
      echo "DNS TXT Record does not exist."
      echo "Creating new record..."
      echo "+ New value: $domain_token"

      record_set_state=$(
        az network dns record-set txt create \
          --zone-name "$domain_dns_zone_name" \
          --name "$record_set_name" \
          --value "$domain_token" \
          --output json \
          --subscription "$AZ_SUBSCRIPTION_SCOPE" \
          --resource-group "$domain_dns_zone_rg" |
        jq -rc '.provisioningState'
      )

      echo
      echo "DNS Record creation: $record_set_state"

    else

      ############################################################################
      # Record exists - compare tokens
      ############################################################################

      record_set_current_token=$(
        echo "$record_exists" |
        jq -rc '.TXTRecords[0].value[0]'
      )

      echo
      echo "Old DNS token: $record_set_current_token"
      echo "New Front Door token: $domain_token"

      ############################################################################
      # Update DNS record if token has changed
      ############################################################################

      if [[ "$record_set_current_token" != "$domain_token" ]]; then

        echo
        echo "DNS TXT Record needs updating."
        echo "Updating DNS TXT Record..."

        dns_update_result=$(
          az network dns record-set txt update \
            --zone-name "$domain_dns_zone_name" \
            --name "$record_set_name" \
            --set "txtRecords[0].value[0]=$domain_token" \
            --output json \
            --subscription "$AZ_SUBSCRIPTION_SCOPE" \
            --resource-group "$domain_dns_zone_rg" \
            --only-show-errors \
            2>&1
        )

        dns_exit_code=$?

        if [[ "$dns_exit_code" -ne 0 ]]; then

          echo
          echo "ERROR: DNS Record update failed"  >&2
          echo "$dns_update_result"

          exit "$dns_exit_code"

        fi

        record_set_state=$(
          echo "$dns_update_result" |
          jq -r '.provisioningState'
        )

        echo
        echo "DNS Record update: $record_set_state"

      else

        echo
        echo "DNS Record already contains the correct validation token."
        echo "Nothing to update."

      fi

    fi

  else

    echo
    echo "Domain validation state is $state."
    echo "No DNS update required."

  fi

  ################################################################################
  # Wait for Front Door validation to become Approved
  ################################################################################

  if [[ "$state" == "Pending" || "$state" == "PendingRevalidation" ]]; then

    wait_for_approved_seconds=2700
    wait_interval_seconds=60
    waited_seconds=0

    echo
    echo "Waiting for Azure Front Door validation state to become Approved..."

    while true; do

      current_domain=$(
        az afd custom-domain show \
          --ids "$resource_id" \
          --output json \
          --only-show-errors
      )

      current_state=$(echo "$current_domain" | jq -rc '.domainValidationState')
      current_provisioning_state=$(echo "$current_domain" | jq -rc '.provisioningState')

      echo "Current validation state: $current_state"
      echo "Current provisioning state: $current_provisioning_state"

      if [[ "$current_state" == "Approved" ]]; then
        echo
        echo "SUCCESS: Azure Front Door validation state is Approved."
        break
      fi

      if [[ "$current_state" == "Rejected" || "$current_state" == "InternalError" || "$current_state" == "TimedOut" ]]; then
        echo
        echo "ERROR: Azure Front Door validation entered terminal state: $current_state" >&2
        exit 1
      fi

      if [[ "$waited_seconds" -ge "$wait_for_approved_seconds" ]]; then
        echo
        echo "ERROR: Front Door did not reach Approved within $wait_for_approved_seconds seconds." >&2
        echo "The DNS record may be correct but Front Door may still be waiting for DNS visibility/TTL expiry." >&2
        exit 1
      fi

      sleep "$wait_interval_seconds"
      waited_seconds=$((waited_seconds + wait_interval_seconds))

    done

  fi

  echo
  echo "============================================================"
  echo "Finished processing $target_domain"
  echo "============================================================"

}

################################################################################
# Process each requested domain
################################################################################

FAILED_DOMAINS=()
SUCCEEDED_DOMAINS=()

for CURRENT_TARGET_DOMAIN in "${TARGET_DOMAINS[@]}"; do

  echo
  echo "############################################################"
  echo "# Domain: $CURRENT_TARGET_DOMAIN"
  echo "############################################################"
  echo

  # Run in a subshell with errexit enabled so a failure for one domain does not
  # stop the remaining domains from being processed.
  set +e
  ( set -e; process_domain "$CURRENT_TARGET_DOMAIN" )
  DOMAIN_EXIT_CODE=$?
  set -e

  if [[ "$DOMAIN_EXIT_CODE" -eq 0 ]]; then
    SUCCEEDED_DOMAINS+=("$CURRENT_TARGET_DOMAIN")
  else
    echo "ERROR: Processing failed for $CURRENT_TARGET_DOMAIN (exit code $DOMAIN_EXIT_CODE)" >&2
    FAILED_DOMAINS+=("$CURRENT_TARGET_DOMAIN")
  fi

done

################################################################################
# Finished
################################################################################

echo
echo "============================================================"
echo "Summary"
echo "============================================================"
echo "Succeeded: ${#SUCCEEDED_DOMAINS[@]}"
for d in "${SUCCEEDED_DOMAINS[@]+"${SUCCEEDED_DOMAINS[@]}"}"; do
  echo "  - $d"
done
echo "Failed:    ${#FAILED_DOMAINS[@]}"
for d in "${FAILED_DOMAINS[@]+"${FAILED_DOMAINS[@]}"}"; do
  echo "  - $d"
done
echo "============================================================"

if [[ "${#FAILED_DOMAINS[@]}" -gt 0 ]]; then
  exit 1
fi
