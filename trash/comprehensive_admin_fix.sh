#!/bin/bash
# Comprehensive admin fix deployment script
# Usage: Run this script locally, then upload to the server and run the second part there

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===== COMPREHENSIVE ADMIN FUNCTIONALITY FIX =====${NC}"

# 1. Create the special route file
echo -e "${GREEN}Creating comprehensive fix route file...${NC}"
cat > routes/comprehensive_admin_fix.php << 'EOF'
<?php
// Comprehensive admin functionality fix route

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Log;
use Illuminate\Http\Request;

// This route will apply a comprehensive fix to the admin functionality
Route::get('/comprehensive-admin-fix/{secret_key}', function (Request $request, $secret_key) {
    // Only allow this route to be accessed with the correct key and admin token
    if ($secret_key !== 'fix_admin_june_2025' || !$request->user() || !$request->user()->is_admin) {
        return response()->json([
            'message' => 'Unauthorized'
        ], 403);
    }

    try {
        // Fix 1: Fix the UserController
        $userControllerPath = app_path('Http/Controllers/UserController.php');
        $backupPath = app_path('Http/Controllers/UserController.php.bak_' . date('Ymd_His'));
        
        // Create a backup
        if (File::exists($userControllerPath)) {
            File::copy($userControllerPath, $backupPath);
        }
        
        // The fixed controller code - making sure to close the class properly
        $fixedCode = <<<'PHP'
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
PHP;

        // Write the fixed code to the file
        File::put($userControllerPath, $fixedCode);
        
        // Fix 2: Create a SimpleUserController as an alternative
        $simpleControllerPath = app_path('Http/Controllers/SimpleUserController.php');
        
        $simpleControllerCode = <<<'PHP'
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
PHP;

        // Write the simple controller
        File::put($simpleControllerPath, $simpleControllerCode);
        
        // Fix 3: Fix the routes/api.php file
        $routesPath = base_path('routes/api.php');
        $routesContent = File::get($routesPath);
        
        // Make sure we use the array syntax for middleware
        $routesContent = str_replace(
            "Route::middleware('admin')->group(function () {", 
            "Route::middleware(['admin'])->group(function () {", 
            $routesContent
        );
        
        // Ensure the include statement for the admin fix routes is present
        if (!str_contains($routesContent, "require __DIR__.'/comprehensive_admin_fix.php';")) {
            // Add the include after the last route definition
            $routesContent .= "\n\n// Include the comprehensive admin fix routes\nrequire __DIR__.'/comprehensive_admin_fix.php';\n";
        }
        
        // Add a direct test route outside the admin middleware
        if (!str_contains($routesContent, "direct-user-test")) {
            $testRoute = <<<'PHP'

// Direct user test route (no admin middleware)
Route::get('/direct-user-test', function (Request $request) {
    try {
        $users = App\Models\User::select('id', 'name', 'email', 'is_admin')
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

PHP;
            
            // Insert before the last closing brace
            $lastBracePos = strrpos($routesContent, '});');
            if ($lastBracePos !== false) {
                $routesContent = substr_replace($routesContent, $testRoute, $lastBracePos, 0);
            } else {
                // If we can't find the position, just append
                $routesContent .= $testRoute;
            }
        }
        
        // Write the updated routes file
        File::put($routesPath, $routesContent);
        
        // Fix 4: Update the .env file to enable debugging
        $envPath = base_path('.env');
        if (File::exists($envPath)) {
            $envContent = File::get($envPath);
            
            // Set debug mode to true
            $envContent = preg_replace('/APP_DEBUG=false/', 'APP_DEBUG=true', $envContent);
            
            // Make sure error logging is set to daily
            $envContent = preg_replace('/LOG_CHANNEL=.*/', 'LOG_CHANNEL=daily', $envContent);
            
            File::put($envPath, $envContent);
        }
        
        // Clear all caches
        \Artisan::call('cache:clear');
        \Artisan::call('config:clear');
        \Artisan::call('route:clear');
        \Artisan::call('view:clear');
        
        return response()->json([
            'status' => 'success',
            'message' => 'Comprehensive admin fix applied successfully',
            'actions' => [
                'UserController fixed',
                'SimpleUserController created',
                'Routes fixed and enhanced',
                'Debug mode enabled',
                'Caches cleared'
            ],
            'next_steps' => [
                'Test regular admin endpoints: GET /api/users and POST /api/users',
                'Test simple admin endpoints: GET /api/simple-users and POST /api/simple-users',
                'Test direct endpoint: GET /api/direct-user-test',
                'Check logs for any remaining errors: storage/logs/laravel-*.log'
            ]
        ]);
    } catch (\Exception $e) {
        Log::error('Comprehensive admin fix failed: ' . $e->getMessage());
        Log::error($e->getTraceAsString());
        
        return response()->json([
            'status' => 'error',
            'message' => 'Failed to apply comprehensive admin fix: ' . $e->getMessage(),
            'trace' => $e->getTraceAsString()
        ], 500);
    }
})->middleware('auth:sanctum');

// Add a health check route that doesn't require authentication
Route::get('/admin-health-check', function () {
    return response()->json([
        'status' => 'ok',
        'message' => 'Admin routes are being loaded',
        'timestamp' => now()->toIso8601String()
    ]);
});
EOF

# 2. Update the api.php file to include the comprehensive fix route
echo -e "${GREEN}Updating api.php to include the comprehensive fix route...${NC}"
if ! grep -q "comprehensive_admin_fix.php" routes/api.php; then
    echo -e "\n// Include the comprehensive admin fix routes\nrequire __DIR__.'/comprehensive_admin_fix.php';" >> routes/api.php
    echo -e "${GREEN}Route file included in api.php${NC}"
else
    echo -e "${YELLOW}Route file already included in api.php${NC}"
fi

# 3. Create deployment package
echo -e "${GREEN}Creating deployment package...${NC}"
zip -j admin_fix_comprehensive.zip routes/comprehensive_admin_fix.php routes/api.php app/Http/Controllers/UserController.php

# 4. Create verification script
echo -e "${GREEN}Creating verification script...${NC}"
cat > verify_comprehensive_fix.php << 'EOF'
<?php
// Verify comprehensive admin functionality fix

$token = "5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585";
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

echo "===== VERIFYING COMPREHENSIVE ADMIN FIX =====\n\n";

// 0. Check the health check endpoint
echo "0. Testing health check endpoint...\n";
$result = makeRequest('GET', '/admin-health-check');
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 200) {
    echo "✅ Admin routes are being loaded correctly.\n\n";
} else {
    echo "❌ Admin routes might not be loaded correctly.\n\n";
}

// 1. Apply the fix
echo "1. Applying the comprehensive fix...\n";
$result = makeRequest('GET', '/comprehensive-admin-fix/fix_admin_june_2025');
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 200) {
    echo "✅ Comprehensive fix applied successfully.\n";
    if (isset($result['response']['actions'])) {
        echo "Actions performed:\n";
        foreach ($result['response']['actions'] as $action) {
            echo "  - " . $action . "\n";
        }
    }
    echo "\n";
} else {
    echo "❌ Failed to apply comprehensive fix.\n";
    if (isset($result['response']['message'])) {
        echo "Error: " . $result['response']['message'] . "\n";
    }
    echo "\n";
}

// 2. Test direct route (no admin middleware)
echo "2. Testing direct route (no admin middleware)...\n";
$result = makeRequest('GET', '/direct-user-test');
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 200) {
    echo "✅ Direct route is working.\n";
    echo "Current user: " . json_encode($result['response']['current_user'] ?? 'Not available') . "\n";
    echo "Number of users: " . count($result['response']['users'] ?? []) . "\n\n";
} else {
    echo "❌ Direct route failed.\n";
    if (isset($result['response']['message'])) {
        echo "Error: " . $result['response']['message'] . "\n";
    }
    echo "\n";
}

