#! /bin/bash

if [ $1 = "--secrets-from-file" ]; then
  PROJECT_ID=$(jq -r '.projectId' secrets.json)
  ENVIRONMENT_ID=$(jq -r '.environmentId' secrets.json)
  API_KEY=$(jq -r '.apiKey' secrets.json)
  CLIENT_ID=$(jq -r '.clientId' secrets.json)
  CLIENT_SECRET=$(jq -r '.clientSecret' secrets.json)
else
  read -p "Project ID: " PROJECT_ID
  read -p "Environment ID: " ENVIRONMENT_ID
  read -p "API Key: " API_KEY
  read -p "Client ID: " CLIENT_ID
  read -p "Client Secret: " CLIENT_SECRET
fi

ACCESS_TOKEN=$(curl --no-progress-meter -f --location "https://auth.spaceblocks.cloud/token-manager/token" \
  --request POST \
  --header "Content-Type: application/json" \
  --header "apiKey: $API_KEY" \
  --data "{
    \"client_id\": \"$CLIENT_ID\",
    \"client_secret\": \"$CLIENT_SECRET\",
    \"scope\": \"permissions:management:read permissions:management:write core:permissions:config:read core:permissions:config:write\"
  }" | jq -r .access_token)

# Create resource type
curl --no-progress-meter -i --location "https://api.spaceblocks.cloud/public/projects/$PROJECT_ID/environments/$ENVIRONMENT_ID/permissions/config/resource-types" \
  --request POST \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --header "apiKey: $API_KEY" \
  --data '{
    "name": "City",
    "id": "city",
    "parentId": "tenant"
  }'

# Create permissions
curl --no-progress-meter -i --location "https://api.spaceblocks.cloud/public/projects/$PROJECT_ID/environments/$ENVIRONMENT_ID/permissions/config/resource-types/city/permissions" \
  --request POST \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --header "apiKey: $API_KEY" \
  --data '{
    "name": "Get current forecast",
    "id": "get-current-forecast"
  }'

curl --no-progress-meter -i --location "https://api.spaceblocks.cloud/public/projects/$PROJECT_ID/environments/$ENVIRONMENT_ID/permissions/config/resource-types/city/permissions" \
  --request POST \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --header "apiKey: $API_KEY" \
  --data '{
    "name": "Get future forecast",
    "id": "get-future-forecast"
  }'

# Create roles
curl --no-progress-meter -i --location "https://api.spaceblocks.cloud/public/projects/$PROJECT_ID/environments/$ENVIRONMENT_ID/permissions/config/static-roles" \
  --request POST \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --header "apiKey: $API_KEY" \
  --data '{
    "name": "Current Forecast Viewer",
    "id": "current-forecast-viewer",
    "permissions": {
      "city": [ "get-current-forecast" ]
    }
  }'

curl --no-progress-meter -i --location "https://api.spaceblocks.cloud/public/projects/$PROJECT_ID/environments/$ENVIRONMENT_ID/permissions/config/static-roles" \
  --request POST \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --header "apiKey: $API_KEY" \
  --data '{
    "name": "Future Forecast Viewer",
    "id": "future-forecast-viewer",
    "permissions": {
      "city": [ "get-future-forecast" ]
    }
  }'
