#!/bin/bash

# Environment Variables:
# ==========================
# REGISTRY_OWNER
# PROJECT_NAME
# GH_TOKEN
# SHORT_COMMIT_HASH
# ENVIRONMENT_TAG

echo "Tagging all repositories in '$REGISTRY_PACKAGE' with a short commit hash: $SHORT_COMMIT_HASH"
echo "Source tag for import will be: $ENVIRONMENT_TAG"

# Get list of repositories
#repo_list=$(az acr repository list --name "$ACR_NAME" --output tsv)
repo_list=$(gh api "/user/packages?package_type=container" --jq '.[].name')

if [ -z "$repo_list" ]; then
  echo "No repositories found in '$REGISTRY_PACKAGE'. Nothing to tag."
  exit 0
fi

echo "Found repositories: $(echo $repo_list | wc -w)"
echo "---"

exit_code=0

for repo_name in $repo_list; do
  #source_image="${ACR_NAME}.azurecr.io/${repo_name}:${ENVIRONMENT_TAG}"
  source_image="ghcr.io/${REGISTRY_OWNER}/${repo_name}:${ENVIRONMENT_TAG}"
  target_image="ghcr.io/${REGISTRY_OWNER}/${repo_name}:${SHORT_COMMIT_HASH}"

  echo "Processing repository: ghcr.io/${REGISTRY_OWNER}/${repo_name}"
  echo "  Checking for existing target tag: $SHORT_COMMIT_HASH"

  #target_tag_check_output=$(az acr manifest list-metadata --registry "$ACR_NAME" --name "$repo_name" --query "[?tags.contains(@, '${SHORT_COMMIT_HASH}')]" --output tsv)
  target_tag_check_output=$(curl -s \
    -H "Authorization: Bearer ${GH_TOKEN}" -H "Accept: application/vnd.github+json" \
    "https://api.github.com/orgs/${REGISTRY_OWNER}/packages/container/${repo_name}/versions" | \
    jq -r --arg tag "$SHORT_COMMIT_HASH" '.[] | \
    select(.metadata.container.tags[]? == $tag) | .name')

  target_tag_check_status=$?

  if [ $target_tag_check_status -eq 0 ] && [ -n "$target_tag_check_output" ]; then
    echo "  Target tag '$SHORT_COMMIT_HASH' already exists. Skipping import for this repository."
    echo "---"
    continue
  fi

  echo "  Proceeding with import: $source_image -> $target_image"
  docker buildx imagetools create "${source_image}" --tag "${target_image}"

  # az acr import \
  #   --name "$ACR_NAME" \
  #   --source "$source_image" \
  #   --image "$target_image" \
  #   --force

  import_status=$?

  if [ $import_status -ne 0 ]; then
    echo "  ⚠️ Warning: ACR import command failed for '$REGISTRY_PACKAGE' (Exit Code: $import_status)."
    exit_code=1 # Record import failure
  else
    echo "  Import successful for '$REGISTRY_PACKAGE'."
  fi
  echo "---"
done

echo "Finished processing all repositories."
exit $exit_code
