#!/bin/bash
# Script to create a focused deployment package for the admin fix

# Define paths
SOURCE_DIR="/home/senne/projects/uitlenen"
PACKAGE_DIR="/home/senne/projects/uitlenen/admin_fix_deployment/package"
INCLUDE_FILE="/home/senne/projects/uitlenen/tools/deployment/production_include.txt"

# Create package directory
mkdir -p "$PACKAGE_DIR"

# Read files from include list and copy them to package
while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip comments and empty lines
    if [[ "$line" =~ ^#.*$ ]] || [[ -z "$line" ]]; then
        continue
    fi
    
    # Create directory structure
    mkdir -p "$PACKAGE_DIR/$(dirname "$line")"
    
    # Copy file
    if [ -f "$SOURCE_DIR/$line" ]; then
        echo "Copying $line"
        cp "$SOURCE_DIR/$line" "$PACKAGE_DIR/$line"
    else
        echo "Warning: File not found - $line"
    fi
done < "$INCLUDE_FILE"

# Create README with instructions
cat > "$PACKAGE_DIR/README.md" << 'EOF'
# Admin Fix Deployment Package

This package contains the essential files needed to fix the admin functionality issues in the Laravel 12 "uitlenen" application.

## Deployment Instructions

1. Backup the original files before replacing them.
2. Copy each file to its corresponding location in your Laravel application.
3. Run the post-deployment script to clear the Laravel cache.
4. Use the verification script to confirm the fix is working.

For detailed instructions, see `DEPLOY_INSTRUCTIONS.md`.
EOF

# Copy the DEPLOY_INSTRUCTIONS.md
cp "$SOURCE_DIR/admin_fix_final/DEPLOY_INSTRUCTIONS.md" "$PACKAGE_DIR/"

# Create a zip package
cd "$PACKAGE_DIR/.."
zip -r admin_fix_deployment.zip package/*

echo "Deployment package created at: $PACKAGE_DIR/../admin_fix_deployment.zip"
echo "Package contents:"
find "$PACKAGE_DIR" -type f | sort
