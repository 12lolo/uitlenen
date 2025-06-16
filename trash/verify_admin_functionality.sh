#!/bin/bash

# Admin functionality verification script after Laravel 12 fixes
# This script tests the admin endpoints to ensure they are working correctly

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Define the base URL
BASE_URL="https://uitleensysteemfirda.nl"

# Define the admin token (get this from the login endpoint)
echo -e "${YELLOW}Please login to get an admin token${NC}"
echo "Enter admin email:"
read ADMIN_EMAIL
echo "Enter admin password:"
read -s ADMIN_PASSWORD

echo -e "\n${YELLOW}Attempting to login...${NC}"
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASSWORD\"}")

ADMIN_TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$ADMIN_TOKEN" ]; then
  echo -e "${RED}Failed to get admin token. Response:${NC}"
  echo $LOGIN_RESPONSE
  exit 1
fi

echo -e "${GREEN}Successfully obtained admin token${NC}"

# Test endpoints
function test_endpoint() {
  ENDPOINT=$1
  METHOD=$2
  DATA=$3
  DESC=$4
  
  echo -e "${YELLOW}Testing $DESC...${NC}"
  
  if [ "$METHOD" == "GET" ]; then
    RESPONSE=$(curl -s -X $METHOD "$BASE_URL$ENDPOINT" \
      -H "Authorization: Bearer $ADMIN_TOKEN" \
      -H "Content-Type: application/json")
  else
    RESPONSE=$(curl -s -X $METHOD "$BASE_URL$ENDPOINT" \
      -H "Authorization: Bearer $ADMIN_TOKEN" \
      -H "Content-Type: application/json" \
      -d "$DATA")
  fi
  
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X $METHOD "$BASE_URL$ENDPOINT" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" ${DATA:+-d "$DATA"})
  
  if [ "$HTTP_CODE" == "200" ] || [ "$HTTP_CODE" == "201" ]; then
    echo -e "${GREEN}Success! Status code: $HTTP_CODE${NC}"
    echo "Response preview: ${RESPONSE:0:100}..."
  else
    echo -e "${RED}Failed! Status code: $HTTP_CODE${NC}"
    echo "Response: $RESPONSE"
  fi
  echo ""
}

# Run tests
echo -e "${YELLOW}===== VERIFYING ADMIN FUNCTIONALITY =====${NC}"

# Test health check endpoint
test_endpoint "/api/admin-health-check" "GET" "" "Admin health check"

# Test user listing
test_endpoint "/api/users" "GET" "" "List all users"

# Test user creation
NEW_USER_EMAIL="test$(date +%s)@firda.nl"
test_endpoint "/api/users" "POST" "{\"email\":\"$NEW_USER_EMAIL\",\"is_admin\":false}" "Create new user"

# Test admin gate
test_endpoint "/api/admin-gate-test" "GET" "" "Admin gate test"

echo -e "${YELLOW}===== VERIFICATION COMPLETE =====${NC}"
echo -e "If all tests passed with 200 status codes, the admin functionality is working correctly."
echo -e "Make sure to delete the test user created: $NEW_USER_EMAIL"
