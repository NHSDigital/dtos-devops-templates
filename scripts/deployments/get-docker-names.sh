#!/bin/bash

set -eo pipefail

remove_from_array() {
    local item_to_remove="$1"
    local -n target_array="$2"  # Use nameref to modify the array directly
    local filtered_array=()

    for item in "${target_array[@]}"; do
        [[ "$item" != "$item_to_remove" ]] && filtered_array+=("$item")
    done

    target_array=("${filtered_array[@]}")
}

if [[ -z "${COMPOSE_FILES_CSV}" ]]; then
    echo "❌ Error: COMPOSE_FILES_CSV has not been defined (comma separated)."
    exit 1
fi

# CHANGED_FOLDERS_CSV can be supplied via environment variable for local testing
if [[ -z "${CHANGED_FOLDERS_CSV}" ]]; then
    if [[ -z "${SOURCE_CODE_PATH}" ]]; then
        echo "❌ Error: SOURCE_CODE_PATH has not been defined."
        exit 1
    fi
    if [[ "${GITHUB_EVENT_NAME}" == "push" && "${GITHUB_REF}" == "refs/heads/main" ]]; then
        # Merge to main - compare merging feature branch with main immediately prior to the merge (HEAD^), needs 'fetch-depth: 2' parameter for actions/checkout@v4
        mapfile -t source_changes < <(git diff --name-only HEAD^ -- "${SOURCE_CODE_PATH}" | sed -r 's#(^.*/).*$#\1#' | sort -u)
    else
        # PR creation or update - compare feature branch with main, folder paths only, unique list
        git fetch origin main
        mapfile -t source_changes < <(git diff --name-only origin/main..HEAD -- "${SOURCE_CODE_PATH}" | sed -r 's#(^.*/).*$#\1#' | sort -u)
    fi
else
    IFS=',' read -r -a source_changes <<< "${CHANGED_FOLDERS_CSV}"
fi

echo -e "\nChanged source code folder(s):"
printf "  - %s\n" "${source_changes[@]}"
echo

[[ -n "${EXCLUDED_CONTAINERS_CSV}" ]] && EXCLUSION_FILTER="select($(echo "${EXCLUDED_CONTAINERS_CSV}" | awk -v ORS='' '{split($0, arr, ","); for (i in arr) printf ".container_name != \"%s\" and ", arr[i]} END {print "1"}')) |"

IFS_OLD=$IFS
IFS=$', \n'
changed_services=()
non_matched_changes=()

for compose_file in ${COMPOSE_FILES_CSV}; do

    echo -e "Parsing Docker compose file '${compose_file}'...\n"
    declare -A docker_services_map=()

    # STEP 1 - Create a map of folder paths to services
    for service in $(yq eval ".services[] | ${EXCLUSION_FILTER} .container_name" "${compose_file}"); do
        # Combine the context and dockerfile variables to determine the container root
        # We need to filter these since there are various ways these can be defined (leading ./ or trailing / for instance)
        context=$(yq eval ".services[] | select(.container_name == \"$service\") | .build.context" "${compose_file}")
        dockerfile=$(yq eval ".services[] | select(.container_name == \"$service\") | .build.dockerfile" "${compose_file}")

        if [[ -z "${dockerfile}" ]] || [[ -z "${context}" ]]; then
            continue
        fi
        context_filtered=$(echo "${context}" | sed 's#^\./src/##' | sed 's#^\./##' | sed 's#/$##')
        dockerfile_filtered=$(echo "${dockerfile}" | sed 's#^\./##' | sed 's#\/Dockerfile##' | sed 's#Dockerfile##')
        if [[ -n "${context_filtered}" ]] && [[ -n "${dockerfile_filtered}" ]]; then
            function_path="${context_filtered}/${dockerfile_filtered}"
        else
            function_path="${context_filtered}${dockerfile_filtered}"
        fi
        docker_services_map[${function_path}]=${service}
    done
    printf "%-50s %-50s\n" "Service" "Path"
    printf "%-50s %-50s\n" "-------" "----"
    for key in "${!docker_services_map[@]}"; do
        printf "%-50s %-50s\n" "${docker_services_map[$key]}" "$key"
    done
    echo

    # STEP 2 - Now check the source code changes against the map created in STEP 1 to determine which containers to build
    if [[ ${#source_changes[@]} -eq 0 ]]; then
        echo "No files changed."

    elif [[ "${source_changes[*],,}" =~ shared ]]; then
        echo "Shared folder changed, building all images."
        for key in "${!docker_services_map[@]}"; do
            changed_services+=("${docker_services_map[$key]}")
        done
    else
        echo "Checking changed folders..."
        for folder in "${source_changes[@]}"; do
            matched="false"
            for function_path in "${!docker_services_map[@]}"; do
                # The changed folder may be a deeper path than the Function path, so it must be matched this way around
                if [[ "${folder}" =~ ${function_path} ]]; then
                    changed_services+=("${docker_services_map[$function_path]}")
                    echo "  - ${folder} matches service '${docker_services_map[$function_path]}'"
                    matched="true"
                    remove_from_array "$folder" source_changes
                    remove_from_array "$folder" non_matched_changes # In case it's in this array from a previous compose file iteration
                    continue
                fi
            done
            # Collect changed folders that were not matched to services
            [[ "${matched}" == "false" ]] && non_matched_changes+=("${folder}")
        done
    fi
    echo
done

if [ ${#non_matched_changes[@]} -ne 0 ]; then
    # Remove duplicates (non-matched items across several compose files)
    unique_changes=("$(printf "%s\n" "${non_matched_changes[@]}" | sort -u)")

    warning_message=$(
        cat <<EOF
⚠️ Warning!
The following source code changes did not match any services defined in the provided Docker compose file(s):
$(printf '  - %s\n' "${unique_changes[@]}")

EOF
)
    echo -e "$warning_message\n"
    echo "#### $warning_message" >> "$GITHUB_STEP_SUMMARY"
fi

changed_services_json="$(jq -c -n '$ARGS.positional | unique' --args "${changed_services[@]}")"

IFS=$IFS_OLD
echo "List of services to build:"
echo "${changed_services_json}"
echo "FUNC_NAMES=${changed_services_json}" >> "${GITHUB_OUTPUT}"

# Assumes all compose files are together in the same folder
echo "DOCKER_COMPOSE_DIR=$(dirname "${compose_file}")" >> "${GITHUB_OUTPUT}"
