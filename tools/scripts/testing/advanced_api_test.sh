#!/bin/bash
# Advanced API Testing Script for the Lending System
# This script tests various endpoints of the lending system API including POST, PUT and DELETE methods

# Configuration
TOKEN="5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585"
BASE_URL="https://uitleensysteemfirda.nl/api"
AUTH_HEADER="Authorization: Bearer $TOKEN"

# Set the display width for curl output
export COLUMNS=120

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
  
  # Make the request
  if [ ! -z "$data" ]; then
    response=$(curl -s -X $method -H "Content-Type: application/json" -H "$AUTH_HEADER" -d "$data" "$BASE_URL$endpoint")
  else
    response=$(curl -s -X $method -H "Content-Type: application/json" -H "$AUTH_HEADER" "$BASE_URL$endpoint")
  fi
  
  # Display response
  echo -e "${GREEN}Response:${NC}"
  echo $response | python3 -m json.tool 2>/dev/null || echo $response
  echo ""
  
  # Return the response for further processing
  echo "$response"
}

# 1. Authentication Tests
print_header "AUTHENTICATION TESTS"

print_test "Get current user information"
make_request "GET" "/user" "" "Getting current user information"

# 2. Categories Tests
print_header "CATEGORIES TESTS"

print_test "Get all categories"
categories_response=$(make_request "GET" "/categories" "" "Getting all categories")

print_test "Create a new test category"
new_category_response=$(make_request "POST" "/categories" '{"name":"Test Category","description":"A category created for testing purposes"}' "Creating a new test category")

# Extract category ID from response for later use
new_category_id=$(echo $new_category_response | grep -o '"id":[0-9]*' | head -1 | cut -d ":" -f2)

if [ ! -z "$new_category_id" ]; then
  print_test "Update the test category"
  make_request "PUT" "/categories/$new_category_id" '{"name":"Updated Test Category","description":"This category has been updated"}' "Updating the test category"

  print_test "Get items in the test category"
  make_request "GET" "/categories/$new_category_id/items" "" "Getting items in the test category"

  print_test "Delete the test category (may fail if it has items)"
  make_request "DELETE" "/categories/$new_category_id" "" "Deleting the test category"
else
  echo -e "${RED}Failed to extract category ID. Skipping category update and delete tests.${NC}"
fi

# 3. Items Tests
print_header "ITEMS TESTS"

print_test "Get all items"
items_response=$(make_request "GET" "/items" "" "Getting all items")

print_test "Create a new test item"
new_item_response=$(make_request "POST" "/items" '{"title":"Test Item","description":"An item created for testing purposes","category_id":1,"status":"available","location":"Test Location","inventory_number":"TEST-001"}' "Creating a new test item")

# Extract item ID from response for later use
new_item_id=$(echo $new_item_response | grep -o '"id":[0-9]*' | head -1 | cut -d ":" -f2)

if [ ! -z "$new_item_id" ]; then
  print_test "Get the test item"
  make_request "GET" "/items/$new_item_id" "" "Getting the test item"

  print_test "Update the test item"
  make_request "PUT" "/items/$new_item_id" '{"title":"Updated Test Item","description":"This item has been updated","category_id":1,"status":"unavailable","location":"New Test Location","inventory_number":"TEST-001-UPDATED"}' "Updating the test item"

  print_test "Create a damage report for the test item"
  make_request "POST" "/items/$new_item_id/damage" '{"description":"Test damage report","severity":"minor","student_email":"test@student.firda.nl"}' "Creating a damage report for the test item"

  print_test "Delete the test item (may fail if it has loans or damages)"
  make_request "DELETE" "/items/$new_item_id" "" "Deleting the test item"
else
  echo -e "${RED}Failed to extract item ID. Skipping item update and delete tests.${NC}"
fi

# 4. Loans (Lendings) Tests
print_header "LOANS (LENDINGS) TESTS"

print_test "Get all loans"
make_request "GET" "/lendings" "" "Getting all loans"

print_test "Get lending format guide"
make_request "GET" "/lendings/format" "" "Getting lending format guide"

print_test "Create a new test loan (using item ID 2)"
new_loan_response=$(make_request "POST" "/lendings" '{"item_id":2,"due_date":"2025-06-30","notes":"Test loan"}' "Creating a new test loan")

# Extract loan ID from response for later use
new_loan_id=$(echo $new_loan_response | grep -o '"id":[0-9]*' | head -1 | cut -d ":" -f2)

if [ ! -z "$new_loan_id" ]; then
  print_test "Return the test loan"
  make_request "POST" "/lendings/$new_loan_id/return" '{"condition":"good","notes":"Returned during testing"}' "Returning the test loan"
else
  echo -e "${RED}Failed to extract loan ID. Skipping loan return test.${NC}"
fi

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

print_test "Create a new test user"
new_user_response=$(make_request "POST" "/users" '{"email":"testuser@firda.nl","is_admin":false}' "Creating a new test user")

# Done
print_header "API TESTING COMPLETED"
echo -e "${GREEN}All API endpoints have been tested.${NC}"
