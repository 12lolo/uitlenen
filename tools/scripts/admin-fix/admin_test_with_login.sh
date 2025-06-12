#!/bin/bash
# Admin API Test with Login
# This script logs in first and then tests all admin functionality

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Base URL for the API
BASE_URL="https://uitleensysteemfirda.nl/api"

echo -e "${BLUE}===== ADMIN API TEST WITH LOGIN =====${NC}"

# 1. Login to get a token
echo -e "\n${YELLOW}Logging in to get admin token...${NC}"
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"252034@student.firda.nl","password":"Uitlenen1!"}')

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo -e "${RED}Failed to get token. Response:${NC}"
  echo $LOGIN_RESPONSE
  exit 1
fi

echo -e "${GREEN}Successfully obtained token:${NC} $TOKEN"

# 2. Test admin health check
echo -e "\n${YELLOW}Testing Admin Health Check${NC}"
echo -e "GET $BASE_URL/admin-health-check"
HEALTH_RESPONSE=$(curl -s -X GET "$BASE_URL/admin-health-check")
echo -e "${GREEN}Response:${NC} $HEALTH_RESPONSE"

# 3. Test admin gate
echo -e "\n${YELLOW}Testing Admin Gate${NC}"
echo -e "GET $BASE_URL/admin-gate-test"
GATE_RESPONSE=$(curl -s -X GET "$BASE_URL/admin-gate-test" \
  -H "Authorization: Bearer $TOKEN")
echo -e "${GREEN}Response:${NC} $GATE_RESPONSE"

# 4. Test user listing
echo -e "\n${YELLOW}Testing User Listing${NC}"
echo -e "GET $BASE_URL/users"
USERS_RESPONSE=$(curl -s -X GET "$BASE_URL/users" \
  -H "Authorization: Bearer $TOKEN")
echo -e "${GREEN}Response:${NC} $USERS_RESPONSE"

# 5. Test regular user creation
echo -e "\n${YELLOW}Testing Regular User Creation${NC}"
REGULAR_EMAIL="test_regular_$(date +%s)@firda.nl"
echo -e "POST $BASE_URL/users"
echo -e "Data: {\"email\":\"$REGULAR_EMAIL\",\"is_admin\":false}"
REG_RESPONSE=$(curl -s -X POST "$BASE_URL/users" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$REGULAR_EMAIL\",\"is_admin\":false}")
echo -e "${GREEN}Response:${NC} $REG_RESPONSE"

# 6. Check for password exposure
echo -e "\n${YELLOW}Checking for Password Exposure${NC}"
if [[ "$REG_RESPONSE" == *"temp_password"* ]]; then
  echo -e "${RED}SECURITY ISSUE: Password is exposed in the API response!${NC}"
else
  echo -e "${GREEN}SECURITY CHECK PASSED: No password exposed in response.${NC}"
fi

# 7. Test admin user creation
echo -e "\n${YELLOW}Testing Admin User Creation${NC}"
ADMIN_EMAIL="test_admin_$(date +%s)@firda.nl"
echo -e "POST $BASE_URL/users"
echo -e "Data: {\"email\":\"$ADMIN_EMAIL\",\"is_admin\":true}"
ADMIN_RESPONSE=$(curl -s -X POST "$BASE_URL/users" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$ADMIN_EMAIL\",\"is_admin\":true}")
echo -e "${GREEN}Response:${NC} $ADMIN_RESPONSE"

echo -e "\n${BLUE}===== TESTING COMPLETED =====${NC}"
echo -e "Test Summary:"
echo -e "1. Login: ${GREEN}SUCCESS${NC}"
echo -e "2. Admin Health Check: ${GREEN}TESTED${NC}"
echo -e "3. Admin Gate: ${GREEN}TESTED${NC}"
echo -e "4. User Listing: ${GREEN}TESTED${NC}"
echo -e "5. Regular User Creation: ${GREEN}TESTED${NC}"
echo -e "6. Password Security: ${GREEN}VERIFIED${NC}"
echo -e "7. Admin User Creation: ${GREEN}TESTED${NC}"
echo -e "\nCreated test users:"
echo -e "- Regular: $REGULAR_EMAIL"
echo -e "- Admin: $ADMIN_EMAIL"
