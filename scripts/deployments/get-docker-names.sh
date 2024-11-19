#!/bin/bash

if [ $# -lt 2 ]; then
  echo "Usage: $0 <docker_compose_file> <excluded_containers_comma_separated>"
  exit 1
fi

DOCKER_COMPOSE_FILE=$1
WORKING_DIR="$(dirname "$1")"
EXCLUDED_CONTAINERS=$2

EXCLUSION_FILTER=$(echo "$EXCLUDED_CONTAINERS" | awk -v ORS='' '{split($0, arr, ","); for (i in arr) printf ".container_name != \"%s\" and ", arr[i]} END {print "1"}')

cd "$WORKING_DIR" || { echo "Directory not found: $WORKING_DIR"; exit 1; }

declare -A docker_functions_map=()

set -x

for service in $(yq eval ".services[] | select($EXCLUSION_FILTER) | .container_name" ${DOCKER_COMPOSE_FILE}); do
  context=$(yq eval ".services[] | select(.container_name == \"$service\") | .build.context" ${DOCKER_COMPOSE_FILE})
  dockerfile=$(yq eval ".services[] | select(.container_name == \"$service\") | .build.dockerfile" ${DOCKER_COMPOSE_FILE})

  if [ -z ${dockerfile} ] || [ -z ${context} ] ; then
    continue
  fi
  contextFiltered=$(echo ${context} | sed 's#^\./src/##' | sed 's#^\./##' | sed 's#/$##')
  dockerfileFiltered=$(echo ${dockerfile} | sed 's#^\./##' | sed 's#\/Dockerfile##' | sed 's#Dockerfile##' )
  docker_functions_map[${contextFiltered}${dockerfileFiltered}]=${service}
done


for key in "${!docker_functions_map[@]}"; do
  echo "Key: $key Value: ${docker_functions_map[$key]}"
done


changed_functions=""

set -x

if [ -z "$CHANGED_FOLDERS" ]; then
    changed_functions="null"
    echo "No files changed"
elif [[ "$CHANGED_FOLDERS" == *Shared* ]]; then
    echo "Shared folder changed, returning all functions"
    for key in "${!docker_functions_map[@]}"; do
        changed_functions+=" ${docker_functions_map[$key]}"
        echo "Adding in: ${docker_functions_map[$key]}"
    done
else
    echo "files changed $CHANGED_FOLDERS "
    for folder in $CHANGED_FOLDERS; do
      echo "Add this function in: ${folder} "
      echo "Add this which maps to: ${docker_functions_map[$folder]} "
      changed_functions+=" ${docker_functions_map[$folder]}"
    done
fi

# Format the output for the github matrix:
changed_functions_json=$(printf '["%s"]' "$(echo $changed_functions | sed 's/ /","/g')")

echo "Final list of functions to rebuild:"
echo "$changed_functions_json"

echo "FUNC_NAMES=$changed_functions_json" >> "$GITHUB_OUTPUT"
