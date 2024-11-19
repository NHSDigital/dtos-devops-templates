#!/bin/bash

if [ $# -lt 2 ]; then
  echo "Usage: $0 <working_directory> <excluded_containers_comma_separated>"
  exit 1
fi

WORKING_DIR=$1
EXCLUDED_CONTAINERS=$2

EXCLUSION_FILTER=$(echo "$EXCLUDED_CONTAINERS" | awk -v ORS='' '{split($0, arr, ","); for (i in arr) printf ".container_name != \"%s\" and ", arr[i]} END {print "1"}')

cd "$WORKING_DIR" || { echo "Directory not found: $WORKING_DIR"; exit 1; }

declare -A docker_functions_map=()

for service in $(yq eval ".services[] | select($EXCLUSION_FILTER) | .container_name" compose.yaml); do
  dockerfile=$(yq eval ".services[] | select(.container_name == \"$service\") | .build.dockerfile" compose.yaml | sed 's#.\/##')
  servicename=$(yq eval ".services[] | select(.container_name == \"$service\") | .container_name" compose.yaml)
  docker_functions_map["$dockerfile"]="$servicename"
done

echo "declare -A docker_functions_map=("
for key in "${!docker_functions_map[@]}"; do
  echo "    [\"$key\"]=\"${docker_functions_map[$key]}\""
done
echo ")"


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
