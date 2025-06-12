#!/bin/bash
# Test the fixed admin API

TOKEN="$1"
BASE_URL="https://uitleensysteemfirda.nl/api"

if [ -z "$TOKEN" ]; then
    echo "Usage: $0 <your_auth_token>"
    echo "Example: $0 '13|6IQsPIAL9R9cFaf0ceOrDuJQ1lNw66zcIcGPDuAjd505fb7a'"
    exit 1
fi

echo "==============================================="
echo "Testing authentication check..."
echo "==============================================="
curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/auth-check-test" | jq

echo "==============================================="
echo "Testing admin check..."
echo "==============================================="
curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/admin-check-test" | jq

echo "==============================================="
echo "Testing SimpleUserController directly..."
echo "==============================================="
curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/test-user-api" | jq

echo "==============================================="
echo "Testing regular UserController endpoint..."
echo "==============================================="
curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/users" | jq

echo "==============================================="
echo "Testing user creation..."
echo "==============================================="
RANDOM_EMAIL="test.user.$(date +%s)@firda.nl"
curl -s -X POST \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$RANDOM_EMAIL\",\"is_admin\":false}" \
    "$BASE_URL/users" | jq
