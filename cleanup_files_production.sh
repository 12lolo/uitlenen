#!/bin/bash
# Cleanup script for production server
# Removes files that are no longer needed after deployment

echo "Starting production cleanup..."

# Remove the deployment zip file
if [ -f "deploy.zip" ]; then
    echo "Removing deployment zip file..."
    rm deploy.zip
    echo "Deployment zip file removed."
fi

echo "Production cleanup completed successfully."
