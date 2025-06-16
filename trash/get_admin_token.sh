#!/bin/bash
# Script to login and get an admin token

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Base URL for the API
BASE_URL="https://uitleensysteemfirda.nl/api"

echo -e "${YELLOW}===== ADMIN LOGIN =====${NC}"
echo -e "Enter admin email:"
read ADMIN_EMAIL
echo -e "Enter admin password:"
read -s ADMIN_PASSWORD
echo

echo -e "${YELLOW}Attempting to login...${NC}"
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASSWORD\"}")

# Extract token
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo -e "${RED}Failed to get token. Response:${NC}"
  echo $LOGIN_RESPONSE
  exit 1
fi

echo -e "${GREEN}Successfully obtained token:${NC} $TOKEN"
echo
echo -e "${YELLOW}Use this token to run admin tests:${NC}"
echo -e "./test_admin_functionality.sh $TOKEN"
