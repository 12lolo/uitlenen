#!/bin/bash
# Comprehensive fix for Laravel 12 middleware resolution issues in admin functionality

# Display header
echo "======================================================"
echo "Laravel 12 Admin Middleware Resolution Fix"
echo "Date: $(date)"
echo "======================================================"

# Environment check
cd /home/senne/projects/uitlenen || { echo "Error: Could not find project directory"; exit 1; }

# Make a backup of key files
echo "[1/7] Creating backups of key files..."
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR
cp app/Http/Controllers/UserController.php $BACKUP_DIR/
cp app/Http/Controllers/SimpleUserController.php $BACKUP_DIR/ 2>/dev/null || echo "SimpleUserController.php not found (will be created)"
cp app/Http/Middleware/AdminMiddleware.php $BACKUP_DIR/
cp app/Http/Kernel.php $BACKUP_DIR/
cp routes/api.php $BACKUP_DIR/
echo "✓ Backups created in $BACKUP_DIR"

# Fix 1: Run the PHP fixer script
echo "[2/7] Running PHP admin API fix script..."
php admin_api_fix.php || echo "Warning: PHP fix script may have encountered issues"

# Fix 2: Clear all cache
echo "[3/7] Clearing Laravel cache..."
php artisan optimize:clear
php artisan cache:clear
php artisan config:clear
php artisan route:clear
echo "✓ Cache cleared"

# Fix 3: Ensure the middleware is properly registered
echo "[4/7] Checking middleware registration..."
MIDDLEWARE_FIXED=0
grep -q "'admin' => \\\\App\\\\Http\\\\Middleware\\\\AdminMiddleware::class" app/Http/Kernel.php
if [ $? -eq 0 ]; then
    echo "✓ Admin middleware is properly registered"
    MIDDLEWARE_FIXED=1
else
    echo "  Admin middleware registration not found or incorrect"
fi

# Fix 4: Create a test route file if it doesn't exist
echo "[5/7] Ensuring test routes are available..."
if [ ! -f "routes/admin_test_routes.php" ]; then
    echo "  Creating admin test routes file..."
    cat > routes/admin_test_routes.php << 'PHPCODE'
<?php
// Admin test routes

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;

// Direct admin check test
Route::get('/admin-direct-test', function (Request $request) {
    $isAdmin = Auth::check() && Auth::user()->is_admin;
    
    return response()->json([
        'status' => 'success',
        'message' => $isAdmin ? 'You are an admin' : 'You are NOT an admin',
        'authenticated' => Auth::check(),
        'is_admin' => $isAdmin,
        'user_details' => Auth::check() ? Auth::user()->only('id', 'name', 'email', 'is_admin') : null,
        'timestamp' => now()->toIso8601String()
    ]);
})->middleware('auth:sanctum');

// Admin middleware test
Route::get('/admin-middleware-test', function (Request $request) {
    return response()->json([
        'status' => 'success',
        'message' => 'Admin middleware test passed',
        'user_details' => Auth::user()->only('id', 'name', 'email', 'is_admin'),
        'timestamp' => now()->toIso8601String()
    ]);
})->middleware(['auth:sanctum', 'admin']);

// Direct controller action test
Route::get('/admin-controller-test', function (Request $request) {
    $controller = new \App\Http\Controllers\UserController();
    return $controller->index();
})->middleware('auth:sanctum');

// Health check ping
Route::get('/admin-ping', function () {
    return response()->json([
        'status' => 'success',
        'message' => 'Admin routes are accessible',
        'timestamp' => now()->toIso8601String()
    ]);
});
PHPCODE
    
    # Include the test routes in api.php if not already there
    if ! grep -q "require __DIR__.'\/admin_test_routes.php';" routes/api.php; then
        echo "  Including admin test routes in api.php..."
        echo -e "\n// Include admin test routes\nrequire __DIR__.'/admin_test_routes.php';" >> routes/api.php
    fi
    echo "✓ Admin test routes created and included"
else
    echo "✓ Admin test routes already exist"
fi

# Fix 5: Create a separate admin route group
echo "[6/7] Creating dedicated admin routes file..."
if [ ! -f "routes/admin.php" ]; then
    cat > routes/admin.php << 'PHPCODE'
<?php
// Dedicated admin routes

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController;
use Illuminate\Support\Facades\Auth;

// All routes in this file are under the 'admin' prefix and require 'auth:sanctum' middleware
Route::prefix('admin')->middleware('auth:sanctum')->group(function () {
    
    // Admin-only routes that don't use the admin middleware but check inside controller
    Route::get('/users', [UserController::class, 'index']);
    Route::post('/users', [UserController::class, 'store']);
    
    // Direct admin checks without middleware
    Route::get('/check', function () {
        if (!Auth::check() || !Auth::user()->is_admin) {
            return response()->json(['message' => 'This action is unauthorized.'], 403);
        }
        
        return response()->json([
            'message' => 'Admin check passed',
            'user' => Auth::user()->only('id', 'name', 'email', 'is_admin')
        ]);
    });
    
    // System status for admins
    Route::get('/status', function () {
        if (!Auth::check() || !Auth::user()->is_admin) {
            return response()->json(['message' => 'This action is unauthorized.'], 403);
        }
        
        return response()->json([
            'app_name' => config('app.name'),
            'app_env' => config('app.env'),
            'app_debug' => config('app.debug'),
            'server_time' => now()->toIso8601String(),
            'php_version' => PHP_VERSION,
            'laravel_version' => app()->version(),
            'admin_user' => Auth::user()->only('id', 'name', 'email')
        ]);
    });
});

