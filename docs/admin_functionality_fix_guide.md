# Troubleshooting Guide: Admin Functionality in Uitleen System

## Issue Description

During API testing, we encountered 500 Internal Server Errors when attempting to use the admin-only endpoints:
- `GET /users` - Returns a 500 error
- `POST /users` - Returns a 500 error

The admin middleware appears to be properly configured in the Kernel.php file, and the routes are correctly defined in api.php. This suggests the issue might be in the UserController implementation or related models.

## Diagnostic Steps

1. **Check Server Logs**

   First, check the Laravel error logs to identify the specific exception that's causing the 500 error:

   ```bash
   # Connect to the server and view the logs
   ssh user@uitleensysteemfirda.nl
   cd /path/to/laravel/storage/logs
   tail -n 100 laravel.log
   ```

2. **Verify Admin Permissions**

   Confirm that the test user actually has admin privileges:

   ```php
   // Run this in a PHP test script or tinker
   $user = \App\Models\User::find(1);
   var_dump($user->is_admin);
   ```

3. **Check UserController Implementation**

   Review the UserController class for potential issues:
   - Missing dependencies or use statements
   - Uncaught exceptions
   - Logic errors in the index() or store() methods

4. **Verify the Admin Middleware**

   Test the admin middleware directly:

   ```php
   // Create a test route with only the admin middleware
   Route::get('/test-admin', function () {
       return response()->json(['status' => 'success']);
   })->middleware('admin');
   ```

## Potential Fixes

Based on common issues, here are potential fixes for the admin functionality:

1. **Fix UserController Index Method**

   If the issue is in retrieving users:

   ```php
   public function index()
   {
       try {
           $users = User::select('id', 'name', 'email', 'is_admin', 'created_at')
               ->orderBy('name')
               ->get();

           return response()->json($users);
       } catch (\Exception $e) {
           // Log the error
           \Log::error('Error in UserController@index: ' . $e->getMessage());
           
           // Return a more helpful error message
           return response()->json([
               'message' => 'Error retrieving users: ' . $e->getMessage()
           ], 500);
       }
   }
   ```

2. **Fix UserController Store Method**

   If the issue is in creating users:

   ```php
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
           $tempPassword = \Illuminate\Support\Str::random(16);

           $user = User::create([
               'name' => 'New User', // Temporary name
               'email' => $email,
               'password' => \Illuminate\Support\Facades\Hash::make($tempPassword),
               'is_admin' => $request->is_admin ?? false,
               'setup_completed' => false,
               'invitation_sent_at' => now()
           ]);

           // Send verification email (wrapped in try-catch to avoid email errors breaking the API)
           try {
               $user->sendEmailVerificationNotification();
           } catch (\Exception $emailException) {
               \Log::warning('Failed to send verification email: ' . $emailException->getMessage());
           }

           return response()->json([
               'message' => 'Uitnodiging succesvol verzonden. De gebruiker ontvangt een e-mail om het account te activeren.',
               'user' => [
                   'id' => $user->id,
                   'email' => $user->email,
                   'is_admin' => $user->is_admin,
                   'created_at' => $user->created_at
               ]
           ], 201);
       } catch (\Exception $e) {
           // Log the error
           \Log::error('Error in UserController@store: ' . $e->getMessage());
           
           // Return a more helpful error message
           return response()->json([
               'message' => 'Error creating user: ' . $e->getMessage()
           ], 500);
       }
   }
   ```

3. **Fix Admin Middleware Registration**

   If there's an issue with how the middleware is applied:

   ```php
   // In routes/api.php
   Route::middleware(['auth:sanctum', 'admin'])->group(function () {
       Route::get('/users', [UserController::class, 'index']);
       Route::post('/users', [UserController::class, 'store']);
   });
   ```

## Testing the Fix

After implementing any fixes, test the admin functionality again:

```bash
# Test getting all users
curl -H "Authorization: Bearer YOUR_ADMIN_TOKEN" https://uitleensysteemfirda.nl/api/users

# Test creating a new user
curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer YOUR_ADMIN_TOKEN" -d '{"email":"test@firda.nl","is_admin":false}' https://uitleensysteemfirda.nl/api/users
```

## Prevention Tips

To prevent similar issues in the future:

1. **Implement Better Error Handling**
   - Wrap controller methods in try-catch blocks
   - Log detailed error information
   - Return informative error messages in API responses

2. **Add Automated Tests**
   - Create PHPUnit tests for admin functionality
   - Include both positive and negative test cases
   - Run tests as part of deployment process

3. **Implement API Monitoring**
   - Set up logging for all 500 errors
   - Create alerts for unexpected error rates
   - Regularly review error logs

## Conclusion

The 500 errors in the admin functionality are likely due to uncaught exceptions in the UserController. By adding proper error handling and fixing any implementation issues, these functions should work correctly.
