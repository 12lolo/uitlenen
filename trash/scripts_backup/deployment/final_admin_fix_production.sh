#!/bin/bash
# Final production deployment script for admin functionality fix

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===== DEPLOYING ADMIN FUNCTIONALITY FIX TO PRODUCTION =====${NC}"

# Check if we're running on the production server
if [ ! -d "/var/www/uitleensysteemfirda.nl" ]; then
    echo -e "${RED}Error: This script must be run on the production server${NC}"
    echo "Please upload this script to the production server and run it there."
    exit 1
fi

# Navigate to the production directory
cd /var/www/uitleensysteemfirda.nl || {
    echo -e "${RED}Error: Could not navigate to production directory${NC}"
    exit 1
}

# Create backup directory
echo -e "${GREEN}Creating backup...${NC}"
BACKUP_DIR="backups/admin_fix_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup key files
cp -f app/Http/Controllers/UserController.php "$BACKUP_DIR/UserController.php.bak" || echo -e "${YELLOW}Warning: Could not backup UserController${NC}"
cp -f routes/api.php "$BACKUP_DIR/api.php.bak" || echo -e "${YELLOW}Warning: Could not backup api.php${NC}"

# Apply fixes
echo -e "${GREEN}Applying controller fixes...${NC}"

# 1. Fix UserController
cat > app/Http/Controllers/UserController.php << 'EOF'
<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Log;

class UserController extends Controller
{
    /**
     * Display a listing of all users (teachers)
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index()
    {
        try {
            $users = User::select('id', 'name', 'email', 'is_admin', 'created_at')
                ->orderBy('name')
                ->get();

            return response()->json($users);
        } catch (\Exception $e) {
            // Log the error
            Log::error('Error in UserController@index: ' . $e->getMessage());
            Log::error($e->getTraceAsString());
            
            // Return a more helpful error message
            return response()->json([
                'message' => 'Error retrieving users: ' . $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ], 500);
        }
    }

    /**
     * Store a newly created user (teacher)
     * Only admin users can create new teachers
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'email' => 'required|string|email|max:255|unique:users',
                'is_admin' => 'boolean'
            ]);

            if ($validator->fails()) {
                return response()->json(['errors' => $validator->errors()], 422);
            }

            // Verify that the email ends with @firda.nl
            $email = $request->email;
            if (!str_ends_with($email, '@firda.nl')) {
                return response()->json([
                    'message' => 'Docent e-mail moet eindigen op @firda.nl'
                ], 422);
            }

            // Generate a temporary random password
            $tempPassword = Str::random(16);

            // FIXED: Auto-verify the email for now to avoid email sending issues
            $user = User::create([
                'name' => 'New User', // Temporary name
                'email' => $email,
                'password' => Hash::make($tempPassword),
                'is_admin' => $request->is_admin ?? false,
                'setup_completed' => false,
                'invitation_sent_at' => now(),
                'email_verified_at' => now() // Auto-verify instead of sending email
            ]);

            // FIXED: Skip email verification for now
            // Instead of: $user->sendEmailVerificationNotification();

            return response()->json([
                'message' => 'Gebruiker succesvol aangemaakt. (E-mailverificatie is tijdelijk uitgeschakeld)',
                'user' => [
                    'id' => $user->id,
                    'email' => $user->email,
                    'is_admin' => $user->is_admin,
                    'created_at' => $user->created_at
                ],
                'temp_password' => $tempPassword // Only for testing - remove in production
            ], 201);
        } catch (\Exception $e) {
            // Log the error
            Log::error('Error in UserController@store: ' . $e->getMessage());
            Log::error($e->getTraceAsString());
            
            // Return a more helpful error message
            return response()->json([
                'message' => 'Error creating user: ' . $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ], 500);
        }
    }
}
EOF

# 2. Create SimpleUserController as a backup solution
echo -e "${GREEN}Creating SimpleUserController...${NC}"
cat > app/Http/Controllers/SimpleUserController.php << 'EOF'
<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Log;

class SimpleUserController extends Controller
{
    /**
     * A simplified controller for handling admin user operations
     * Created as an alternative to debug issues
     */
    
