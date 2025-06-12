#!/bin/bash
# Essential files cleanup script for the uitlenen project
# Date: June 11, 2025

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Uitlenen Project Essential Files Cleanup${NC}"
echo -e "${GREEN}Date: $(date)${NC}"
echo -e "${GREEN}=========================================${NC}"

# Create a trash directory rather than deleting files
mkdir -p trash

# List of essential files/directories
ESSENTIAL=(
  "app"
  "bootstrap"
  "config"
  "database"
  "public"
  "resources"
  "routes"
  "storage"
  "tests"
  "vendor"
  ".env"
  ".env.example"
  ".gitignore"
  "artisan"
  "composer.json"
  "composer.lock"
  "package.json"
  "phpunit.xml"
  "README.md"
  "tools"
  "docs"
  "admin_fix_final"
  "admin_fix_final_deployment.zip"
  "admin_api_tester.html"
)

# Count files before cleanup
FILE_COUNT=$(find . -maxdepth 1 -type f | wc -l)
DIR_COUNT=$(find . -maxdepth 1 -type d | grep -v "^\.$" | wc -l)

echo -e "${YELLOW}Found ${FILE_COUNT} files and ${DIR_COUNT} directories at the root level.${NC}"
echo -e "${YELLOW}Moving non-essential files to trash directory...${NC}"

# Move non-essential files to trash
for file in $(find . -maxdepth 1 -type f); do
  basename=$(basename "$file")
  is_essential=0
  
  for essential in "${ESSENTIAL[@]}"; do
    if [ "$basename" == "$essential" ]; then
      is_essential=1
      break
    fi
  done
  
  if [ $is_essential -eq 0 ] && [ "$basename" != "essential_cleanup.sh" ]; then
    echo "Moving $basename to trash/"
    mv "$file" trash/
  fi
done

# Move non-essential directories to trash
for dir in $(find . -maxdepth 1 -type d | grep -v "^\.$"); do
  dirname=$(basename "$dir")
  is_essential=0
  
  for essential in "${ESSENTIAL[@]}"; do
    if [ "$dirname" == "$essential" ]; then
      is_essential=1
      break
    fi
  done
  
  if [ $is_essential -eq 0 ] && [ "$dirname" != "trash" ] && [ "$dirname" != "scripts" ]; then
    echo "Moving directory $dirname to trash/"
    mv "$dir" trash/
  fi
done

# Create a backup of the scripts directory if it exists
if [ -d "scripts" ]; then
  echo -e "${YELLOW}Creating backup of scripts directory...${NC}"
  cp -r scripts trash/scripts_backup
  
  # Create a symlink from tools to scripts for compatibility
  if [ ! -L "scripts" ]; then
    mv scripts tools/scripts
    ln -sf tools/scripts scripts
  fi
fi

# Count files after cleanup
FILE_COUNT_AFTER=$(find . -maxdepth 1 -type f | wc -l)
DIR_COUNT_AFTER=$(find . -maxdepth 1 -type d | grep -v "^\.$" | wc -l)

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Cleanup Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo "Files before: $FILE_COUNT"
echo "Files after: $FILE_COUNT_AFTER"
echo "Directories before: $DIR_COUNT"
echo "Directories after: $DIR_COUNT_AFTER"
echo ""
echo "Non-essential files have been moved to trash/"
echo "You can delete them permanently with: rm -rf trash"
echo -e "${GREEN}=========================================${NC}"
