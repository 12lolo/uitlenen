#!/bin/bash
# Uitleen System API Health Check Script
# This script performs a basic health check on all critical API endpoints
# Run this periodically to ensure the system is functioning correctly

# Configuration
TOKEN=""  # Add your token here when running the script
BASE_URL="https://uitleensysteemfirda.nl/api"
AUTH_HEADER="Authorization: Bearer $TOKEN"
LOG_FILE="api_health_check.log"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to log messages
log_message() {
  local level=$1
  local message=$2
  echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" | tee -a $LOG_FILE
}

# Function to check an endpoint
check_endpoint() {
  local method=$1
  local endpoint=$2
  local description=$3
  local expected_status=$4
  
  log_message "INFO" "Testing: $description"
  
  # Make the request
  response=$(curl -s -w "%{http_code}" -X $method -H "Content-Type: application/json" -H "$AUTH_HEADER" -o /tmp/response.json "$BASE_URL$endpoint")
  status_code=$response
  
  # Check if status code matches expected
  if [ "$status_code" == "$expected_status" ]; then
    log_message "PASS" "${GREEN}✓ $description: Status $status_code${NC}"
    return 0
  else
    log_message "FAIL" "${RED}✗ $description: Expected status $expected_status but got $status_code${NC}"
    cat /tmp/response.json | jq . 2>/dev/null || cat /tmp/response.json
    return 1
  fi
}

# Main health check function
run_health_check() {
  log_message "INFO" "${BLUE}===== UITLEEN SYSTEM API HEALTH CHECK =====${NC}"
  log_message "INFO" "Starting health check at $(date)"
  
  # Initialize counters
  total=0
  passed=0
  
  # Check authentication
  if [ -z "$TOKEN" ]; then
    log_message "WARN" "${YELLOW}No token provided. Authentication tests will be skipped.${NC}"
  else
    total=$((total+1))
    if check_endpoint "GET" "/user" "Authentication" "200"; then
      passed=$((passed+1))
    fi
  fi
  
  # Check public endpoints
  total=$((total+1))
  if check_endpoint "GET" "/categories" "Get Categories" "200"; then
    passed=$((passed+1))
  fi
  
  total=$((total+1))
  if check_endpoint "GET" "/items/1" "Get Item Details" "200"; then
    passed=$((passed+1))
  fi
  
  # Check authenticated endpoints (if token provided)
  if [ ! -z "$TOKEN" ]; then
    total=$((total+1))
    if check_endpoint "GET" "/items" "Get All Items" "200"; then
      passed=$((passed+1))
    fi
    
    total=$((total+1))
    if check_endpoint "GET" "/lendings" "Get All Loans" "200"; then
      passed=$((passed+1))
    fi
    
    total=$((total+1))
    if check_endpoint "GET" "/lendings/status" "Get Loan Status" "200"; then
      passed=$((passed+1))
    fi
    
    total=$((total+1))
    if check_endpoint "GET" "/damages" "Get All Damages" "200"; then
      passed=$((passed+1))
    fi
  fi
  
  # Calculate and report results
  percentage=$((passed * 100 / total))
  if [ $percentage -eq 100 ]; then
    log_message "INFO" "${GREEN}All checks passed! ($passed/$total)${NC}"
  elif [ $percentage -ge 80 ]; then
    log_message "WARN" "${YELLOW}Most checks passed: $passed/$total ($percentage%)${NC}"
  else
    log_message "ERROR" "${RED}Several checks failed: $passed/$total ($percentage%)${NC}"
  fi
  
  log_message "INFO" "Health check completed at $(date)"
  log_message "INFO" "${BLUE}===== HEALTH CHECK COMPLETE =====${NC}"
}

# Run the health check
run_health_check
