#!/bin/bash

# Cleanup script for Uitleensysteem project
# Created: June 16, 2025
# This script removes unnecessary testing files and scripts that are no longer needed

echo "Starting cleanup of unnecessary files..."
echo "Creating backup of project files before deletion..."

# Create backup directory
BACKUP_DIR="/home/senne/projects/uitlenen/backup_before_cleanup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Files to delete - these are temporary testing files that are no longer needed
FILES_TO_DELETE=(
  "admin_api_tester.html"
  "admin_test_console.html"
  "admin_fix_final_deployment.zip"
  "admin_verify_web.php"
  "create_item_test.html"
  "direct_admin_test.php"
  "improved_verify_server_fix.php"
  "local_admin_test.php"
  "t, fetch the remote repository"
  "ter"
  "test_admin.php"
  "test_admin_api.php"
  "test_admin_fix.php"
  "test_admin_functionality.sh"
  "test_admin_middleware.php"
  "test_admin_routes.php"
  "test_create_item.php"
  "test_damages.php"
  "test_direct_route.php"
  "test_loans.php"
  "test_local_admin.php"
  "test_middleware_resolution.php"
  "test_simple_admin.php"
  "test_update_delete.php"
  "admin_test_with_login.sh"
  "advanced_api_test.sh"
  "comprehensive_verification.sh"
  "prod_admin_test.sh"
  "quick_admin_test.sh"
  "simple_api_test.sh"
  "simple_test.sh"
  "test_admin_api_fixed.sh"
  "test_api_endpoints.sh"
  "test_update_delete.sh"
)

# Backup and delete files
for file in "${FILES_TO_DELETE[@]}"; do
  if [ -f "$file" ]; then
    echo "Backing up: $file"
    cp "$file" "$BACKUP_DIR/"
    echo "Removing: $file"
    rm "$file"
  else
    echo "File not found, skipping: $file"
  fi
done

# Remove redundant scripts that are not needed for a working system
REDUNDANT_SCRIPTS=(
  "admin_fix_verify.php"
  "apply_admin_fix.php"
  "check_production.sh"
  "cleanup_files_production.sh"
  "cleanup_production.sh"
  "complete_admin_fix_deployment.sh"
  "comprehensive_admin_fix.sh"
  "create_laravel12_fix_package.sh"
  "deploy_admin_fix.sh"
  "deploy_final_admin_fix.sh"
  "deploy_laravel12_fix.sh"
  "final_admin_fix_production.sh"
  "final_admin_route_fix.sh"
  "final_auth_provider_fix.sh"
  "final_check.sh"
  "final_fix.sh"
  "final_middleware_fix.sh"
  "fix_laravel12_admin_middleware.sh"
  "fix_production.sh"
  "fix_sessions.sh"
  "fixed_admin_deployment.sh"
  "get_admin_token.sh"
  "laravel12_middleware_fix.sh"
  "laravel12_route_fix.sh"
  "simple_deploy_admin_fix.sh"
)

# Backup and delete redundant scripts
for script in "${REDUNDANT_SCRIPTS[@]}"; do
  if [ -f "$script" ]; then
    echo "Backing up: $script"
    cp "$script" "$BACKUP_DIR/"
    echo "Removing: $script"
    rm "$script"
  else
    echo "Script not found, skipping: $script"
  fi
done

echo "Cleanup complete. All deleted files have been backed up to: $BACKUP_DIR"
echo "If you need any of these files in the future, you can restore them from the backup."

# Create a list of preserved essential scripts
PRESERVED_SCRIPTS=(
  "api_health_check.sh"
  "deploy.sh"
  "deploy_production.sh"
  "server_setup.sh"
  "setup_cron.sh"
  "maintenance.sh"
  "seed_production.sh"
)

echo -e "\nPreserved essential scripts:"
for script in "${PRESERVED_SCRIPTS[@]}"; do
  if [ -f "$script" ]; then
    echo "- $script"
  fi
done

echo -e "\nConsider organizing remaining scripts using the plan in cleanup_plan.md"
