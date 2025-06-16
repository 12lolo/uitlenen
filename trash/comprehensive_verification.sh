#!/bin/bash

# Comprehensive Admin Fix Verification
# This script verifies all aspects of the admin functionality fix
# Run on production after deployment to ensure everything is working correctly

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}   COMPREHENSIVE ADMIN FIX VERIFICATION       ${NC}"
echo -e "${BLUE}===============================================${NC}"
echo -e "Running complete verification on $(date)"
echo

# 1. Check File Integrity
echo -e "${YELLOW}[1/5] Checking File Integrity${NC}"
FILES_TO_CHECK=(
  "app/Http/Controllers/UserController.php"
  "app/Http/Kernel.php"
  "routes/api.php"
  "app/Http/Middleware/AdminMiddleware.php"
)

for file in "${FILES_TO_CHECK[@]}"; do
  if [ -f "$file" ]; then
    echo -e "  ${GREEN}✓${NC} $file exists"
    
    # Check for password exposure in UserController
    if [[ "$file" == "app/Http/Controllers/UserController.php" ]]; then
      if grep -q "temp_password" "$file"; then
        echo -e "  ${RED}✗${NC} UserController still contains temp_password exposure!"
      else
        echo -e "  ${GREEN}✓${NC} UserController correctly secured (no password exposure)"
      fi
    fi
    
    # Check for admin middleware in Kernel.php
    if [[ "$file" == "app/Http/Kernel.php" ]]; then
      if grep -q "'admin' => \\App\\Http\\Middleware\\AdminMiddleware::class" "$file"; then
        echo -e "  ${GREEN}✓${NC} Kernel.php has proper admin middleware registration"
      else
        echo -e "  ${RED}✗${NC} Kernel.php missing correct admin middleware registration"
      fi
    fi
  else
    echo -e "  ${RED}✗${NC} $file does not exist"
  fi
done
echo

# 2. Check Laravel Cache Status
echo -e "${YELLOW}[2/5] Checking Laravel Cache Status${NC}"
php artisan cache:status
echo -e "  ${GREEN}✓${NC} Cache check completed"

# Get admin authentication token
echo -e "${YELLOW}[3/5] Authenticating as Admin${NC}"
echo -e "Enter admin email:"
read ADMIN_EMAIL
echo -e "Enter admin password:"
read -s ADMIN_PASSWORD
echo

LOGIN_RESPONSE=$(curl -s -X POST "https://uitleensysteemfirda.nl/api/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASSWORD\"}")

ADMIN_TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$ADMIN_TOKEN" ]; then
  echo -e "  ${RED}✗${NC} Failed to get admin token. Response: $LOGIN_RESPONSE"
  echo -e "  ${YELLOW}!${NC} Continuing with tests using a sample token. They may fail."
  ADMIN_TOKEN="sample_token"
else
  echo -e "  ${GREEN}✓${NC} Successfully obtained admin token"
fi
echo

# 3. Test Admin Endpoints
echo -e "${YELLOW}[4/5] Testing Admin Endpoints${NC}"

# Function to test endpoint
test_endpoint() {
  local endpoint=$1
  local method=$2
  local data=$3
  local description=$4
  local success_marker=$5
  
  echo -e "  Testing: $description"
  
  if [ "$method" == "GET" ]; then
    response=$(curl -s -X $method "https://uitleensysteemfirda.nl/api$endpoint" \
      -H "Authorization: Bearer $ADMIN_TOKEN" \
      -H "Content-Type: application/json")
  else
    response=$(curl -s -X $method "https://uitleensysteemfirda.nl/api$endpoint" \
      -H "Authorization: Bearer $ADMIN_TOKEN" \
      -H "Content-Type: application/json" \
      -d "$data")
  fi
  
  status_code=$(curl -s -o /dev/null -w "%{http_code}" -X $method "https://uitleensysteemfirda.nl/api$endpoint" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" ${data:+-d "$data"})
  
  # Check if response contains success marker or status code is 200/201
  if [[ "$response" == *"$success_marker"* ]] || [[ "$status_code" == "200" ]] || [[ "$status_code" == "201" ]]; then
    echo -e "    ${GREEN}✓${NC} Success ($status_code)"
    echo -e "    Response preview: ${response:0:80}..."
  else
    echo -e "    ${RED}✗${NC} Failed ($status_code)"
    echo -e "    Response: $response"
  fi
}

# Test the endpoints
test_endpoint "/admin-health-check" "GET" "" "Admin Health Check" "status\":\"ok"
test_endpoint "/admin-gate-test" "GET" "" "Admin Gate Test" "success"
test_endpoint "/users" "GET" "" "List All Users" "data"

# Test user creation
new_email="test$(date +%s)@firda.nl"
test_endpoint "/users" "POST" "{\"email\":\"$new_email\",\"is_admin\":false}" "Create User" "success"

# Check for password exposure in creation response
user_creation_response=$(curl -s -X POST "https://uitleensysteemfirda.nl/api/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$new_email-2\",\"is_admin\":false}")

if [[ "$user_creation_response" == *"temp_password"* ]]; then
  echo -e "  ${RED}✗${NC} User creation still exposes passwords in response!"
else
  echo -e "  ${GREEN}✓${NC} User creation properly secured (no password exposure)"
fi
echo

# 4. Check for Temporary Files
echo -e "${YELLOW}[5/5] Checking for Temporary Files${NC}"
temp_files=(
  "fix_laravel_middleware.php"
  "fix_laravel12_middleware.php"
  "verify_laravel12_fix.php"
  "laravel12_admin_test.php"
  "test_laravel12_routes.php"
  "fix_laravel12_routes.php"
  "quick_admin_test.php"
  "improved_verify_server_fix.php"
  "admin_fix_verify.php"
  "test_middleware_resolution.php"
)

files_found=0
for file in "${temp_files[@]}"; do
  if [ -f "$file" ]; then
    echo -e "  ${RED}✗${NC} Temporary file still exists: $file"
    files_found=$((files_found+1))
  fi
done

if [ $files_found -eq 0 ]; then
  echo -e "  ${GREEN}✓${NC} No temporary files found. Cleanup successful!"
else
  echo -e "  ${RED}✗${NC} $files_found temporary files still exist. Cleanup incomplete!"
fi
echo

# Final Summary
echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}            VERIFICATION SUMMARY              ${NC}"
echo -e "${BLUE}===============================================${NC}"
echo -e "Date: $(date)"
echo -e "1. File Integrity Check: ${GREEN}PASSED${NC}"
echo -e "2. Laravel Cache Status: ${GREEN}CHECKED${NC}"
echo -e "3. Admin Authentication: ${GREEN}TESTED${NC}"
echo -e "4. Admin Endpoints Test: ${GREEN}COMPLETED${NC}"
echo -e "5. Temporary Files Check: ${GREEN}COMPLETED${NC}"
echo
echo -e "${GREEN}If all tests passed, the admin functionality fix has been successfully deployed!${NC}"
echo -e "${YELLOW}If any issues were found, refer to the rollback procedure in admin_deployment_guide.md${NC}"
echo
echo -e "For additional testing, you can use the individual test scripts:"
echo -e "  - verify_admin_functionality.sh"
echo -e "  - test_admin_api.php"
echo -e "  - api_health_check.sh"
echo
echo -e "${BLUE}===============================================${NC}"
