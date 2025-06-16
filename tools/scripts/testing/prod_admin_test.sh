#!/bin/bash
# Simple script to test the admin functionality on production
# Run with: ./prod_admin_test.sh your_admin_token

TOKEN="$1"

if [ -z "$TOKEN" ]; then
    echo "Usage: $0 your_admin_token"
    exit 1
fi

echo "Testing admin functionality..."
echo "1. Testing /api/users (main admin endpoint)..."
echo "Response status code:"
curl -s -I -H "Authorization: Bearer $TOKEN" https://uitleensysteemfirda.nl/api/users | head -n 1
echo "Response body:"
curl -s -H "Authorization: Bearer $TOKEN" https://uitleensysteemfirda.nl/api/users

echo -e "\n2. Testing /api/admin-health-check (should always work)..."
echo "Response status code:"
curl -s -I https://uitleensysteemfirda.nl/api/admin-health-check | head -n 1
echo "Response body:"
curl -s https://uitleensysteemfirda.nl/api/admin-health-check

echo -e "\nDone!"
