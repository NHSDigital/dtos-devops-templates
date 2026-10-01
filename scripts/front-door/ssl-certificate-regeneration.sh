#!/bin/bash

################################################################################
# Azure Front Door SSL Certificate Renewal - Process Flow
################################################################################
#
# 1. Receive the Azure subscription, target domain and certificate expiry
#    threshold as command-line arguments.
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
  echo "Usage: $0 -s <subscription> -d <target-domain> -e <expiration-days> [-r <resource-group>]"
  echo
  echo "Required arguments:"
  echo "  -s    Azure subscription name or ID"
  echo "  -d    Target domain"
  echo "  -e    TLS certificate expiration threshold in days"
  echo
  echo "Optional arguments:"
  echo "  -f    Force regeneration of TLS certificate (optional)"
  echo "  -r    Resource group filter"
  echo
  echo "Example:"
  echo "  $0 -s my-subscription -d example.nhs.uk -e 30"
  echo "  $0 -s my-subscription -d example.nhs.uk -e 30 -f"
  exit 1
}

AZ_SUBSCRIPTION_SCOPE=""
TARGET_DOMAIN=""
AFD_DOMAIN_EXPIRATION_DAYS=""
RESOURCE_GROUP_FILTER=""
FORCE_REGENERATION=false

while getopts ":s:d:e:fr:h" opt; do
  case "$opt" in
    s)
      AZ_SUBSCRIPTION_SCOPE="$OPTARG"
      ;;
    d)
      TARGET_DOMAIN="$OPTARG"
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
  esac
done

################################################################################
# Validate configuration
################################################################################

if [[ -z "$AZ_SUBSCRIPTION_SCOPE" ]]; then
  echo "ERROR: Azure subscription is required. Use -s <subscription>." >&2
  usage
fi

if [[ -z "$TARGET_DOMAIN" ]]; then
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
echo "Target domain: $TARGET_DOMAIN"
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

AFD_COUNT=$(echo "$AFD_LIST" | wc -l | tr -d ' ')

echo "Found $AFD_COUNT Azure Front Door(s) total"
echo

if [[ -n "$RESOURCE_GROUP_FILTER" ]]; then
  echo "Filtering for resource group: $RESOURCE_GROUP_FILTER"
  echo
fi

################################################################################
# Find the Azure Front Door containing TARGET_DOMAIN
################################################################################

TARGET_AFD=""
TARGET_RESOURCE_GROUP=""
MATCHING_DOMAIN=""