// 3. Test standard admin route
echo "3. Testing standard admin route (GET /users)...\n";
$result = makeRequest('GET', '/users');
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 200) {
    echo "✅ Standard admin route is working.\n";
    echo "Number of users: " . count($result['response'] ?? []) . "\n\n";
} else {
    echo "❌ Standard admin route failed.\n";
    if (isset($result['response']['message'])) {
        echo "Error: " . $result['response']['message'] . "\n";
    }
    echo "\n";
}

// 4. Test simple admin route
echo "4. Testing simple admin route (GET /simple-users)...\n";
$result = makeRequest('GET', '/simple-users');
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 200) {
    echo "✅ Simple admin route is working.\n";
    echo "Number of users: " . count($result['response']['users'] ?? []) . "\n\n";
} else {
    echo "❌ Simple admin route failed.\n";
    if (isset($result['response']['message'])) {
        echo "Error: " . $result['response']['message'] . "\n";
    }
    echo "\n";
}

// 5. Test creating a user
$testEmail = "test" . time() . "@firda.nl";
echo "5. Testing user creation (POST /users with email: $testEmail)...\n";
$result = makeRequest('POST', '/users', [
    'email' => $testEmail,
    'is_admin' => false
]);
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 201) {
    echo "✅ User creation is working.\n";
    echo "User ID: " . ($result['response']['user']['id'] ?? 'Not available') . "\n";
    echo "Temporary password: " . ($result['response']['temp_password'] ?? 'Not provided') . "\n\n";
} else {
    echo "❌ User creation failed.\n";
    if (isset($result['response']['message'])) {
        echo "Error: " . $result['response']['message'] . "\n";
    }
    echo "\n";
}

