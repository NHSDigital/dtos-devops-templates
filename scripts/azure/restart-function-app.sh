#!/bin/bash

set -eo pipefail

if [[ -z "${FUNCTION_APP_NAME}" ]]; then
    echo "❌ Error: FUNCTION_APP_NAME has not been defined."
    exit 1
fi


RESOURCE_GROUP=$(az functionapp list --query "[?name=='$FUNCTION_APP_NAME'].resourceGroup" -o tsv)

if [[ -z "$RESOURCE_GROUP" ]]; then
  echo "❌ Could not find the Resource Group for the Function App named '$FUNCTION_APP_NAME'"
  exit 1
fi

echo "Found Function App in resource group: $RESOURCE_GROUP"
echo "Restarting..."

az functionapp restart --name "$FUNCTION_APP_NAME" --resource-group "$RESOURCE_GROUP"

echo "✅ Function App restarted successfully."