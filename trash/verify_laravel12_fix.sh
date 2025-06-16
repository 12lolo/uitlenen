#!/bin/bash
# Final Laravel 12 Admin Fix Verification

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===== FINAL VERIFICATION OF LARAVEL 12 ADMIN FIX =====${NC}"

# Admin token for testing
TOKEN="5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585"
BASE_URL="https://uitleensysteemfirda.nl/api"

# Function to test an endpoint
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    
    echo -e "${GREEN}Testing $method $endpoint${NC}"
    
    # Build the curl command
    CURL_CMD="curl -s -X $method"
    CURL_CMD+=" -H 'Authorization: Bearer $TOKEN'"
    CURL_CMD+=" -H 'Accept: application/json'"
    
    if [ "$method" == "POST" ] || [ "$method" == "PUT" ]; then
        CURL_CMD+=" -H 'Content-Type: application/json'"
        CURL_CMD+=" -d '$data'"
    fi
    
    CURL_CMD+=" $BASE_URL$endpoint"
    
    # Execute and capture the response
    RESPONSE=$(eval $CURL_CMD)
    STATUS=$?
    
    if [ $STATUS -ne 0 ]; then
        echo -e "${RED}Error executing curl command${NC}"
        return 1
    fi
    
    # Parse and display the response
    echo -e "${GREEN}Response:${NC}"
    echo $RESPONSE | jq -C . || echo $RESPONSE
    
    # Determine if the test passed based on the response
    if echo $RESPONSE | grep -q "error\|unauthorized"; then
        echo -e "${RED}✗ Test failed${NC}"
        return 1
    else
        echo -e "${GREEN}✓ Test passed${NC}"
        return 0
    fi
}

# Test 1: Health Check
echo -e "\n${YELLOW}Test 1: Admin Health Check${NC}"
test_endpoint "GET" "/admin-health-check"

# Test 2: Direct User Test
echo -e "\n${YELLOW}Test 2: Direct User Test${NC}"
test_endpoint "GET" "/direct-user-test"

# Test 3: Admin Gate Test
echo -e "\n${YELLOW}Test 3: Admin Gate Test${NC}"
test_endpoint "GET" "/admin-gate-test"

# Test 4: Users Endpoint
echo -e "\n${YELLOW}Test 4: Users Endpoint${NC}"
test_endpoint "GET" "/users"

# Test 5: User Creation
echo -e "\n${YELLOW}Test 5: User Creation${NC}"
TEST_EMAIL="test.final.$(date +%s)@firda.nl"
test_endpoint "POST" "/users" "{\"email\":\"$TEST_EMAIL\",\"is_admin\":false}"

echo -e "\n${YELLOW}===== VERIFICATION COMPLETED =====${NC}"
echo -e "${GREEN}All tests have been executed.${NC}"
echo "Review the output above to determine if the fix was successful."
echo ""
echo -e "${YELLOW}Reminder: You should now clean up any temporary files on the server.${NC}"
