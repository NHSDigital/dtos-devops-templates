#!/bin/bash
GITHUB_TOKEN="<private github classic token with write packages permission>"
ORG="NHSDigital"
REPO_NAME="dtos-service-layer"

echo "=== Testing Repository Level ==="
# Capture raw output
repo_raw_response=$(curl -s \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/nhsdigital/dtos-service-layer/packages?package_type=container")

echo "--- Raw Repository Response ---"
echo "$repo_raw_response"
echo "-------------------------------"

if echo "$repo_raw_response" | jq -e '. | type == "array"' > /dev/null 2>&1; then
    echo "$repo_raw_response" | jq '.[] | .name'
else
    echo "Repository API response (jq failed):"
    echo "$repo_raw_response" | jq '.' # This line might still fail if it's not JSON at all
fi

echo
echo "=== Testing Organisation Level ==="
# Capture raw output
org_raw_response=$(curl -s \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/orgs/$ORG/packages?package_type=container")

echo "--- Raw Organisation Response ---"
echo "$org_raw_response"
echo "---------------------------------"

if echo "$org_raw_response" | jq -e '. | type == "array"' > /dev/null 2>&1; then
  echo "$org_raw_response" | jq --arg repo "$REPO_NAME" '.[] | select(.repository.name == $repo) | .name'
else
  echo "Organisation API response (jq failed):"
  echo "$org_raw_response" | jq '.' # This line might still fail if it's not JSON at all
fi
