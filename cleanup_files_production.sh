#!/bin/bash
# cleanup_files_production.sh
#
# This script removes files and folders that are not needed in a production environment
# It should be run on the production server after deployment
#
# Author: GitHub Copilot
# Date: June 5, 2025

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting production cleanup process...${NC}"

# Check if we're in the right directory (should contain artisan file)
if [ ! -f "artisan" ]; then
    echo -e "${RED}Error: artisan file not found. Are you in the Laravel project root?${NC}"
    exit 1
fi

# Function to safely remove a file or directory if it exists
safe_remove() {
    if [ -e "$1" ]; then
        echo -e "Removing: ${YELLOW}$1${NC}"
        rm -rf "$1"
    fi
}

echo -e "\n${GREEN}Removing development and testing files...${NC}"

# Development environment configuration files
safe_remove ".editorconfig"
safe_remove ".gitattributes"
safe_remove ".gitignore"
safe_remove "vite.config.js"
safe_remove "webpack.mix.js"
safe_remove "phpunit.xml"
safe_remove ".styleci.yml"
safe_remove ".env.example"
safe_remove "tailwind.config.js"
safe_remove "postcss.config.js"
safe_remove "package.json"
safe_remove "package-lock.json"
safe_remove "composer.lock"
safe_remove "yarn.lock"
safe_remove "node_modules"

# Tests directory
safe_remove "tests"

# Documentation
safe_remove "README.md"
safe_remove "CHANGELOG.md"
safe_remove "CONTRIBUTING.md"
safe_remove "LICENSE.md"
safe_remove "documentation"
safe_remove "docs"
safe_remove "*.md"

# IDE and editor files
safe_remove ".idea"
safe_remove ".vscode"
safe_remove "*.sublime-project"
safe_remove "*.sublime-workspace"
safe_remove ".phpstorm.meta.php"
safe_remove "_ide_helper.php"
safe_remove "_ide_helper_models.php"

# Deployment and maintenance scripts not needed in production
safe_remove "*.sh"
safe_remove "deploy"
safe_remove "deployment-include.txt"
safe_remove "scripts_to_remove.md"

# Remove database seeders (not needed in production)
safe_remove "database/seeders"
safe_remove "database/factories"

# Keep the storage structure but clean up unneeded files
find storage/logs -type f -name "*.log" -exec rm {} \;
find bootstrap/cache -type f -exec rm {} \;

echo -e "\n${GREEN}Creating necessary directories and placeholder files...${NC}"

# Create necessary directories that might have been removed
mkdir -p storage/logs
mkdir -p storage/framework/cache
mkdir -p storage/framework/sessions
mkdir -p storage/framework/views
mkdir -p storage/framework/testing
mkdir -p bootstrap/cache

# Create placeholder files to maintain directory structure
touch storage/logs/.gitkeep
touch storage/framework/cache/.gitkeep
touch storage/framework/sessions/.gitkeep
touch storage/framework/views/.gitkeep
touch storage/framework/testing/.gitkeep
touch bootstrap/cache/.gitkeep

# Set proper permissions
echo -e "\n${GREEN}Setting proper permissions...${NC}"
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
chmod 755 artisan

# Make storage and bootstrap/cache writable
chmod -R 775 storage
chmod -R 775 bootstrap/cache

# Remove this script itself at the end
echo -e "\n${GREEN}Cleanup completed!${NC}"
echo -e "${YELLOW}This script will self-delete now...${NC}"

# Uncomment the following line when ready to have the script self-delete
# rm -- "$0"

echo -e "\n${GREEN}Production environment is now clean and optimized.${NC}"