// 6. Test creating a user with simple controller
$testEmail = "simple_test" . time() . "@firda.nl";
echo "6. Testing simple user creation (POST /simple-users with email: $testEmail)...\n";
$result = makeRequest('POST', '/simple-users', [
    'email' => $testEmail,
    'is_admin' => false
]);
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 201) {
    echo "✅ Simple user creation is working.\n";
    echo "User ID: " . ($result['response']['user']['id'] ?? 'Not available') . "\n";
    echo "Temporary password: " . ($result['response']['temp_password'] ?? 'Not provided') . "\n\n";
} else {
    echo "❌ Simple user creation failed.\n";
    if (isset($result['response']['message'])) {
        echo "Error: " . $result['response']['message'] . "\n";
    }
    echo "\n";
}

echo "===== VERIFICATION COMPLETED =====\n";
echo "If any tests failed, please check the server logs for more details.\n";
echo "Log location: /var/www/uitleensysteemfirda.nl/storage/logs/laravel-*.log\n";
EOF

# 5. Create server deployment guide
echo -e "${GREEN}Creating server deployment guide...${NC}"
cat > deploy_on_server.md << 'EOF'
# Comprehensive Admin Fix - Server Deployment Guide

## Step 1: Upload Files
Upload the `admin_fix_comprehensive.zip` file to your server using SCP or SFTP:

```bash
scp admin_fix_comprehensive.zip user@uitleensysteemfirda.nl:/tmp/
```

## Step 2: Extract and Deploy on Server
SSH into your server and run these commands:

```bash
# Log in to server
ssh user@uitleensysteemfirda.nl

# Navigate to Laravel project directory
cd /var/www/uitleensysteemfirda.nl

# Create backup
mkdir -p backups/$(date +%Y%m%d)
cp -f app/Http/Controllers/UserController.php backups/$(date +%Y%m%d)/UserController.php.bak
cp -f routes/api.php backups/$(date +%Y%m%d)/api.php.bak

# Extract fix files
unzip -o /tmp/admin_fix_comprehensive.zip -d /tmp/admin_fix/
cp -f /tmp/admin_fix/UserController.php app/Http/Controllers/
cp -f /tmp/admin_fix/api.php routes/
cp -f /tmp/admin_fix/comprehensive_admin_fix.php routes/

# Set proper permissions
chown -R www-data:www-data app/Http/Controllers/
chown -R www-data:www-data routes/
chmod 644 app/Http/Controllers/UserController.php
chmod 644 routes/api.php
chmod 644 routes/comprehensive_admin_fix.php

# Clear Laravel cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Clean up
rm -rf /tmp/admin_fix
rm /tmp/admin_fix_comprehensive.zip
```

## Step 3: Apply the Fix
Use curl to trigger the fix endpoint (requires a valid admin token):

```bash
curl -X GET "https://uitleensysteemfirda.nl/api/comprehensive-admin-fix/fix_admin_june_2025" \
  -H "Authorization: Bearer 5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585" \
  -H "Content-Type: application/json"
```

## Step 4: Verify the Fix
Run the verification script locally:

```bash
php verify_comprehensive_fix.php
```

## Troubleshooting
If issues persist:

1. Check Laravel logs on the server:
   ```bash
   tail -n 100 /var/www/uitleensysteemfirda.nl/storage/logs/laravel-*.log
   ```

2. Ensure the admin middleware is properly registered in app/Http/Kernel.php:
   ```php
   protected $middlewareAliases = [
       // ... other middleware
       'admin' => \App\Http\Middleware\AdminMiddleware::class,
   ];
   ```

