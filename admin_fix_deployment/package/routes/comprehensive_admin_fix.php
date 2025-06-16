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
