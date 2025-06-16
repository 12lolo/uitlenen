#!/bin/bash
# Admin Fix Rollback Script
# Run this script to rollback the admin fix deployment if issues occur

# Configuration
APP_DIR="/var/www/uitleensysteemfirda.nl"  # Update this to your actual app directory
BACKUP_DIR="$1"  # Pass the backup directory as an argument

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root or with sudo
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root or with sudo"
   exit 1
fi

# Check if backup directory is provided
if [ -z "$BACKUP_DIR" ]; then
    log_error "Backup directory must be provided"
    echo "Usage: $0 /path/to/backup/directory"
    exit 1
fi

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    log_error "Backup directory not found: $BACKUP_DIR"
    exit 1
fi

# Confirm rollback
echo ""
log_warn "WARNING: This will rollback the admin fix to the previous version"
log_warn "All changes made since the backup will be lost"
echo ""
read -p "Are you sure you want to continue? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Rollback cancelled"
    exit 0
fi

# Restore files from backup
log_info "Restoring files from backup: $BACKUP_DIR"

if [ -f "$BACKUP_DIR/UserController.php" ]; then
    cp -p "$BACKUP_DIR/UserController.php" "$APP_DIR/app/Http/Controllers/" || log_error "Failed to restore UserController.php"
fi

if [ -f "$BACKUP_DIR/AdminMiddleware.php" ]; then
    cp -p "$BACKUP_DIR/AdminMiddleware.php" "$APP_DIR/app/Http/Middleware/" || log_error "Failed to restore AdminMiddleware.php"
fi

if [ -f "$BACKUP_DIR/api.php" ]; then
    cp -p "$BACKUP_DIR/api.php" "$APP_DIR/routes/" || log_error "Failed to restore api.php"
fi

if [ -f "$BACKUP_DIR/admin.php" ]; then
    cp -p "$BACKUP_DIR/admin.php" "$APP_DIR/routes/" || log_error "Failed to restore admin.php"
fi

# Remove SimpleUserController if it didn't exist before
if [ ! -f "$BACKUP_DIR/SimpleUserController.php" ]; then
    log_info "Removing SimpleUserController.php (it did not exist in the backup)"
    rm -f "$APP_DIR/app/Http/Controllers/SimpleUserController.php"
fi

# Clear Laravel cache
log_info "Clearing Laravel cache..."
cd "$APP_DIR"
php artisan optimize:clear
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Fix permissions
log_info "Fixing file permissions..."
find "$APP_DIR/app" -type f -exec chmod 644 {} \;
find "$APP_DIR/routes" -type f -exec chmod 644 {} \;
chown -R www-data:www-data "$APP_DIR/app" "$APP_DIR/routes"

log_info "Rollback completed successfully!"
log_info "The application has been restored to its state before the admin fix deployment"
echo ""
log_info "Post-Rollback Steps:"
echo "1. Verify that the application is functioning properly"
echo "2. Check application logs for any errors"
echo "3. Report the rollback to the development team"
