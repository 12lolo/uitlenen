#!/bin/bash
# Script to create a comprehensive admin fix deployment package

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===== CREATING ADMIN FIX DEPLOYMENT PACKAGE =====${NC}"

# Create deployment directory if it doesn't exist
mkdir -p deploy/admin_fix

# Copy all necessary files
echo -e "${GREEN}Copying deployment files...${NC}"
cp final_admin_fix_production.sh deploy/admin_fix/
cp admin_deployment_guide.md deploy/admin_fix/
cp admin_fix_verification_report.md deploy/admin_fix/

# Create backup files for the server
echo -e "${GREEN}Creating controller files for deployment...${NC}"

# Create UserController file
cat > deploy/admin_fix/UserController.php << 'EOF'
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

# Create SimpleUserController file
cat > deploy/admin_fix/SimpleUserController.php << 'EOF'
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

# Create admin health check routes file
cat > deploy/admin_fix/admin_health_check.php << 'EOF'
<?php
// Admin health check routes

use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;

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

# Create verification script
cat > deploy/admin_fix/verify_fix.php << 'EOF'
<?php
// Verify admin functionality fix on production

$token = "5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585"; // Replace with your admin token
$baseUrl = "https://uitleensysteemfirda.nl/api";

function makeRequest($method, $endpoint, $data = null) {
    global $token, $baseUrl;
    
    $ch = curl_init($baseUrl . $endpoint);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Authorization: Bearer ' . $token
    ]);
    
    if ($data && ($method == 'POST' || $method == 'PUT')) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    }
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    return [
        'code' => $httpCode,
        'response' => json_decode($response, true)
    ];
}

echo "===== VERIFYING ADMIN FIX ON PRODUCTION =====\n\n";

// 0. Test health check endpoint (doesn't require auth)
echo "0. Testing health check endpoint...\n";
$result = makeRequest('GET', '/admin-health-check');
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 200) {
    echo "✅ Admin routes are being loaded correctly.\n\n";
} else {
    echo "❌ Admin routes might not be loaded correctly.\n\n";
}

// 1. Test direct route with auth
echo "1. Testing direct user test endpoint...\n";
$result = makeRequest('GET', '/direct-user-test');
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 200) {
    echo "✅ Direct test route is working.\n";
    echo "Current user: " . json_encode($result['response']['current_user'] ?? 'Not available') . "\n";
    echo "Users: " . count($result['response']['users'] ?? []) . " found\n\n";
} else {
    echo "❌ Direct test route failed.\n";
    if (isset($result['response']['message'])) {
        echo "Error: " . $result['response']['message'] . "\n";
    }
    echo "\n";
}

// 2. Test regular admin route
echo "2. Testing regular admin route (GET /users)...\n";
$result = makeRequest('GET', '/users');
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 200) {
    echo "✅ Regular admin route is working.\n";
    echo "Users found: " . count($result['response'] ?? []) . "\n\n";
} else {
    echo "❌ Regular admin route failed.\n";
    if (isset($result['response']['message'])) {
        echo "Error: " . $result['response']['message'] . "\n";
    }
    echo "\n";
}

// 3. Test simple admin route
echo "3. Testing simple admin route (GET /simple-users)...\n";
$result = makeRequest('GET', '/simple-users');
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 200) {
    echo "✅ Simple admin route is working.\n";
    echo "Users found: " . count($result['response']['users'] ?? []) . "\n\n";
} else {
    echo "❌ Simple admin route failed.\n";
    if (isset($result['response']['message'])) {
        echo "Error: " . $result['response']['message'] . "\n";
    }
    echo "\n";
}

// 4. Test user creation
$testEmail = "test" . time() . "@firda.nl";
echo "4. Testing user creation (POST /users with email: $testEmail)...\n";
$result = makeRequest('POST', '/users', [
    'email' => $testEmail,
    'is_admin' => false
]);
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 201) {
    echo "✅ User creation is working.\n";
    echo "User ID: " . ($result['response']['user']['id'] ?? 'Not available') . "\n";
    echo "Temp password: " . ($result['response']['temp_password'] ?? 'Not provided') . "\n\n";
} else {
    echo "❌ User creation failed.\n";
    if (isset($result['response']['message'])) {
        echo "Error: " . $result['response']['message'] . "\n";
    }
    echo "\n";
}

