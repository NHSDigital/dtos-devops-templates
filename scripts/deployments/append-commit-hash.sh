#!/bin/bash

# Environment Variables:
#==========================
# REPO_NAME, SHORT_COMMIT_HASH, ENVIRONMENT_TAG, GH_TOKEN, GITHUB_REPO_OWNER, PACKAGE_REPO

echo "Tagging all repositories in '${REGISTRY_OWNER}/${PROJECT_NAME}' with a hash/tag: ${COMMIT_HASH_TAG}"
echo "Source tag for import is: $ENVIRONMENT_TAG"

# Get list of repositories
#repo_list=$(az acr repository list --name "$ACR_NAME" --output tsv)
api_query="gh api /repos/${REGISTRY_OWNER}/${PROJECT_NAME}/packages?package_type=container"

repo_list=$(curl -s \
  -H "Authorization: Bearer ${GH_TOKEN} " \
  -H "Accept: application/vnd.github+json" "$api_query" | \
  jq -r '.[].name')

if [ -z "$repo_list" ]; then
  echo "No repositories found in '${REGISTRY_OWNER}/${PROJECT_NAME}'. Nothing to tag."
  exit 0
fi

echo "Found repositories: $(echo $repo_list | wc -w)"
echo "---"

exit_code=0

for repo_name in $repo_list; do
  #source_image="${ACR_NAME}.azurecr.io/${repo_name}:${ENVIRONMENT_TAG}"
  source_image="${REGISTRY_PACKAGE}:${ENVIRONMENT_TAG}"
  target_image="${REGISTRY_PACKAGE}:${COMMIT_HASH_TAG}"

  echo "Processing repository: ${REGISTRY_PACKAGE}"
  echo "  Checking for existing target tag: ${COMMIT_HASH_TAG}"

  #target_tag_check_output=$(az acr manifest list-metadata --registry "$ACR_NAME" --name "$repo_name" --query "[?tags.contains(@, '${SHORT_COMMIT_HASH}')]" --output tsv)
  target_tag_check_output=$(curl -s \
    -H "Authorization: Bearer ${GH_TOKEN}" \
    -H "Accept: application/vnd.github+json" \
    "gh api /repos/${REGISTRY_OWNER}/${PROJECT_NAME}/packages/container/versions" | \
    jq -r --arg tag "${COMMIT_HASH_TAG}" '.[] | select(.metadata.container.tags[]? == $tag) | .name')

  target_tag_check_status=$?

  if [ $target_tag_check_status -eq 0 ] && [ -n "$target_tag_check_output" ]; then
    echo "  Target tag '${COMMIT_HASH_TAG}' already exists. Skipping import for this repository."
    echo "---"
    continue
  fi

  echo "  Proceeding with import: $source_image -> $target_image"

  docker buildx imagetools create \
    ${REGISTRY_PACKAGE}:${ENVIRONMENT_TAG} \
    --tag ${REGISTRY_PACKAGE}:${COMMIT_HASH_TAG}

  # az acr import \
  #   --name "$ACR_NAME" \
  #   --source "$source_image" \
  #   --image "$target_image" \
  #   --force

  import_status=$?

  if [ $import_status -ne 0 ]; then
    echo "  ⚠️ Warning: Import command failed for '${REGISTRY_OWNER}/${PROJECT_NAME}' (Exit Code: $import_status)."
    exit_code=1 # Record import failure
  else
    echo "  Import successful for '${REGISTRY_OWNER}/${PROJECT_NAME}'."
  fi
  echo "---"
done

echo "Finished processing all repositories."
exit $exit_code
