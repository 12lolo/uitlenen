#!/bin/bash
# API Testing Script for the Lending System
# This script tests various endpoints of the lending system API

# Configuration
TOKEN="5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585"
BASE_URL="https://uitleensysteemfirda.nl/api"
AUTH_HEADER="Authorization: Bearer $TOKEN"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
  echo -e "\n${BLUE}===== $1 =====${NC}\n"
}

# Function to print test descriptions
print_test() {
  echo -e "${YELLOW}>>> Testing: $1${NC}"
}

# Function to make API requests and display results
make_request() {
  local method=$1
  local endpoint=$2
  local data=$3
  local description=$4

  echo -e "${YELLOW}>>> $description${NC}"
  
  # Add data parameter if provided
  local data_param=""
  if [ ! -z "$data" ]; then
    data_param="-d '$data'"
  fi
  
  # Make the request
  response=$(curl -s -X $method -H "Content-Type: application/json" -H "$AUTH_HEADER" $data_param "$BASE_URL$endpoint")
  
  # Display response
  echo -e "${GREEN}Response:${NC}"
  echo $response | python3 -m json.tool 2>/dev/null || echo $response
  echo ""
}

# 1. Authentication Tests
print_header "AUTHENTICATION TESTS"

print_test "Get current user information"
make_request "GET" "/user" "" "Getting current user information"

# 2. Categories Tests
print_header "CATEGORIES TESTS"

print_test "Get all categories"
make_request "GET" "/categories" "" "Getting all categories"

print_test "Get items in category ID 1 (Electronics)"
make_request "GET" "/categories/1/items" "" "Getting items in Electronics category"

# 3. Items Tests
print_header "ITEMS TESTS"

print_test "Get all items"
make_request "GET" "/items" "" "Getting all items"

print_test "Get specific item (ID: 1)"
make_request "GET" "/items/1" "" "Getting item with ID 1"

# 4. Loans (Lendings) Tests
print_header "LOANS (LENDINGS) TESTS"

print_test "Get all loans"
make_request "GET" "/lendings" "" "Getting all loans"

print_test "Get lending format guide"
make_request "GET" "/lendings/format" "" "Getting lending format guide"

print_test "Get lending status information"
make_request "GET" "/lendings/status" "" "Getting lending status information"

# 5. Damages Tests
print_header "DAMAGES TESTS"

print_test "Get all damages"
make_request "GET" "/damages" "" "Getting all damage reports"

print_test "Get damage report format guide"
make_request "GET" "/items/damage/format" "" "Getting damage report format guide"

# 6. Users Tests (Admin only)
print_header "USERS TESTS (ADMIN ONLY)"

print_test "Get all users"
make_request "GET" "/users" "" "Getting all users (admin only)"

print_test "Get user format guide"
make_request "GET" "/users/format" "" "Getting user format guide"

# 7. Notifications Tests
print_header "NOTIFICATIONS TESTS"

print_test "Get notifications format guide"
make_request "GET" "/notifications/send-reminders/format" "" "Getting notifications format guide"

# Done
print_header "API TESTING COMPLETED"
echo -e "${GREEN}All API endpoints have been tested.${NC}"
