#!/bin/bash
# Simple Admin Test with sample token
# Change the TOKEN value to your actual admin token

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Base URL for the API
BASE_URL="https://uitleensysteemfirda.nl/api"

# REPLACE THIS with your actual admin token
# You can get a token by logging in via the API:
# curl -X POST "https://uitleensysteemfirda.nl/api/login" -d '{"email":"your_admin@firda.nl","password":"your_password"}'
TOKEN="7|1ivWKuhiib0o0jH3V3Pebxz2obgsCyPxZEPa114i269dc27b"

echo -e "${BLUE}===== TESTING ADMIN FUNCTIONALITY =====${NC}"

# 1. Test admin health check
echo -e "\n${YELLOW}Testing Admin Health Check${NC}"
echo -e "GET $BASE_URL/admin-health-check"
HEALTH_RESPONSE=$(curl -s -X GET "$BASE_URL/admin-health-check")
echo -e "Response: $HEALTH_RESPONSE"

# 2. Test admin authentication
echo -e "\n${YELLOW}Testing Admin Authentication${NC}"
echo -e "GET $BASE_URL/users"
USERS_RESPONSE=$(curl -s -X GET "$BASE_URL/users" -H "Authorization: Bearer $TOKEN")
echo -e "Response: $USERS_RESPONSE"

# 3. Test regular user creation
echo -e "\n${YELLOW}Testing Regular User Creation${NC}"
REGULAR_EMAIL="test_regular_$(date +%s)@firda.nl"
echo -e "POST $BASE_URL/users"
echo -e "Data: {\"email\":\"$REGULAR_EMAIL\",\"is_admin\":false}"
REG_RESPONSE=$(curl -s -X POST "$BASE_URL/users" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$REGULAR_EMAIL\",\"is_admin\":false}")
echo -e "Response: $REG_RESPONSE"

# 4. Test admin user creation
echo -e "\n${YELLOW}Testing Admin User Creation${NC}"
ADMIN_EMAIL="test_admin_$(date +%s)@firda.nl"
echo -e "POST $BASE_URL/users"
echo -e "Data: {\"email\":\"$ADMIN_EMAIL\",\"is_admin\":true}"
ADMIN_RESPONSE=$(curl -s -X POST "$BASE_URL/users" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$ADMIN_EMAIL\",\"is_admin\":true}")
echo -e "Response: $ADMIN_RESPONSE"

echo -e "\n${BLUE}===== TESTING COMPLETED =====${NC}"
echo -e "Review the responses above to verify admin functionality."
echo -e "Created test users:"
echo -e "- Regular: $REGULAR_EMAIL"
echo -e "- Admin: $ADMIN_EMAIL"
