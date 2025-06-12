#!/bin/bash
# Production deployment verification script
# This script checks that the admin API is working correctly after deployment

echo "Admin API Verification Script"
echo "============================"
echo

# Check if token is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <admin_token>"
    echo "Example: $0 '13|6IQsPIAL9R9cFaf0...'"
    exit 1
fi

TOKEN="$1"
BASE_URL="${2:-https://uitleensysteemfirda.nl/api}"

echo "Testing admin endpoints at $BASE_URL..."
echo

# Test 1: Health check
echo "Test 1: Admin health check"
echo "-------------------------"
curl -s "$BASE_URL/admin-health-check" | jq 2>/dev/null || echo "Failed to parse response"
echo

# Test 2: Get users list
echo "Test 2: Admin users list"
echo "----------------------"
curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/users" | jq 2>/dev/null || echo "Failed to parse response"
echo

# Test 3: Check admin status
echo "Test 3: Admin status check"
echo "------------------------"
curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/admin-status" | jq 2>/dev/null || echo "Failed to parse response"
echo

echo "Verification complete!"
echo "If all tests returned valid JSON responses, the deployment was successful."
echo "If any test failed, please check the Laravel logs for more information."