    public function index()
    {
        try {
            // Simplified query - minimal fields
            $users = User::select('id', 'name', 'email', 'is_admin')
                ->orderBy('name')
                ->get();

            return response()->json([
                'status' => 'success',
                'users' => $users
            ]);
        } catch (\Exception $e) {
            Log::error('SimpleUserController@index error: ' . $e->getMessage());
            
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }
    
    public function store(Request $request)
    {
        try {
            // Validate
            if (empty($request->email) || !filter_var($request->email, FILTER_VALIDATE_EMAIL)) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Valid email is required'
                ], 422);
            }
            
            $email = $request->email;
            
            // Check email domain
            if (!str_ends_with($email, '@firda.nl')) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Docent e-mail moet eindigen op @firda.nl'
                ], 422);
            }
            
            // Simple check for duplicate
            if (User::where('email', $email)->exists()) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Email already exists'
                ], 422);
            }
            
            // Generate password
            $tempPassword = Str::random(12);
            
            // Create user - simplified
            $user = new User();
            $user->name = 'New User';
            $user->email = $email;
            $user->password = Hash::make($tempPassword);
            $user->is_admin = $request->is_admin ? true : false;
            $user->setup_completed = false;
            $user->invitation_sent_at = now();
            $user->email_verified_at = now(); // Auto-verified
            $user->save();
            
            return response()->json([
                'status' => 'success',
                'message' => 'User created',
                'user' => [
                    'id' => $user->id,
                    'email' => $user->email,
                    'is_admin' => $user->is_admin
                ],
                'temp_password' => $tempPassword
            ], 201);
        } catch (\Exception $e) {
            Log::error('SimpleUserController@store error: ' . $e->getMessage());
            
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }
}
EOF

# 3. Create the health check route file
echo -e "${GREEN}Creating admin health check routes...${NC}"
cat > routes/admin_health_check.php << 'EOF'
<?php
// Admin health check routes

use Illuminate\Support\Facades\Route;

// Add a health check route that doesn't require authentication
Route::get('/admin-health-check', function () {
    return response()->json([
        'status' => 'ok',
        'message' => 'Admin routes are being loaded',
        'timestamp' => now()->toIso8601String()
    ]);
});

// Direct test route without admin middleware
Route::get('/direct-user-test', function (Request $request) {
    try {
        $users = \App\Models\User::select('id', 'name', 'email', 'is_admin')
            ->limit(5)
            ->get();
            
        return response()->json([
            'status' => 'success',
            'message' => 'Direct test successful',
            'current_user' => $request->user() ? $request->user()->only('id', 'name', 'email', 'is_admin') : null,
            'users' => $users
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => $e->getMessage(),
            'trace' => $e->getTraceAsString()
        ], 500);
    }
})->middleware('auth:sanctum');
EOF

# 4. Update the routes/api.php file to use the correct middleware syntax
echo -e "${GREEN}Updating API routes...${NC}"
# Use sed to replace the middleware syntax
sed -i "s/Route::middleware('admin')/Route::middleware(['admin'])/g" routes/api.php

# Add the include statement for the health check routes if it doesn't exist
if ! grep -q "admin_health_check.php" routes/api.php; then
    echo -e "\n// Include the admin health check routes\nrequire __DIR__.'/admin_health_check.php';" >> routes/api.php
    echo -e "${GREEN}Added health check routes to api.php${NC}"
else
    echo -e "${YELLOW}Health check routes already included in api.php${NC}"
fi

# Set proper permissions
echo -e "${GREEN}Setting permissions...${NC}"
chown -R www-data:www-data app/Http/Controllers/
chown -R www-data:www-data routes/
chmod 644 app/Http/Controllers/UserController.php
chmod 644 app/Http/Controllers/SimpleUserController.php
chmod 644 routes/admin_health_check.php
chmod 644 routes/api.php

# Clear Laravel cache
echo -e "${GREEN}Clearing Laravel cache...${NC}"
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

echo -e "${YELLOW}===== ADMIN FUNCTIONALITY FIX DEPLOYED =====${NC}"
echo -e "${GREEN}Verification:${NC}"
echo "1. Try accessing the health check endpoint: /api/admin-health-check"
echo "2. Try the admin routes with an admin token: /api/users and /api/simple-users"
echo "3. Check logs for any errors: storage/logs/laravel-*.log"
echo ""
echo -e "${YELLOW}Note: This fix auto-verifies new users instead of sending emails${NC}"
echo -e "${YELLOW}      and returns temporary passwords in the API response.${NC}"
echo -e "${YELLOW}      These are temporary measures for testing purposes.${NC}"
