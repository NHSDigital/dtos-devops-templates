#!/bin/bash

# Pipestatus: if any command in a pipeline fails, the return status is that of the failed command.
set -o pipefail
# Print each command to stderr before executing.
set -x

echo "Attempting to tag all repositories in ACR $ACR_NAME with short commit hash: $SHORT_COMMIT_HASH"
echo "Source tag for import will be: $ENVIRONMENT_TAG"

# Get list of repositories
repo_list=$(az acr repository list --name "$ACR_NAME" --output tsv)

if [ -z "$repo_list" ]; then
  echo "No repositories found in ACR $ACR_NAME. Nothing to tag."
  exit 0
fi

echo "Found repositories: $(echo $repo_list | wc -w)"
echo "---"

exit_code=0

for repo_name in $repo_list; do
  source_image="${ACR_NAME}.azurecr.io/${repo_name}:${ENVIRONMENT_TAG}"
  target_image="${repo_name}:${SHORT_COMMIT_HASH}"

  echo "Processing repository: $repo_name"

  echo "  Checking for existing target tag: $SHORT_COMMIT_HASH"
  target_tag_check_output=$(az acr manifest list-metadata --registry "$ACR_NAME" --name "$repo_name" --query "[?tags != null && contains(tags, '${SHORT_COMMIT_HASH}')]" --output tsv)
  target_tag_check_status=$?

  if [ $target_tag_check_status -eq 0 ] && [ -n "$target_tag_check_output" ]; then
    echo "  Target tag '$SHORT_COMMIT_HASH' already exists. Skipping import for this repository."
    echo "---"
    continue
  fi

  echo "  Proceeding with import attempt: $source_image -> $target_image"

  az acr import \
    --name "$ACR_NAME" \
    --source "$source_image" \
    --image "$target_image" \
    --force

  import_status=$?

  if [ $import_status -ne 0 ]; then
    echo "  ⚠️ Warning: ACR import command failed for repository '$repo_name' (Exit Code: $import_status)."
    exit_code=1 # Record import failure
  else
    echo "  Import successful for '$repo_name'."
  fi
  echo "---"
done

echo "Finished processing all repositories."
exit $exit_code