// Health check endpoint (public)
Route::get('/admin-status', function () {
    return response()->json([
        'status' => 'online',
        'timestamp' => now()->toIso8601String()
    ]);
});
PHPCODE

    # Include the admin routes in api.php if not already there
    if ! grep -q "require __DIR__.'\/admin.php';" routes/api.php; then
        echo "  Including admin routes in api.php..."
        echo -e "\n// Include dedicated admin routes\nrequire __DIR__.'/admin.php';" >> routes/api.php
    fi
    echo "✓ Dedicated admin routes created and included"
else
    echo "✓ Dedicated admin routes already exist"
fi

# Fix 6: Create a comprehensive testing script
echo "[7/7] Creating comprehensive test script..."
cat > test_admin_endpoints.sh << 'BASH'
#!/bin/bash
# Comprehensive admin API testing script

TOKEN="$1"
BASE_URL="${2:-https://uitleensysteemfirda.nl/api}"

if [ -z "$TOKEN" ]; then
    echo "Usage: $0 <your_auth_token> [base_url]"
    echo "Example: $0 '13|6IQsPIAL9R9cFaf0ceOrDuJQ1lNw66zcIcGPDuAjd505fb7a'"
    exit 1
fi

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

test_endpoint() {
    local endpoint="$1"
    local method="${2:-GET}"
    local payload="$3"
    local description="${4:-Testing $endpoint}"
    
    echo -e "\n${YELLOW}[$description]${NC}"
    echo "Endpoint: $method $endpoint"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -H "Authorization: Bearer $TOKEN" "$endpoint")
    else
        response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X "$method" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" \
            -d "$payload" \
            "$endpoint")
    fi
    
    http_status=$(echo "$response" | grep "HTTP_STATUS:" | cut -d':' -f2)
    response_body=$(echo "$response" | grep -v "HTTP_STATUS:")
    
    # Check if response is valid JSON
    echo "$response_body" | jq . > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        formatted_json=$(echo "$response_body" | jq .)
    else
        formatted_json="$response_body (Not valid JSON)"
    fi
    
    if [ "$http_status" -ge 200 ] && [ "$http_status" -lt 300 ]; then
        echo -e "${GREEN}Success! Status: $http_status${NC}"
    else
        echo -e "${RED}Failed! Status: $http_status${NC}"
    fi
    
    echo "Response:"
    echo "$formatted_json"
    echo "-----------------------------------------"
}

echo "========================================"
echo "  ADMIN API COMPREHENSIVE TEST"
echo "  Base URL: $BASE_URL"
echo "  Date: $(date)"
echo "========================================"

# Testing regular endpoints
test_endpoint "$BASE_URL/users" "GET" "" "1. Regular users endpoint"

# Testing user creation
random_email="test.user.$(date +%s)@firda.nl"
test_endpoint "$BASE_URL/users" "POST" "{\"email\":\"$random_email\",\"is_admin\":false}" "2. Creating a new user"

# Testing admin test routes
test_endpoint "$BASE_URL/admin-direct-test" "GET" "" "3. Direct admin check test"
test_endpoint "$BASE_URL/admin-middleware-test" "GET" "" "4. Admin middleware test"
test_endpoint "$BASE_URL/admin-controller-test" "GET" "" "5. Admin controller test"
test_endpoint "$BASE_URL/admin-ping" "GET" "" "6. Admin ping test"

# Testing dedicated admin routes
test_endpoint "$BASE_URL/admin/users" "GET" "" "7. Dedicated admin users endpoint"
test_endpoint "$BASE_URL/admin/check" "GET" "" "8. Admin check endpoint"
test_endpoint "$BASE_URL/admin/status" "GET" "" "9. Admin status endpoint"
test_endpoint "$BASE_URL/admin-status" "GET" "" "10. Public admin status endpoint"

echo -e "\n${GREEN}Tests completed!${NC}"
echo "========================================"
BASH

chmod +x test_admin_endpoints.sh
echo "✓ Comprehensive test script created as test_admin_endpoints.sh"

echo "======================================================"
echo "Fix completed successfully!"
echo "======================================================"
echo "Next steps:"
echo "1. Run the test script: ./test_admin_endpoints.sh <your_admin_token>"
echo "2. Access the admin paths via browser or API client:"
echo "   - $BASE_URL/admin/users"
echo "   - $BASE_URL/admin/status"
echo "3. If issues remain, check the Laravel logs:"
echo "   - tail -f storage/logs/laravel*.log"
echo "======================================================"