3. Test the direct endpoint which bypasses the admin middleware:
   ```
   GET /api/direct-user-test
   ```

4. Check PHP error logs:
   ```bash
   tail -n 100 /var/log/apache2/error.log  # For Apache
   # or
   tail -n 100 /var/log/nginx/error.log    # For Nginx
   ```
EOF

# 6. Create a complete shell script for server deployment
echo -e "${GREEN}Creating server deployment script...${NC}"
cat > deploy_on_server.sh << 'EOF'
#!/bin/bash
# Comprehensive admin fix server deployment script

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===== DEPLOYING COMPREHENSIVE ADMIN FIX =====${NC}"

# Navigate to Laravel project directory
cd /var/www/uitleensysteemfirda.nl || {
    echo -e "${RED}Failed to navigate to project directory${NC}"
    exit 1
}

# Create backup
echo -e "${GREEN}Creating backups...${NC}"
mkdir -p backups/$(date +%Y%m%d)
cp -f app/Http/Controllers/UserController.php backups/$(date +%Y%m%d)/UserController.php.bak || echo -e "${YELLOW}Warning: Could not backup UserController${NC}"
cp -f routes/api.php backups/$(date +%Y%m%d)/api.php.bak || echo -e "${YELLOW}Warning: Could not backup api.php${NC}"

# Extract fix files
echo -e "${GREEN}Extracting fix files...${NC}"
mkdir -p /tmp/admin_fix
unzip -o /tmp/admin_fix_comprehensive.zip -d /tmp/admin_fix/ || {
    echo -e "${RED}Failed to extract fix files${NC}"
    exit 1
}

# Copy files
echo -e "${GREEN}Copying fixed files...${NC}"
cp -f /tmp/admin_fix/UserController.php app/Http/Controllers/ || echo -e "${RED}Failed to copy UserController${NC}"
cp -f /tmp/admin_fix/api.php routes/ || echo -e "${RED}Failed to copy api.php${NC}"
cp -f /tmp/admin_fix/comprehensive_admin_fix.php routes/ || echo -e "${RED}Failed to copy comprehensive_admin_fix.php${NC}"

# Set proper permissions
echo -e "${GREEN}Setting permissions...${NC}"
chown -R www-data:www-data app/Http/Controllers/
chown -R www-data:www-data routes/
chmod 644 app/Http/Controllers/UserController.php
chmod 644 routes/api.php
chmod 644 routes/comprehensive_admin_fix.php

# Clear Laravel cache
echo -e "${GREEN}Clearing Laravel cache...${NC}"
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Clean up
echo -e "${GREEN}Cleaning up...${NC}"
rm -rf /tmp/admin_fix
rm -f /tmp/admin_fix_comprehensive.zip

# Apply the fix
echo -e "${GREEN}Applying the fix...${NC}"
TOKEN="5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585"
RESPONSE=$(curl -s -X GET "https://uitleensysteemfirda.nl/api/comprehensive-admin-fix/fix_admin_june_2025" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json")

if [[ "$RESPONSE" == *"success"* ]]; then
    echo -e "${GREEN}Fix applied successfully!${NC}"
    echo "$RESPONSE" | grep -o '"message":"[^"]*"' | cut -d'"' -f4
else
    echo -e "${RED}Failed to apply fix${NC}"
    echo "$RESPONSE"
fi

echo -e "${YELLOW}===== DEPLOYMENT COMPLETED =====${NC}"
echo -e "${GREEN}Next step: Run the verification script to confirm the fix${NC}"
EOF
chmod +x deploy_on_server.sh

echo -e "${YELLOW}===== PREPARATION COMPLETED =====${NC}"
echo -e "${GREEN}Files created:${NC}"
echo "1. routes/comprehensive_admin_fix.php - Comprehensive fix route"
echo "2. admin_fix_comprehensive.zip - Deployment package"
echo "3. verify_comprehensive_fix.php - Verification script"
echo "4. deploy_on_server.md - Server deployment guide"
echo "5. deploy_on_server.sh - Server deployment script"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Upload admin_fix_comprehensive.zip to your server"
echo "2. Run deploy_on_server.sh on the server or follow the instructions in deploy_on_server.md"
echo "3. Run verify_comprehensive_fix.php locally to verify the fix"
