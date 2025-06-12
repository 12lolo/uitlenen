<?php
// This file will be temporarily added to your project to fix the admin functionality
// It creates a special route that can update the UserController directly

/*
 * HOW TO USE THIS FIX:
 * 1. Add this file to your project routes directory on the production server
 * 2. Include it from your routes/api.php file
 * 3. Access the fix endpoint with your admin token
 * 4. Verify the fix is working
 * 5. Remove this file and the include statement for security
 */

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Log;
use Illuminate\Http\Request;

// This special route will fix the UserController
Route::get('/admin-fix/{secret_key}', function (Request $request, $secret_key) {
    // Only allow this route to be accessed with the correct key and admin token
    if ($secret_key !== 'fix_admin_june_2025' || !$request->user() || !$request->user()->is_admin) {
        return response()->json([
            'message' => 'Unauthorized'
        ], 403);
    }

    try {
        // Path to the UserController
        $controllerPath = app_path('Http/Controllers/UserController.php');
        
        // Create a backup
        $backupPath = app_path('Http/Controllers/UserController.php.bak_' . date('Ymd_His'));
        File::copy($controllerPath, $backupPath);
        
        // The fixed controller code
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
        File::put($controllerPath, $fixedCode);
        
        // Fix routes/api.php file to use proper array syntax for middleware
        $routesPath = base_path('routes/api.php');
        $routesContent = File::get($routesPath);
        
        // Replace the middleware syntax
        $routesContent = str_replace(
            "Route::middleware('admin')->group(function () {", 
            "Route::middleware(['admin'])->group(function () {", 
            $routesContent
        );
        
        File::put($routesPath, $routesContent);
        
        // Clear the application cache
        \Illuminate\Support\Facades\Artisan::call('cache:clear');
        \Illuminate\Support\Facades\Artisan::call('config:clear');
        \Illuminate\Support\Facades\Artisan::call('route:clear');
        \Illuminate\Support\Facades\Artisan::call('view:clear');
        
        return response()->json([
            'success' => true,
            'message' => 'Admin functionality has been fixed. UserController has been updated and routes have been fixed.',
            'backup_created' => $backupPath,
            'cache_cleared' => true
        ]);
    } catch (\Exception $e) {
        Log::error('Admin fix failed: ' . $e->getMessage());
        Log::error($e->getTraceAsString());
        
        return response()->json([
            'success' => false,
            'message' => 'Failed to apply admin fix: ' . $e->getMessage(),
            'trace' => $e->getTraceAsString()
        ], 500);
    }
})->middleware('auth:sanctum');
