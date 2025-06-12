#!/bin/bash
# Admin fix deployment verification script
# This script verifies that all files in the deployment package 
# match the files in the production_include.txt list

# Define paths
PACKAGE_ZIP="/home/senne/projects/uitlenen/admin_fix_deployment/admin_fix_deployment.zip"
INCLUDE_FILE="/home/senne/projects/uitlenen/tools/deployment/production_include.txt"
TEMP_DIR="/tmp/admin_fix_verify"

# Create temp directory
mkdir -p "$TEMP_DIR"
rm -rf "$TEMP_DIR/*"

# Extract the zip file
echo "Extracting package..."
unzip -q "$PACKAGE_ZIP" -d "$TEMP_DIR"

# Check for required files
echo "Verifying package contents:"
MISSING_FILES=0

while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip comments and empty lines
    if [[ "$line" =~ ^#.*$ ]] || [[ -z "$line" ]]; then
        continue
    fi
    
    # Check if file exists in package
    if [ -f "$TEMP_DIR/package/$line" ]; then
        echo "✓ $line"
    else
        echo "✗ Missing: $line"
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done < "$INCLUDE_FILE"

# Show summary
echo ""
if [ $MISSING_FILES -eq 0 ]; then
    echo "Verification complete: All required files are in the package."
else
    echo "Verification failed: $MISSING_FILES file(s) are missing from the package."
fi

# Cleanup
rm -rf "$TEMP_DIR"
