#!/bin/bash
# API Testing Script for Update and Delete Operations

# Configuration
TOKEN="5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585"
BASE_URL="https://uitleensysteemfirda.nl/api"
AUTH_HEADER="Authorization: Bearer $TOKEN"

echo "===== TESTING UPDATE AND DELETE OPERATIONS ====="

# We'll use the Test Item we just created (ID 21)
ITEM_ID=21
CATEGORY_ID=9

echo -e "\n1. Testing UPDATE item (PUT /items/$ITEM_ID)"
curl -s -X PUT -H "Content-Type: application/json" -H "$AUTH_HEADER" \
  -d '{"title":"Updated Test Item","description":"This item has been updated","category_id":1,"status":"unavailable","location":"New Test Location","inventory_number":"TEST-001-UPDATED"}' \
  "$BASE_URL/items/$ITEM_ID" | python3 -m json.tool

echo -e "\n2. Testing GET updated item to verify changes"
curl -s -X GET -H "Content-Type: application/json" -H "$AUTH_HEADER" "$BASE_URL/items/$ITEM_ID" | python3 -m json.tool

echo -e "\n3. Testing UPDATE category (PUT /categories/$CATEGORY_ID)"
curl -s -X PUT -H "Content-Type: application/json" -H "$AUTH_HEADER" \
  -d '{"name":"Updated Test Category","description":"This category has been updated"}' \
  "$BASE_URL/categories/$CATEGORY_ID" | python3 -m json.tool

echo -e "\n4. Testing GET categories to verify update"
curl -s -X GET -H "Content-Type: application/json" -H "$AUTH_HEADER" "$BASE_URL/categories" | python3 -m json.tool

echo -e "\n5. Testing DELETE item (DELETE /items/$ITEM_ID)"
curl -s -X DELETE -H "Content-Type: application/json" -H "$AUTH_HEADER" "$BASE_URL/items/$ITEM_ID" | python3 -m json.tool

echo -e "\n6. Testing DELETE category (DELETE /categories/$CATEGORY_ID)"
curl -s -X DELETE -H "Content-Type: application/json" -H "$AUTH_HEADER" "$BASE_URL/categories/$CATEGORY_ID" | python3 -m json.tool

echo -e "\n===== UPDATE AND DELETE TESTING COMPLETED ====="
