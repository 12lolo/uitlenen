#!/bin/bash
# Admin Fix Server Deployment Script
# Run this script on the production server to deploy the admin fix

# Configuration
APP_DIR="/var/www/uitleensysteemfirda.nl"  # Update this to your actual app directory
BACKUP_DIR="/var/www/backups/uitlenen_$(date +%Y%m%d_%H%M%S)"
PACKAGE_FILE="admin_fix_deployment.zip"
TEMP_DIR="/tmp/admin_fix_temp"

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

# Check if package exists
if [ ! -f "$PACKAGE_FILE" ]; then
    log_error "Deployment package not found: $PACKAGE_FILE"
    exit 1
fi

# Create backup directory
log_info "Creating backup directory: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Backup current files
log_info "Backing up original files..."
cp -p "$APP_DIR/app/Http/Controllers/UserController.php" "$BACKUP_DIR/" 2>/dev/null || log_warn "UserController.php not found"
cp -p "$APP_DIR/app/Http/Controllers/SimpleUserController.php" "$BACKUP_DIR/" 2>/dev/null || log_warn "SimpleUserController.php not found (will be created)"
cp -p "$APP_DIR/app/Http/Middleware/AdminMiddleware.php" "$BACKUP_DIR/" 2>/dev/null || log_warn "AdminMiddleware.php not found"
cp -p "$APP_DIR/routes/api.php" "$BACKUP_DIR/" 2>/dev/null || log_warn "api.php not found"
cp -p "$APP_DIR/routes/admin.php" "$BACKUP_DIR/" 2>/dev/null || log_warn "admin.php not found"

# Create temporary directory
log_info "Creating temporary directory: $TEMP_DIR"
rm -rf "$TEMP_DIR" 2>/dev/null
mkdir -p "$TEMP_DIR"

# Extract deployment package
log_info "Extracting deployment package..."
unzip -q "$PACKAGE_FILE" -d "$TEMP_DIR"

# Copy files to application directory
log_info "Deploying fixed files..."
if [ -d "$TEMP_DIR/app" ]; then
    cp -R "$TEMP_DIR/app/"* "$APP_DIR/app/"
fi

if [ -d "$TEMP_DIR/routes" ]; then
    cp -R "$TEMP_DIR/routes/"* "$APP_DIR/routes/"
fi

if [ -d "$TEMP_DIR/docs" ]; then
    mkdir -p "$APP_DIR/docs"
    cp -R "$TEMP_DIR/docs/"* "$APP_DIR/docs/"
fi

if [ -f "$TEMP_DIR/admin_api_tester.html" ]; then
    cp "$TEMP_DIR/admin_api_tester.html" "$APP_DIR/public/"
fi

if [ -f "$TEMP_DIR/verify_deployment.sh" ]; then
    cp "$TEMP_DIR/verify_deployment.sh" "$APP_DIR/"
    chmod +x "$APP_DIR/verify_deployment.sh"
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

# Clean up
log_info "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

log_info "Deployment completed successfully!"
log_info "Backup created at: $BACKUP_DIR"
log_info "To verify deployment, run: $APP_DIR/verify_deployment.sh YOUR_ADMIN_TOKEN"

# Show post-deployment steps
echo ""
log_info "Post-Deployment Steps:"
echo "1. Verify admin API endpoints are working"
echo "2. Check application logs for any errors"
echo "3. Test admin functionality in the browser"
echo ""
log_info "If you encounter any issues, restore from backup:"
echo "cp -R $BACKUP_DIR/* $APP_DIR/"
echo "cd $APP_DIR && php artisan optimize:clear"
