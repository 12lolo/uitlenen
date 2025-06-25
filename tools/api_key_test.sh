#!/bin/bash

# API Key Test Script
# This script demonstrates how to call the API endpoints using an API key

# Configuration
API_BASE_URL="http://localhost:8000/api"  # Use localhost for local testing
API_KEY="Ngh3FZoFwQcba0lT01GxA5mg1rT9qH986049evAQYrcGbyRDOGfMOYkNy9G3gll6"  # The API key we just generated

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if API key is provided
if [ -z "$API_KEY" ]; then
  echo -e "${RED}Error: API key is not set. Please generate an API key and add it to this script.${NC}"
  echo "You can generate an API key using: php artisan api:generate-key \"API Test Script\""
  exit 1
fi

# Function to make API calls
call_api() {
  endpoint=$1
  echo -e "\n${BLUE}Calling: ${endpoint}${NC}"
  
  result=$(curl -s -H "X-API-KEY: $API_KEY" "${API_BASE_URL}${endpoint}")
  
  # Check if jq is available for pretty printing JSON
  if command -v jq &> /dev/null; then
    echo -e "${GREEN}Response:${NC}"
    echo $result | jq
  else
    echo -e "${GREEN}Response:${NC} $result"
    echo -e "${BLUE}Tip: Install 'jq' for prettier JSON output${NC}"
  fi
}

# Test the API endpoints
echo -e "${BLUE}Testing API Key Authentication...${NC}"
echo -e "Using API key: ${API_KEY:0:8}... (truncated for security)"

# Get available items
call_api "/items/available"

# Get overdue loans
call_api "/lendings/overdue"

echo -e "\n${GREEN}API testing complete!${NC}"
