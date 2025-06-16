#!/bin/bash
# Project cleanup script
# Date: June 11, 2025

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Project Cleanup Script${NC}"
echo -e "${GREEN}Date: $(date)${NC}"
echo -e "${GREEN}=========================================${NC}"

# Backup directories first
echo "[1/4] Creating backup of current state..."
BACKUP_DIR="backups/pre_cleanup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup all shell scripts
find . -maxdepth 1 -name "*.sh" -exec cp {} "$BACKUP_DIR/" \;
echo -e "${GREEN}✓ Backup created at $BACKUP_DIR${NC}"

# Create a list of essential scripts to keep
echo "[2/4] Identifying essential scripts..."
cat > essential_scripts.txt << EOL
final_deployment.sh
organize_project.sh
verify_production.sh
cleanup_project.sh
setup_cron.sh
maintenance.sh
deploy_production.sh
admin_test_with_login.sh
comprehensive_verification.sh
EOL

# Create a list of temporary files that can be removed
echo "[3/4] Identifying temporary files to remove..."
cat > temp_files.txt << EOL
*.log
*.tmp
*.bak
*.swp
*~
._*
EOL

# Find and count temporary files
echo "[4/4] Counting files to clean up..."
TEMP_FILE_COUNT=$(find . -type f -name "*.tmp" -o -name "*.bak" -o -name "*.log" -o -name "*~" -o -name "*.swp" | wc -l)

# Count scripts that are likely temporary
NON_ESSENTIAL_SCRIPTS=$(find . -maxdepth 1 -type f -name "*.sh" | wc -l)
ESSENTIAL_SCRIPTS=$(wc -l < essential_scripts.txt)
NON_ESSENTIAL_SCRIPTS=$((NON_ESSENTIAL_SCRIPTS - ESSENTIAL_SCRIPTS))

echo -e "\n${YELLOW}Files identified for cleanup:${NC}"
echo "- Temporary files: $TEMP_FILE_COUNT"
echo "- Non-essential scripts: $NON_ESSENTIAL_SCRIPTS"

# Ask for confirmation
echo -e "\n${YELLOW}Would you like to:${NC}"
echo "1. Run safe cleanup (moves files to trash folder)"
echo "2. Run complete cleanup (permanently deletes files)"
echo "3. Cancel"
read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        echo "Running safe cleanup..."
        mkdir -p trash
        
        # Move temporary files to trash
        find . -type f -name "*.tmp" -o -name "*.bak" -o -name "*.log" -o -name "*~" -o -name "*.swp" -exec mv {} trash/ \;
        
        # Move non-essential scripts to trash
        while IFS= read -r script; do
            find . -maxdepth 1 -type f -name "$script" -exec cp {} trash/ \;
        done < essential_scripts.txt
        
        echo -e "${GREEN}Safe cleanup completed. Files moved to trash/ directory.${NC}"
        ;;
    2)
        echo "${RED}Running complete cleanup...${NC}"
        
        # Remove temporary files
        find . -type f -name "*.tmp" -o -name "*.bak" -o -name "*.log" -o -name "*~" -o -name "*.swp" -exec rm {} \;
        
        # Keep only essential scripts
        while IFS= read -r script; do
            # Skip the essential scripts
            find . -maxdepth 1 -type f -name "*.sh" ! -name "$script" -exec rm {} \;
        done < essential_scripts.txt
        
        echo -e "${GREEN}Complete cleanup finished. Files permanently deleted.${NC}"
        ;;
    3)
        echo "Cleanup cancelled."
        ;;
    *)
        echo -e "${RED}Invalid choice. Cleanup cancelled.${NC}"
        ;;
esac

# Always cleanup the temporary files we created
rm -f essential_scripts.txt temp_files.txt

echo -e "\n=========================================="
echo "Next steps:"
echo "1. Run the organization script: ./organize_project.sh"
echo "2. Deploy to production if needed: ./final_deployment.sh"
echo "3. Verify production: ./verify_production.sh [your_token]"
echo "=========================================="
