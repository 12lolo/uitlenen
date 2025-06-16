#!/bin/bash
# Production deployment verification script
# Date: June 11, 2025

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "Production Deployment Verification"
echo "Date: $(date)"
echo "=========================================="

# Default production URL
PROD_URL="${1:-https://uitleensysteemfirda.nl/api}"
TOKEN="$2"

# Check if an admin token is provided for authenticated tests
if [ -z "$TOKEN" ]; then
    echo -e "${YELLOW}Warning: No admin token provided. Will only run public endpoint tests.${NC}"
    echo "For full testing, run with: $0 [prod_url] [admin_token]"
    echo ""
fi

# Function to test an endpoint
test_endpoint() {
    local endpoint="$1"
    local expected_status="$2"
    local description="$3"
    local use_token="${4:-false}"
    
    echo -n "Testing $description... "
    
    if [ "$use_token" = "true" ] && [ -z "$TOKEN" ]; then
        echo -e "${YELLOW}SKIPPED (no token)${NC}"
        return
    fi
    
    if [ "$use_token" = "true" ]; then
        response=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $TOKEN" "$PROD_URL/$endpoint" || echo "ERROR")
    else
        response=$(curl -s -o /dev/null -w "%{http_code}" "$PROD_URL/$endpoint" || echo "ERROR")
    fi
    
    if [ "$response" = "ERROR" ]; then
        echo -e "${RED}FAIL (connection error)${NC}"
    elif [ "$response" = "$expected_status" ]; then
        echo -e "${GREEN}PASS ($response)${NC}"
    else
        echo -e "${RED}FAIL (got $response, expected $expected_status)${NC}"
    fi
}

echo "Running basic availability tests..."
test_endpoint "" 200 "API root"
test_endpoint "categories" 200 "Categories endpoint"

echo -e "\nRunning admin fix verification tests..."
test_endpoint "admin-health-check" 200 "Admin health check endpoint"
test_endpoint "admin-status" 200 "Public admin status endpoint"
test_endpoint "admin-ping" 200 "Admin ping endpoint"

if [ -n "$TOKEN" ]; then
    echo -e "\nRunning authenticated admin tests..."
    test_endpoint "users" 200 "Users endpoint" true
    test_endpoint "admin/users" 200 "Admin users endpoint" true
    test_endpoint "admin-direct-test" 200 "Admin direct test" true
    test_endpoint "admin/check" 200 "Admin check endpoint" true
    test_endpoint "admin/status" 200 "Admin status endpoint" true
    
    echo -e "\nRunning test routes..."
    test_endpoint "auth-check-test" 200 "Auth check test" true
    test_endpoint "admin-controller-test" 200 "Admin controller test" true
fi

echo -e "\n=========================================="
echo "Deployment Status Summary"
echo "=========================================="

if [ -n "$TOKEN" ]; then
    echo "To complete testing with Insomnia or Postman:"
    echo "1. Try creating a new user with:"
    echo "   POST $PROD_URL/users"
    echo "   Headers: Authorization: Bearer $TOKEN"
    echo "   JSON: {\"email\":\"test@firda.nl\",\"is_admin\":false}"
    echo ""
    echo "2. Try the browser-based tester:"
    echo "   Open admin_api_tester.html in your browser"
else
    echo "For complete testing, run again with your admin token:"
    echo "$0 $PROD_URL your_admin_token"
fi

echo -e "\nIf any tests failed, you may need to deploy the fixes to production:"
echo "./final_deployment.sh"
echo "=========================================="
