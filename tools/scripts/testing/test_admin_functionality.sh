#!/bin/bash
# Admin Functionality Test Script
# This script tests all admin-related functionality including user creation

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Base URL for the API
BASE_URL="https://uitleensysteemfirda.nl/api"
# TOKEN should be provided as an argument to the script
TOKEN="$1"

if [ -z "$TOKEN" ]; then
  echo -e "${RED}Please provide an admin token as the first argument${NC}"
  echo -e "Usage: $0 <admin-token>"
  exit 1
fi

echo -e "${YELLOW}===== TESTING ADMIN FUNCTIONALITY =====${NC}"

# Function to test an endpoint
test_endpoint() {
  local method=$1
  local endpoint=$2
  local data=$3
  local description=$4
  
  echo -e "\n${YELLOW}Testing: $description${NC}"
  echo -e "Endpoint: $method $endpoint"
  
  if [ "$method" == "GET" ]; then
    response=$(curl -s -X GET "$BASE_URL$endpoint" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json")
    
    status=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$BASE_URL$endpoint" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json")
  else
    echo -e "Data: $data"
    response=$(curl -s -X $method "$BASE_URL$endpoint" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d "$data")
    
    status=$(curl -s -o /dev/null -w "%{http_code}" -X $method "$BASE_URL$endpoint" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d "$data")
  fi
  
  if [ "$status" == "200" ] || [ "$status" == "201" ]; then
    echo -e "${GREEN}Success! Status: $status${NC}"
    echo -e "Response: $response"
  else
    echo -e "${RED}Failed! Status: $status${NC}"
    echo -e "Response: $response"
  fi
}

# 1. Test admin health check
test_endpoint "GET" "/admin-health-check" "" "Admin Health Check"

# 2. Test admin gate
test_endpoint "GET" "/admin-gate-test" "" "Admin Gate Test"

# 3. Test listing users
test_endpoint "GET" "/users" "" "List All Users"

# 4. Test creating a regular user
test_endpoint "POST" "/users" "{\"email\":\"test_regular_$(date +%s)@firda.nl\",\"is_admin\":false}" "Create Regular User"

# 5. Test creating an admin user
test_endpoint "POST" "/users" "{\"email\":\"test_admin_$(date +%s)@firda.nl\",\"is_admin\":true}" "Create Admin User"

# 6. Test password display (should not show)
echo -e "\n${YELLOW}Checking for password exposure in response${NC}"
create_response=$(curl -s -X POST "$BASE_URL/users" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"password_test_$(date +%s)@firda.nl\",\"is_admin\":false}")

if [[ "$create_response" == *"temp_password"* ]]; then
  echo -e "${RED}✗ FAIL: User creation still exposes passwords in response!${NC}"
  echo -e "Response: $create_response"
else
  echo -e "${GREEN}✓ PASS: User creation properly secured (no password exposure)${NC}"
  echo -e "Response: $create_response"
fi

echo -e "\n${YELLOW}===== ADMIN TESTING COMPLETED =====${NC}"
echo -e "All admin functionality has been tested."
echo -e "Check the results above to verify each functionality is working correctly."
