#!/bin/bash
# Admin Fix Server Deployment Script for Shared Hosting
# Modified to work without sudo in a shared hosting environment

# Configuration - Adjust these paths for your shared hosting environment
APP_DIR="$HOME/domains/uitleensysteemfirda.nl/public_html"
BACKUP_DIR="$HOME/backups/uitlenen_$(date +%Y%m%d_%H%M%S)"
TEMP_DIR="$HOME/admin_fix_deploy_temp"

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

# Copy files to application directory
log_info "Deploying fixed files..."

# Controllers
log_info "Deploying controllers..."
mkdir -p "$APP_DIR/app/Http/Controllers"
cp -p "app/Http/Controllers/UserController.php" "$APP_DIR/app/Http/Controllers/" || log_error "Failed to copy UserController.php"
cp -p "app/Http/Controllers/SimpleUserController.php" "$APP_DIR/app/Http/Controllers/" || log_error "Failed to copy SimpleUserController.php"

# Middleware
log_info "Deploying middleware..."
mkdir -p "$APP_DIR/app/Http/Middleware"
cp -p "app/Http/Middleware/AdminMiddleware.php" "$APP_DIR/app/Http/Middleware/" || log_error "Failed to copy AdminMiddleware.php"

# Routes
log_info "Deploying routes..."
mkdir -p "$APP_DIR/routes"
cp -p "routes/api.php" "$APP_DIR/routes/" || log_error "Failed to copy api.php"
cp -p "routes/admin.php" "$APP_DIR/routes/" || log_error "Failed to copy admin.php"
cp -p "routes/admin_test_routes.php" "$APP_DIR/routes/" || log_error "Failed to copy admin_test_routes.php"
cp -p "routes/auth_check_test.php" "$APP_DIR/routes/" || log_error "Failed to copy auth_check_test.php"
cp -p "routes/comprehensive_admin_fix.php" "$APP_DIR/routes/" || log_error "Failed to copy comprehensive_admin_fix.php"

# Documentation
log_info "Deploying documentation..."
mkdir -p "$APP_DIR/docs"
cp -p "docs/admin_fix_summary.md" "$APP_DIR/docs/" || log_error "Failed to copy admin_fix_summary.md"
cp -p "docs/laravel12_admin_quick_reference.md" "$APP_DIR/docs/" || log_error "Failed to copy laravel12_admin_quick_reference.md"

# Testing tools
log_info "Deploying testing tools..."
mkdir -p "$APP_DIR/public"
cp -p "admin_api_tester.html" "$APP_DIR/public/" || log_error "Failed to copy admin_api_tester.html"

# Verification script
log_info "Deploying verification script..."
cp -p "verify_deployment.sh" "$APP_DIR/" || log_error "Failed to copy verify_deployment.sh"
chmod +x "$APP_DIR/verify_deployment.sh"

# Clear Laravel cache
log_info "Clearing Laravel cache..."
cd "$APP_DIR"
php artisan optimize:clear
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

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
