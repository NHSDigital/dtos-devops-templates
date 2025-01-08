#!/bin/bash
# This script is called via a Terraform null resource, and will use Azure CLI login credentials.
# For this reason Terraform will be launched from an Azure CLI task in Azure DevOps
set -e

container_name="certbot-state"

# certbot uses canonical paths in the renewal conf files, and Azure DevOps workdir varies between Microsoft- and self-hosted agents
# https://github.com/certbot/certbot/issues/3953
agent_workdir=$(pwd)
agent_workdir=${agent_workdir%/src/layer2}
echo "agent_workdir=${agent_workdir}"

# Workaround for broken path on self-hosted Azure DevOps agents https://github.com/microsoft/azure-pipelines-agent/issues/3461
[[ ${agent_workdir} =~ "/agent/_work/" ]] && export PATH="${PATH}:/home/AzDevOps/.local/bin"

declare -a kv_names
subscription_id_target=""
subscription_id_hub=""
storage_account_name=""
environment=""
email=""

# Parse named parameters
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--email)
        email=("$2") # Add to array
        shift # past argument
        shift # past value
        ;;
        -kv|--keyvault)
        kv_names+=("$2") # Add to array
        shift # past argument
        shift # past value
        ;;
        -st|--subscription-target)
        subscription_id_target="$2"
        shift # past argument
        shift # past value
        ;;
        -sh|--subscription-hub)
        subscription_id_hub="$2"
        shift # past argument
        shift # past value
        ;;
        -sa|--storage-account-name)
        storage_account_name="$2"
        shift # past argument
        shift # past value
        ;;
        -en|--environment)
        environment="$2"
        shift # past argument
        shift # past value
        ;;
        *)
        break
        ;;
    esac
done

# Validate required parameters
if [[ ${#kv_names[@]} -eq 0 || -z "${email}" || -z "${subscription_id_target}" || -z "${subscription_id_hub}" || -z "${storage_account_name}" || -z "${environment}" ]]; then
    echo "Usage: $0"
    echo "       -e <email>"
    echo "       -st <subscription_id_target>"
    echo "       -sh <subscription_id_hub>"
    echo "       -sa <storage_account_name>"
    echo "       -en <environment>"
    echo "       -kv <dest_key_vault_name_1> [-kv <dest_key_vault_name_2> ...]"
    echo "       <domain1> [<domain2> ...]"
    exit 1
fi

pip3 install certbot certbot-dns-azure
mkdir -p .terraform/certbot
cd .terraform # to prevent any temp files being accidentally written back to repo during local deployment

echo "Attempting retrieval of stored certificate creation state..."
az account set --subscription "${subscription_id_hub}"
az storage blob download --account-name "${storage_account_name}" --container-name "${container_name}" --name "${environment}.zip" --file "./certbot_state.zip" --auth-mode login || true # continue on failure
if [[ -e ./certbot_state.zip ]]; then
    unzip -o ./certbot_state.zip
    rm ./certbot_state.zip
    # reset canonical paths in renewal conf files to match the local environment
    sed -i "s#agent_workdir#${agent_workdir}#g" certbot/config/renewal/*.conf
fi

az account set --subscription "${subscription_id_target}"

# Process each domain (certificate subject) serially
while [[ $# -gt 0 ]]; do
    domain="$1"
    shift # past argument

    certbot certonly -d "${domain}" \
      --authenticator dns-azure \
      --preferred-challenges dns \
      --dns-azure-config certbot_dns.ini \
      --config-dir certbot/config \
      --work-dir certbot/work \
      --logs-dir certbot/logs \
      --email "${email}" \
      --noninteractive \
      --agree-tos

    # Trim off the leading "*." from domain for file and certificate names
    trimmed_domain="${domain#\*.}"
    # Construct Key Vault certificate name
    cert_name="${domain/\*\./wildcard-}"
    cert_name="${cert_name//./-}"

    thumbprint_local=$(openssl x509 -in certbot/config/live/${trimmed_domain}/cert.pem -noout -fingerprint -sha1 | sed 's/.*=//;s/://g')
    thumbprint64_local=$(echo "${thumbprint_local}" | xxd -r -p | base64)

    # Import certificate into each Key Vault
    for kv_name in "${kv_names[@]}"; do
        # Retrieve the thumbprint of any pre-existing certificate with this name in Key Vault
        # Key Vault doesn't check thumbprints, and will create a new version even if the thumbprint is identical, causing unnecessary downstream Terraform changes where the cert is used
        thumbprint64_kv=$(az keyvault certificate show --vault-name "${kv_name}" --name "${cert_name}" --query "x509Thumbprint" --output tsv || true) # continue on failure
        if [[ "${thumbprint64_local}" == "${thumbprint64_kv}" ]]; then
            echo "Certificate ${cert_name} with thumbprint ${thumbprint_local} already exists in Key Vault ${kv_name}, skipping import..."
        else
            echo "Importing certificate ${cert_name} into Key Vault ${kv_name}..."
            openssl pkcs12 -export -inkey certbot/config/live/${trimmed_domain}/privkey.pem -in certbot/config/live/${trimmed_domain}/fullchain.pem -out ${trimmed_domain}.pfx -password pass:
            az keyvault certificate import --vault-name "${kv_name}" --name "${cert_name}" --file "${trimmed_domain}.pfx" --password ""
        fi
    done
    [[ -e "${trimmed_domain}.pfx" ]] && rm "${trimmed_domain}.pfx"
done

echo "Persisting certificate creation state to Azure Storage Account..."
# reset canonical paths in renewal conf files to something predictable
sed -i "s#${agent_workdir}#agent_workdir#g" certbot/config/renewal/*.conf
zip -ry certbot_state.zip certbot/config certbot/logs
az account set --subscription "${subscription_id_hub}"
az storage blob upload --account-name "${storage_account_name}" --container-name "${container_name}" --file "./certbot_state.zip" --name "${environment}.zip" --overwrite --auth-mode login

# Cleanup, destroy any local key material
rm certbot_state.zip
rm -rf certbot
rm certbot_dns.ini
cd ..
