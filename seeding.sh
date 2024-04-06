read -p "Permissions URL: " PERMISSIONS_URL
read -p "API Key: " API_KEY
read -p "Client ID: " CLIENT_ID
read -p "Client Secret: " CLIENT_SECRET

ACCESS_TOKEN=$(curl --no-progress-meter -f --location "https://auth.spaceblocks.cloud/token-manager/token" \
  --request POST \
  --header "Content-Type: application/json" \
  --header "apiKey: $API_KEY" \
  --data "{
    \"client_id\": \"$CLIENT_ID\",
    \"client_secret\": \"$CLIENT_SECRET\",
    \"scope\": \"permissions:management:read permissions:management:write\"
  }" | jq -r .access_token)

# Create a tenant
curl --no-progress-meter -i --location "$PERMISSIONS_URL/management/tenants" \
  --request POST \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --header "apiKey: $API_KEY" \
  --data '{
    "id": "default",
    "name": "Default"
  }'

# Create cities
curl --no-progress-meter -i --location "$PERMISSIONS_URL/management/tenants/default/resources/city" \
  --request POST \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --header "apiKey: $API_KEY" \
  --data '{
    "id": "cansas",
    "parent": {
      "id" : "default"
    }
  }'

curl --no-progress-meter -i --location "$PERMISSIONS_URL/management/tenants/default/resources/city" \
  --request POST \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --header "apiKey: $API_KEY" \
  --data '{
    "id": "seattle",
    "parent": {
      "id" : "default"
    }
  }'

# Assign roles to Cansas
curl --no-progress-meter -i --location "$PERMISSIONS_URL/management/tenants/default/resources/city/cansas/members" \
  --request PATCH \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --header "apiKey: $API_KEY" \
  --data '{
    "subjects": {
      "alice": [],
      "linda": ["future-forecast-viewer"]
    }
  }'

# Assign roles to Seattle
curl --no-progress-meter -i --location "$PERMISSIONS_URL/management/tenants/default/resources/city/seattle/members" \
  --request PATCH \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --header "apiKey: $API_KEY" \
  --data '{
    "subjects": {
      "alice": ["current-forecast-viewer"],
      "linda": ["future-forecast-viewer"]
    }
  }'
