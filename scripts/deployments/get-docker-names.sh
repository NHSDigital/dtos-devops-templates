#!/bin/bash

set -x  # Uncomment for debugging

if [ $# -lt 2 ]; then
  echo "Usage: $0 <docker_compose_file> <excluded_containers_comma_separated>"
  exit 1
fi

set -x

DOCKER_COMPOSE_FILE=$1
WORKING_DIR="$(dirname "$1")"
EXCLUDED_CONTAINERS=$2

find . -type f | grep -i compose

pwd

EXCLUSION_FILTER=$(echo "${EXCLUDED_CONTAINERS}" | awk -v ORS='' '{split($0, arr, ","); for (i in arr) printf ".container_name != \"%s\" and ", arr[i]} END {print "1"}')

cd "${WORKING_DIR}" || { echo "Directory not found: ${WORKING_DIR}"; exit 1; }

echo "Alastair 2"

ABSOLUTE_PATH_DOCKER_COMPOSE_FILE=$(find . -type f | grep -i compose-core)

pwd

echo DOCKER_COMPOSE_FILE: ${DOCKER_COMPOSE_FILE}

# ABSOLUTE_PATH_DOCKER_COMPOSE_FILE=$( echo $(pwd)/${DOCKER_COMPOSE_FILE} )

# ABSOLUTE_PATH_DOCKER_COMPOSE_FILE="./application/CohortManager/compose.core.yaml"

ls -l ${ABSOLUTE_PATH_DOCKER_COMPOSE_FILE}

echo "Alastair 3"

declare -A docker_functions_map=()

for service in $(yq eval ".services[] | select($EXCLUSION_FILTER) | .container_name" "${ABSOLUTE_PATH_DOCKER_COMPOSE_FILE}"); do
  context=$(yq eval ".services[] | select(.container_name == \"$service\") | .build.context" "${ABSOLUTE_PATH_DOCKER_COMPOSE_FILE}")
  dockerfile=$(yq eval ".services[] | select(.container_name == \"$service\") | .build.dockerfile" "${ABSOLUTE_PATH_DOCKER_COMPOSE_FILE}")

  if [ -z "${dockerfile}" ] || [ -z "${context}" ] ; then
    continue
  fi
  contextFiltered=$(echo "${context}" | sed 's#^\./src/##' | sed 's#^\./##' | sed 's#/$##')
  dockerfileFiltered=$(echo "${dockerfile}" | sed 's#^\./##' | sed 's#\/Dockerfile##' | sed 's#Dockerfile##' )
  docker_functions_map["${contextFiltered}${dockerfileFiltered}"]="${service}"
done

changed_functions=""

if [ -z "${CHANGED_FOLDERS}" ]; then
    changed_functions="null"
    echo "No files changed"
elif [[ "${CHANGED_FOLDERS,,}" =~ shared ]]; then
    echo "Shared folder changed, returning all functions"
    for key in "${!docker_functions_map[@]}"; do
        changed_functions+=" ${docker_functions_map[$key]}"
        echo "Adding in: ${docker_functions_map[$key]}"
    done
else
    echo "files changed ${CHANGED_FOLDERS} "

    for folder in ${CHANGED_FOLDERS}; do
      echo "Checking folder: ${folder}"
      for key in "${!docker_functions_map[@]}";
        if [[ "$key" == "$folder" ]]; then
          echo "Found match: ${folder} -> ${docker_functions_map[$key]}"
          changed_functions+=" ${docker_functions_map[$key]}"
          break
        fi
      done
    done
fi

changed_functions_json=$(printf '["%s"]' "$(echo "${changed_functions}" | sed 's/ /","/g')")

echo "Final list of functions to rebuild:"
echo "${changed_functions_json}"

echo "FUNC_NAMES+=${changed_functions_json}" >> "${GITHUB_OUTPUT}"
