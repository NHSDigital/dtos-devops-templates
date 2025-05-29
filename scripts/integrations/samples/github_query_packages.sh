#!/bin/bash
GITHUB_TOKEN="<YOU_PAT_TOKEN>" # if using your own GitHub account, create a "classic" token with "packages:write" permission
ORG="NHSDigital"
REPO_NAME="dtos-service-layer"

echo "=== Testing Repository Level ==="
repo_response=$(curl -s \
	-H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/nhsdigital/dtos-service-layer/packages?package_type=container")

if echo "$repo_response" | jq -e '. | type == "array"' > /dev/null 2>&1; then
    echo "$repo_response" | jq '.[] | .name'
else
    echo "Repository API response:"
    echo "$repo_response" | jq '.'
fi

echo
echo "=== Testing Organization Level ==="
org_response=$(curl -s \
	-H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/orgs/$ORG/packages?package_type=container")

if echo "$org_response" | jq -e '. | type == "array"' > /dev/null 2>&1; then
    echo "$org_response" | jq --arg repo "$REPO_NAME" '.[] | select(.repository.name == $repo) | .name'
else
    echo "Organization API response:"
    echo "$org_response" | jq '.'
fi

echo
echo "=== All Org Packages ==="
all_response=$(curl -s \
	-H "Authorization: Bearer $GITHUB_TOKEN" \
	-H "Accept: application/vnd.github.v3+json" \
	"https://api.github.com/orgs/$ORG/packages?package_type=container" \
	| jq '.[] | {name: .name, repo: .repository.name}' )

if echo "$all_response" | jq -e '. | type == "array"' > /dev/null 2>&1; then
    echo "$all_response" | jq --arg repo "$REPO_NAME" '.[] | select(.repository.name == $repo) | .name'
else
    echo "All API response:"
    echo "$all_response" | jq '.'
fi
