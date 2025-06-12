#!/bin/bash
# Comprehensive admin API testing script

TOKEN="$1"
BASE_URL="${2:-https://uitleensysteemfirda.nl/api}"

if [ -z "$TOKEN" ]; then
    echo "Usage: $0 <your_auth_token> [base_url]"
    echo "Example: $0 '13|6IQsPIAL9R9cFaf0ceOrDuJQ1lNw66zcIcGPDuAjd505fb7a'"
    exit 1
fi

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

test_endpoint() {
    local endpoint="$1"
    local method="${2:-GET}"
    local payload="$3"
    local description="${4:-Testing $endpoint}"
    
    echo -e "\n${YELLOW}[$description]${NC}"
    echo "Endpoint: $method $endpoint"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -H "Authorization: Bearer $TOKEN" "$endpoint")
    else
        response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X "$method" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" \
            -d "$payload" \
            "$endpoint")
    fi
    
    http_status=$(echo "$response" | grep "HTTP_STATUS:" | cut -d':' -f2)
    response_body=$(echo "$response" | grep -v "HTTP_STATUS:")
    
    # Check if response is valid JSON
    echo "$response_body" | jq . > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        formatted_json=$(echo "$response_body" | jq .)
    else
        formatted_json="$response_body (Not valid JSON)"
    fi
    
    if [ "$http_status" -ge 200 ] && [ "$http_status" -lt 300 ]; then
        echo -e "${GREEN}Success! Status: $http_status${NC}"
    else
        echo -e "${RED}Failed! Status: $http_status${NC}"
    fi
    
    echo "Response:"
    echo "$formatted_json"
    echo "-----------------------------------------"
}

echo "========================================"
echo "  ADMIN API COMPREHENSIVE TEST"
echo "  Base URL: $BASE_URL"
echo "  Date: $(date)"
echo "========================================"

# Testing regular endpoints
test_endpoint "$BASE_URL/users" "GET" "" "1. Regular users endpoint"

# Testing user creation
random_email="test.user.$(date +%s)@firda.nl"
test_endpoint "$BASE_URL/users" "POST" "{\"email\":\"$random_email\",\"is_admin\":false}" "2. Creating a new user"

# Testing admin test routes
test_endpoint "$BASE_URL/admin-direct-test" "GET" "" "3. Direct admin check test"
test_endpoint "$BASE_URL/admin-middleware-test" "GET" "" "4. Admin middleware test"
test_endpoint "$BASE_URL/admin-controller-test" "GET" "" "5. Admin controller test"
test_endpoint "$BASE_URL/admin-ping" "GET" "" "6. Admin ping test"

# Testing dedicated admin routes
test_endpoint "$BASE_URL/admin/users" "GET" "" "7. Dedicated admin users endpoint"
test_endpoint "$BASE_URL/admin/check" "GET" "" "8. Admin check endpoint"
test_endpoint "$BASE_URL/admin/status" "GET" "" "9. Admin status endpoint"
test_endpoint "$BASE_URL/admin-status" "GET" "" "10. Public admin status endpoint"

echo -e "\n${GREEN}Tests completed!${NC}"
echo "========================================"
