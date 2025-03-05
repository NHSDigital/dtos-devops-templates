#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Usage: $0 <docker_compose_file> <excluded_containers_comma_separated>"
    exit 1
fi
echo "Parsing Docker compose file..."
echo
DOCKER_COMPOSE_FILE=$1
WORKING_DIR="$(dirname "$1")"
EXCLUDED_CONTAINERS=$2

EXCLUSION_FILTER=$(echo "${EXCLUDED_CONTAINERS}" | awk -v ORS='' '{split($0, arr, ","); for (i in arr) printf ".container_name != \"%s\" and ", arr[i]} END {print "1"}')

cd "${WORKING_DIR}" || { echo "Directory not found: ${WORKING_DIR}"; exit 1; }

declare -A docker_functions_map=()

for service in $(yq eval ".services[] | select($EXCLUSION_FILTER) | .container_name" ${DOCKER_COMPOSE_FILE}); do
    context=$(yq eval ".services[] | select(.container_name == \"$service\") | .build.context" ${DOCKER_COMPOSE_FILE})
    dockerfile=$(yq eval ".services[] | select(.container_name == \"$service\") | .build.dockerfile" ${DOCKER_COMPOSE_FILE})

    if [ -z ${dockerfile} ] || [ -z ${context} ]; then
        continue
    fi
    context_filtered=$(echo ${context} | sed 's#^\./src/##' | sed 's#^\./##' | sed 's#/$##')
    dockerfile_filtered=$(echo ${dockerfile} | sed 's#^\./##' | sed 's#\/Dockerfile##' | sed 's#Dockerfile##')
    if [ -n "${context_filtered}" ] && [ -n "${dockerfile_filtered}" ]; then
        function_path="${context_filtered}/${dockerfile_filtered}"
    else
        function_path="${context_filtered}${dockerfile_filtered}"
    fi
    docker_functions_map[${function_path}]=${service}
done

printf "%-40s %-50s\n" "Service" "Path"
printf "%-40s %-50s\n" "-------" "----"
for key in "${!docker_functions_map[@]}"; do
    printf "%-40s %-50s\n" "${docker_functions_map[$key]}" "$key"
done
echo

changed_functions=""

if [ -z "${CHANGED_FOLDERS}" ]; then
    changed_functions="null"
    echo "No files changed"
elif [[ "${CHANGED_FOLDERS,,}" =~ shared ]]; then
    echo "Shared folder changed, building all images"
    for key in "${!docker_functions_map[@]}"; do
        changed_functions+=" ${docker_functions_map[$key]}"
        echo "- ${docker_functions_map[$key]}"
    done
else
    echo "Checking changed folders..."
    for folder in ${CHANGED_FOLDERS}; do
        for function_path in "${!docker_functions_map[@]}"; do
            # The changed folder may be a deeper path than the Function path, so it must be matched this way around
            if [[ "${folder}" =~ ${function_path} ]]; then
                changed_functions+=" ${docker_functions_map[$function_path]}"
                echo "${folder} matches service '${docker_functions_map[$function_path]}'"
                continue
            fi
        done
    done
fi
echo

# Format the output for the github matrix:
changed_functions=${changed_functions# }
changed_functions_json="[${changed_functions// /,}]"

echo "List of services to build:"
echo "${changed_functions_json}"

echo "FUNC_NAMES=${changed_functions_json}" >> "${GITHUB_OUTPUT}"
