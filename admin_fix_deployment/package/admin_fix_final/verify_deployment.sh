#!/bin/bash
# Admin fix verification script

TOKEN="$1"
BASE_URL="$2"

if [ -z "$TOKEN" ]; then
  echo "Usage: $0 your_admin_token [base_url]"
  echo "Example: $0 13|6IQsPIAL9R9cFaf0... https://yourdomain.com/api"
  exit 1
fi

if [ -z "$BASE_URL" ]; then
  BASE_URL="https://uitleensysteemfirda.nl/api"
fi

echo "Testing admin endpoints at $BASE_URL..."
echo "1. Testing admin health check endpoint..."
curl -s $BASE_URL/admin-health-check

echo -e "\n\n2. Testing users endpoint with admin token..."
curl -s -H "Authorization: Bearer $TOKEN" $BASE_URL/users

echo -e "\n\nDone!"
