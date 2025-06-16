#!/bin/bash
# Simple Admin Test

# Login first
echo "Logging in..."
LOGIN_RESPONSE=$(curl -s -X POST "https://uitleensysteemfirda.nl/api/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"252034@student.firda.nl","password":"Uitlenen1!"}')

echo "Login response: $LOGIN_RESPONSE"

# Extract token
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
echo "Token: $TOKEN"

# Test health check
echo -e "\nTesting health check..."
HEALTH_RESPONSE=$(curl -s "https://uitleensysteemfirda.nl/api/admin-health-check")
echo "Health response: $HEALTH_RESPONSE"

# Test user listing
echo -e "\nTesting user listing..."
USERS_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "https://uitleensysteemfirda.nl/api/users")
echo "Users response: $USERS_RESPONSE"

# Test user creation
echo -e "\nTesting user creation..."
USER_RESPONSE=$(curl -s -X POST "https://uitleensysteemfirda.nl/api/users" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"email":"test_user@firda.nl","is_admin":false}')
echo "User creation response: $USER_RESPONSE"