for AZURE_FRONT_DOOR in $AFD_LIST; do

  RESOURCE_GROUP=$(echo "$AZURE_FRONT_DOOR" | jq -rc '.resourceGroup')
  AFD_NAME=$(echo "$AZURE_FRONT_DOOR" | jq -rc '.name')

  # Skip if resource group filter is set and doesn't match.
  if [[ -n "$RESOURCE_GROUP_FILTER" ]] && [[ "$RESOURCE_GROUP" != "$RESOURCE_GROUP_FILTER" ]]; then
    continue
  fi

  echo "Checking Front Door $AFD_NAME in Resource Group $RESOURCE_GROUP..."

  ALL_CUSTOM_DOMAINS=$(
    az afd custom-domain list \
      --profile-name "$AFD_NAME" \
      --output json \
      --only-show-errors \
      --subscription "$AZ_SUBSCRIPTION_SCOPE" \
      --resource-group "$RESOURCE_GROUP"
  )

  MATCHING_DOMAIN=$(
    echo "$ALL_CUSTOM_DOMAINS" |
    jq -c --arg TARGET_DOMAIN "$TARGET_DOMAIN" '
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

  if [[ -n "$MATCHING_DOMAIN" ]]; then

    TARGET_AFD="$AFD_NAME"
    TARGET_RESOURCE_GROUP="$RESOURCE_GROUP"

    break

  fi

done

################################################################################
# Make sure target domain was found
################################################################################

if [[ -z "$MATCHING_DOMAIN" ]]; then

  echo
  echo "ERROR: Target domain was not found:"  >&2
  echo "       $TARGET_DOMAIN"
  echo
  echo "Make sure the domain exists in the selected subscription."
  exit 1

fi

################################################################################
# Extract domain properties
################################################################################

DOMAIN="$MATCHING_DOMAIN"

DOMAIN_NAME=$(echo "$DOMAIN" | jq -rc '.domain')
RESOURCE_ID=$(echo "$DOMAIN" | jq -rc '.id')
STATE=$(echo "$DOMAIN" | jq -rc '.state')
PROVISIONING_STATE=$(echo "$DOMAIN" | jq -rc '.provisioningState')
CERTIFICATE_TYPE=$(echo "$DOMAIN" | jq -rc '.certificateType')

DOMAIN_VALIDATION_EXPIRY=$(
  echo "$DOMAIN" |
  jq -rc '.validationProperties.expirationDate'
)

DOMAIN_TOKEN=$(
  echo "$DOMAIN" |
  jq -rc '.validationProperties.validationToken'
)

DOMAIN_DNS_ZONE_ID=$(
  echo "$DOMAIN" |
  jq -rc '.azureDnsZone.id'
)

echo
echo "============================================================"
echo "Processing ONLY the requested domain"
echo "============================================================"
echo "Front Door:        $TARGET_AFD"
echo "Resource Group:    $TARGET_RESOURCE_GROUP"
echo "Domain:            $DOMAIN_NAME"
echo "Certificate Type:  $CERTIFICATE_TYPE"
echo "Resource ID:       $RESOURCE_ID"
echo "Provisioning state: $PROVISIONING_STATE"
echo "Validation state:   $STATE"
echo "============================================================"
echo

################################################################################
# Get currently served TLS certificate expiry
################################################################################

echo "Checking currently served TLS certificate..."

CERT_END_DATE=$(
  echo | openssl s_client \
    -connect "${DOMAIN_NAME}:443" \
    -servername "${DOMAIN_NAME}" \
    2>/dev/null |
  openssl x509 -noout -enddate |
  cut -d= -f2
)

if [[ -z "$CERT_END_DATE" ]]; then
  echo "ERROR: Unable to determine TLS certificate expiry." >&2
  exit 1
fi

CERT_EXPIRY_SECONDS=$(date -d "$CERT_END_DATE" +%s)
TODAY_SECONDS=$(date -d "$TODAY" +%s)

CERT_DAYS_UNTIL_EXPIRY=$(( (CERT_EXPIRY_SECONDS - TODAY_SECONDS) / 86400 ))

echo "TLS certificate expires on: $CERT_END_DATE"
echo "TLS certificate expires in approximately: $CERT_DAYS_UNTIL_EXPIRY days"
echo

################################################################################
# Decide whether validation token regeneration is required
################################################################################

SHOULD_REGENERATE=false

CERT_EXPIRATION_THRESHOLD_SECONDS=$(( AFD_DOMAIN_EXPIRATION_DAYS * 86400 ))

if [[ "$FORCE_REGENERATION" == "true" ]]; then

  SHOULD_REGENERATE=true

  echo "FORCE regeneration enabled."
  echo "Validation token will be regenerated regardless of certificate expiry or validation state."

elif [[ "$STATE" == "PendingRevalidation" || "$STATE" == "InternalError" ]]; then

  SHOULD_REGENERATE=true

  echo "Front Door validation state is $STATE."
  echo "Validation token regeneration is required."

elif [[ "$CERT_EXPIRY_SECONDS" -le "$((TODAY_SECONDS + CERT_EXPIRATION_THRESHOLD_SECONDS))" ]]; then

  SHOULD_REGENERATE=true

  echo "TLS certificate expires within $AFD_DOMAIN_EXPIRATION_DAYS days."
  echo "Certificate renewal/revalidation is required."

else

  SHOULD_REGENERATE=false

  echo "TLS certificate has more than $AFD_DOMAIN_EXPIRATION_DAYS days remaining."
  echo "No certificate renewal/revalidation required."

fi

# Force regeneration for testing. This bypasses the normal expiry threshold,
# but deliberately does not submit another request while Front Door is already
# refreshing/submitting a previous regeneration request.
if [[ "$FORCE_REGENERATION" == "true" ]]; then
  if [[ "$STATE" == "RefreshingValidationToken" || "$STATE" == "Submitting" ]]; then
    SHOULD_REGENERATE=false
    echo "Force regeneration requested, but Front Door is already processing a validation token regeneration."
    echo "No additional regeneration request will be submitted."
  else
    SHOULD_REGENERATE=true
    echo "FORCE regeneration enabled - ignoring validation token expiry threshold."
    echo "Attempting asynchronous validation token regeneration."
  fi
fi

################################################################################
# Regenerate token and continue through DNS validation in the same run
################################################################################

if [[ "$SHOULD_REGENERATE" == "true" ]]; then

  echo
  echo "Submitting validation token regeneration..."
  echo "Waiting for Front Door to complete regeneration."

  if ! REGENERATE_RESULT=$(
    az afd custom-domain regenerate-validation-token \
      --ids "$RESOURCE_ID" \
      --only-show-errors \
      2>&1
  ); then

    echo
    echo "ERROR: Failed to regenerate validation token" >&2
    echo "$REGENERATE_RESULT"
    echo

    if echo "$REGENERATE_RESULT" | grep -Eqi "Rate limit exceeded|Too Many Requests|TooManyRequests|429"; then
      echo "WARNING: Azure Front Door rate limit reached."
    fi

    exit 1
  fi

  echo
  echo "Validation token regeneration operation completed."

  ################################################################################
  # Re-read Front Door until the refreshed token is available
  ################################################################################

  WAIT_FOR_PENDING_SECONDS=900
  WAIT_INTERVAL_SECONDS=15
  WAITED_SECONDS=0

  echo "Waiting for Front Door to expose the refreshed validation token..."

  while true; do

    DOMAIN=$(
      az afd custom-domain show \
        --ids "$RESOURCE_ID" \
        --output json \
        --only-show-errors
    )

    STATE=$(echo "$DOMAIN" | jq -rc '.domainValidationState')
    PROVISIONING_STATE=$(echo "$DOMAIN" | jq -rc '.provisioningState')
    DOMAIN_TOKEN=$(echo "$DOMAIN" | jq -rc '.validationProperties.validationToken')

    echo "Current validation state: $STATE"
    echo "Current provisioning state: $PROVISIONING_STATE"

    if [[ "$STATE" == "Pending" && -n "$DOMAIN_TOKEN" && "$DOMAIN_TOKEN" != "null" ]]; then
      echo "New validation token is available."
      break
    fi

    if [[ "$STATE" == "Approved" && -n "$DOMAIN_TOKEN" && "$DOMAIN_TOKEN" != "null" ]]; then
      echo "Front Door is already Approved after regeneration."
      break
    fi

    if [[ "$STATE" == "Rejected" || "$STATE" == "InternalError" || "$STATE" == "TimedOut" ]]; then
      echo "ERROR: Front Door entered terminal validation state: $STATE" >&2
      exit 1
    fi

    if [[ "$WAITED_SECONDS" -ge "$WAIT_FOR_PENDING_SECONDS" ]]; then
      echo "ERROR: Timed out waiting for the refreshed validation token." >&2
      exit 1
    fi

    sleep "$WAIT_INTERVAL_SECONDS"
    WAITED_SECONDS=$((WAITED_SECONDS + WAIT_INTERVAL_SECONDS))

  done

  # Refresh values used by the DNS validation section.
  DOMAIN_NAME=$(echo "$DOMAIN" | jq -rc '.hostName')
  STATE=$(echo "$DOMAIN" | jq -rc '.domainValidationState')
  PROVISIONING_STATE=$(echo "$DOMAIN" | jq -rc '.provisioningState')
  DOMAIN_VALIDATION_EXPIRY=$(echo "$DOMAIN" | jq -rc '.validationProperties.expirationDate')
  DOMAIN_TOKEN=$(echo "$DOMAIN" | jq -rc '.validationProperties.validationToken')
  DOMAIN_DNS_ZONE_ID=$(echo "$DOMAIN" | jq -rc '.azureDnsZone.id')

  echo "Validation state after regeneration: $STATE"
  echo "Retrieved current validation token for DNS validation."
  echo

fi

################################################################################
# Process DNS validation for Pending domains
################################################################################

if [[ "$STATE" == "Pending" || "$STATE" == "PendingRevalidation" || "$STATE" == "InternalError" ]]; then

  echo
  echo "Processing DNS validation for $DOMAIN_NAME..."

  ##############################################################################
  # Locate DNS zone
  ##############################################################################

  DOMAIN_DNS_ZONE=$(
    az network dns zone show \
      --ids "$DOMAIN_DNS_ZONE_ID" \
      --output json \
      --only-show-errors |
    jq -rc '{
      "name": .name,
      "etag": .etag,
      "resourceGroup": .resourceGroup
    }'
  )

  DOMAIN_DNS_ZONE_NAME=$(
    echo "$DOMAIN_DNS_ZONE" |
    jq -rc '.name'
  )

  DOMAIN_DNS_ZONE_RG=$(
    echo "$DOMAIN_DNS_ZONE" |
    jq -rc '.resourceGroup'
  )

  echo "DNS zone: $DOMAIN_DNS_ZONE_NAME"
  echo "DNS resource group: $DOMAIN_DNS_ZONE_RG"

  ##############################################################################
  # Build DNS TXT record name
  ##############################################################################

  RECORD_SET_NAME_TMP=${DOMAIN_NAME//${DOMAIN_DNS_ZONE_NAME}/}

  RECORD_SET_NAME_TMP="_dnsauth.${RECORD_SET_NAME_TMP}"

  RECORD_SET_NAME=${RECORD_SET_NAME_TMP/%./}

  echo "DNS TXT record: $RECORD_SET_NAME"

  ##############################################################################
  # Check whether DNS TXT record exists
  ##############################################################################

  echo
  echo "Checking DNS Record for validation token..."

  DNS_RESULT=$(
    az network dns record-set txt show \
      --zone-name "$DOMAIN_DNS_ZONE_NAME" \
      --name "$RECORD_SET_NAME" \
      --output json \
      --subscription "$AZ_SUBSCRIPTION_SCOPE" \
      --resource-group "$DOMAIN_DNS_ZONE_RG" \
      --only-show-errors \
      2>&1
  )

  DNS_EXIT_CODE=$?

  if [[ "$DNS_EXIT_CODE" -eq 0 ]]; then

    RECORD_EXISTS="$DNS_RESULT"

  else

    if echo "$DNS_RESULT" | grep -qi "ResourceNotFound\|could not be found\|was not found"; then
      RECORD_EXISTS=""
    else
      echo "ERROR checking DNS TXT record:"  >&2
      echo "$DNS_RESULT"

      exit "$DNS_EXIT_CODE"
    fi
  fi

  ##############################################################################
  # Create DNS record if it doesn't exist
  ##############################################################################

  if [[ -z "$RECORD_EXISTS" ]]; then

    echo
    echo "DNS TXT Record does not exist."
    echo "Creating new record..."
    echo "+ New value: $DOMAIN_TOKEN"

    RECORD_SET_STATE=$(
      az network dns record-set txt create \
        --zone-name "$DOMAIN_DNS_ZONE_NAME" \
        --name "$RECORD_SET_NAME" \
        --value "$DOMAIN_TOKEN" \
        --output json \
        --subscription "$AZ_SUBSCRIPTION_SCOPE" \
        --resource-group "$DOMAIN_DNS_ZONE_RG" |
      jq -rc '.provisioningState'
    )

    echo
    echo "DNS Record creation: $RECORD_SET_STATE"

  else

    ############################################################################
    # Record exists - compare tokens
    ############################################################################

    RECORD_SET_CURRENT_TOKEN=$(
      echo "$RECORD_EXISTS" |
      jq -rc '.TXTRecords[0].value[0]'
    )

    echo
    echo "Old DNS token: $RECORD_SET_CURRENT_TOKEN"
    echo "New Front Door token: $DOMAIN_TOKEN"

    ############################################################################
    # Update DNS record if token has changed
    ############################################################################

    if [[ "$RECORD_SET_CURRENT_TOKEN" != "$DOMAIN_TOKEN" ]]; then

      echo
      echo "DNS TXT Record needs updating."
      echo "Updating DNS TXT Record..."

      DNS_UPDATE_RESULT=$(
        az network dns record-set txt update \
          --zone-name "$DOMAIN_DNS_ZONE_NAME" \
          --name "$RECORD_SET_NAME" \
          --set "txtRecords[0].value[0]=$DOMAIN_TOKEN" \
          --output json \
          --subscription "$AZ_SUBSCRIPTION_SCOPE" \
          --resource-group "$DOMAIN_DNS_ZONE_RG" \
          --only-show-errors \
          2>&1
      )

      DNS_EXIT_CODE=$?

      if [[ "$DNS_EXIT_CODE" -ne 0 ]]; then

        echo
        echo "ERROR: DNS Record update failed"  >&2
        echo "$DNS_UPDATE_RESULT"

        exit "$DNS_EXIT_CODE"

      fi

      RECORD_SET_STATE=$(
        echo "$DNS_UPDATE_RESULT" |
        jq -r '.provisioningState'
      )

      echo
      echo "DNS Record update: $RECORD_SET_STATE"

    else

      echo
      echo "DNS Record already contains the correct validation token."
      echo "Nothing to update."

    fi

  fi

else

  echo
  echo "Domain validation state is $STATE."
  echo "No DNS update required."

fi

################################################################################
# Wait for Front Door validation to become Approved
################################################################################

if [[ "$STATE" == "Pending" || "$STATE" == "PendingRevalidation" ]]; then

  WAIT_FOR_APPROVED_SECONDS=900
  WAIT_INTERVAL_SECONDS=15
  WAITED_SECONDS=0

  echo
  echo "Waiting for Azure Front Door validation state to become Approved..."

  while true; do

    CURRENT_DOMAIN=$(
      az afd custom-domain show \
        --ids "$RESOURCE_ID" \
        --output json \
        --only-show-errors
    )

    CURRENT_STATE=$(echo "$CURRENT_DOMAIN" | jq -rc '.domainValidationState')
    CURRENT_PROVISIONING_STATE=$(echo "$CURRENT_DOMAIN" | jq -rc '.provisioningState')

    echo "Current validation state: $CURRENT_STATE"
    echo "Current provisioning state: $CURRENT_PROVISIONING_STATE"

    if [[ "$CURRENT_STATE" == "Approved" ]]; then
      echo
      echo "SUCCESS: Azure Front Door validation state is Approved."
      break
    fi

    if [[ "$CURRENT_STATE" == "Rejected" || "$CURRENT_STATE" == "InternalError" || "$CURRENT_STATE" == "TimedOut" ]]; then
      echo
      echo "ERROR: Azure Front Door validation entered terminal state: $CURRENT_STATE" >&2
      exit 1
    fi

    if [[ "$WAITED_SECONDS" -ge "$WAIT_FOR_APPROVED_SECONDS" ]]; then
      echo
      echo "ERROR: Front Door did not reach Approved within $WAIT_FOR_APPROVED_SECONDS seconds." >&2
      echo "The DNS record may be correct but Front Door may still be waiting for DNS visibility/TTL expiry." >&2
      exit 1
    fi

    sleep "$WAIT_INTERVAL_SECONDS"
    WAITED_SECONDS=$((WAITED_SECONDS + WAIT_INTERVAL_SECONDS))

  done

fi


################################################################################
# Finished
################################################################################

echo
echo "============================================================"
echo "Finished processing $TARGET_DOMAIN"
echo "============================================================"
