#!/bin/bash
# Simple API Testing Script for the Lending System

# Configuration
TOKEN="5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585"
BASE_URL="https://uitleensysteemfirda.nl/api"
AUTH_HEADER="Authorization: Bearer $TOKEN"

echo "===== TESTING KEY API ENDPOINTS ====="

echo -e "\n1. Testing authentication (GET /user)"
curl -s -X GET -H "Content-Type: application/json" -H "$AUTH_HEADER" "$BASE_URL/user" | python3 -m json.tool

echo -e "\n2. Testing GET categories"
curl -s -X GET -H "Content-Type: application/json" -H "$AUTH_HEADER" "$BASE_URL/categories" | python3 -m json.tool

echo -e "\n3. Testing POST new category"
curl -s -X POST -H "Content-Type: application/json" -H "$AUTH_HEADER" \
  -d '{"name":"Test Category","description":"A category created for testing purposes"}' \
  "$BASE_URL/categories" | python3 -m json.tool

echo -e "\n4. Testing GET items"
curl -s -X GET -H "Content-Type: application/json" -H "$AUTH_HEADER" "$BASE_URL/items" | python3 -m json.tool

echo -e "\n5. Testing POST new item"
curl -s -X POST -H "Content-Type: application/json" -H "$AUTH_HEADER" \
  -d '{"title":"Test Item","description":"An item created for testing purposes","category_id":1,"status":"available","location":"Test Location","inventory_number":"TEST-001"}' \
  "$BASE_URL/items" | python3 -m json.tool

echo -e "\n===== TESTING COMPLETED ====="