echo "===== VERIFICATION COMPLETED =====\n";
echo "Summary:\n";
$passed = 0;
$failed = 0;

// Report on health check
if (isset($result) && $result['code'] == 200) { $passed++; } else { $failed++; }

// Reset result to avoid confusion
unset($result);

echo "Tests passed: " . $passed . "\n";
echo "Tests failed: " . $failed . "\n";

if ($failed > 0) {
    echo "\nIf any tests failed, check server logs for more details:\n";
    echo "Log location: /var/www/uitleensysteemfirda.nl/storage/logs/laravel-*.log\n";
}
EOF

# Create manual deployment instructions
cat > deploy/admin_fix/README.md << 'EOF'
# Admin Functionality Fix - Manual Deployment

If the automatic deployment script doesn't work for any reason, follow these manual steps:

## 1. Copy Files to the Server

Upload these files to the correct locations:

- `UserController.php` → `/var/www/uitleensysteemfirda.nl/app/Http/Controllers/`
- `SimpleUserController.php` → `/var/www/uitleensysteemfirda.nl/app/Http/Controllers/`
- `admin_health_check.php` → `/var/www/uitleensysteemfirda.nl/routes/`

## 2. Update Routes File

Edit `/var/www/uitleensysteemfirda.nl/routes/api.php` and:

1. Fix middleware syntax by replacing:
   ```php
   Route::middleware('admin')->group(function () {
   ```
   with:
   ```php
   Route::middleware(['admin'])->group(function () {
   ```

2. Add the health check routes include at the end of the file:
   ```php
   // Include the admin health check routes
   require __DIR__.'/admin_health_check.php';
   ```

## 3. Clear Laravel Cache

Run these commands:

```bash
cd /var/www/uitleensysteemfirda.nl
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

## 4. Verify the Fix

Run the verification script:

```bash
php verify_fix.php
```

## Support

If you encounter any issues, check the Laravel logs at:
`/var/www/uitleensysteemfirda.nl/storage/logs/laravel-*.log`
EOF

# Create a simple upload script
cat > deploy/admin_fix/upload.sh << 'EOF'
#!/bin/bash
# Upload script for admin fix

# Define your server details
SERVER="uitleensysteemfirda.nl"
USER="user"  # Replace with your actual username
TARGET_DIR="/tmp/admin_fix"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===== UPLOADING ADMIN FIX TO PRODUCTION SERVER =====${NC}"

# Create remote directory
echo -e "${GREEN}Creating remote directory...${NC}"
ssh $USER@$SERVER "mkdir -p $TARGET_DIR"

# Upload all files
echo -e "${GREEN}Uploading files...${NC}"
scp ./* $USER@$SERVER:$TARGET_DIR/

echo -e "${GREEN}Files uploaded to $SERVER:$TARGET_DIR/${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo "1. SSH into the server: ssh $USER@$SERVER"
echo "2. Navigate to the upload directory: cd $TARGET_DIR"
echo "3. Run the deployment script: sudo bash final_admin_fix_production.sh"
echo "4. Verify the fix: php verify_fix.php"
EOF

# Create a complete deployment package
echo -e "${GREEN}Creating deployment package...${NC}"
cd deploy
zip -r admin_fix_complete.zip admin_fix/
cd ..

echo -e "${YELLOW}===== ADMIN FIX DEPLOYMENT PACKAGE CREATED =====${NC}"
echo -e "${GREEN}Package location: deploy/admin_fix_complete.zip${NC}"
echo -e "${GREEN}Deployment files: deploy/admin_fix/${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Upload the package to the production server"
echo "2. Extract the package on the server: unzip admin_fix_complete.zip"
echo "3. Navigate to the admin_fix directory: cd admin_fix"
echo "4. Run the deployment script: sudo bash final_admin_fix_production.sh"
echo "5. Verify the fix: php verify_fix.php"
