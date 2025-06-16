<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\ProjectController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\ItemController;
use App\Http\Controllers\LoanController;
use App\Http\Controllers\DamageController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\HelpController;
use App\Http\Controllers\TestController;
use App\Http\Controllers\FormatController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Health check route
Route::get('/admin-health-check', function () {
    return response()->json([
        'status' => 'ok',
        'message' => 'Admin routes are being loaded',
        'timestamp' => now()->toIso8601String()
    ]);
});

// Help routes
Route::get('/help', [HelpController::class, 'publicHelp']);
Route::get('/help/authenticated', [HelpController::class, 'authenticatedHelp'])->middleware('auth:sanctum')->name('api.help.authenticated');

// Authentication routes
Route::post('/login', [AuthController::class, 'login']);
Route::get('/login/format', [FormatController::class, 'loginFormat']);
Route::post('/register', [AuthController::class, 'register']);
Route::get('/register/format', [FormatController::class, 'registerFormat']);
Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');

// Email Verification Routes
Route::get('/email/verify/{id}/{hash}', [App\Http\Controllers\VerificationController::class, 'verify'])
    ->middleware('checkinvitation')
    ->name('verification.verify');
Route::post('/email/verification-notification', [App\Http\Controllers\VerificationController::class, 'resend'])
    ->middleware(['auth:sanctum', 'throttle:6,1'])
    ->name('verification.send');

// Invitation Routes
Route::post('/invitations/resend', [App\Http\Controllers\InvitationController::class, 'resend'])
    ->middleware(['auth:sanctum', 'verified']);
Route::get('/invitations/resend/format', [FormatController::class, 'invitationResendFormat']);

// Account Setup Routes
Route::post('/account-setup/complete', [App\Http\Controllers\AccountSetupController::class, 'completeSetup'])
    ->middleware('check.invitation');
Route::get('/account-setup/status', [App\Http\Controllers\AccountSetupController::class, 'checkSetupStatus'])
    ->middleware('check.invitation');
Route::get('/account-setup/format', [FormatController::class, 'accountSetupFormat']);

// User profile route
Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// Public routes - no authentication required
Route::get('/categories', [CategoryController::class, 'index']);
Route::get('/categories/{id}/items', [CategoryController::class, 'items']);
Route::get('/items/{id}', [ItemController::class, 'show']);

// Test routes
Route::post('/test/email', [TestController::class, 'testEmail']);
Route::get('/test/email/format', [FormatController::class, 'testEmailFormat']);

// Protected routes - authentication required
Route::middleware(['auth:sanctum', 'verified'])->group(function () {
    // Category management
    Route::post('/categories', [CategoryController::class, 'store']);
    Route::get('/categories/format', [FormatController::class, 'categoryFormat']);
    Route::put('/categories/{id}', [CategoryController::class, 'update']);
    Route::get('/categories/update/format', [FormatController::class, 'categoryUpdateFormat']);
    Route::delete('/categories/{id}', [CategoryController::class, 'destroy']);

    // Item management
    Route::get('/items', [ItemController::class, 'index']);
    Route::post('/items', [ItemController::class, 'store']);
    Route::get('/items/format', [FormatController::class, 'itemFormat']);
    Route::put('/items/{id}', [ItemController::class, 'update']);
    Route::get('/items/update/format', [FormatController::class, 'itemUpdateFormat']);
    Route::delete('/items/{id}', [ItemController::class, 'destroy']);

    // Loan management
    Route::get('/lendings', [LoanController::class, 'index']);
    Route::post('/lendings', [LoanController::class, 'store']);
    Route::get('/lendings/format', [FormatController::class, 'lendingFormat']);
    Route::post('/lendings/{id}/return', [LoanController::class, 'returnItem']);
    Route::get('/lendings/return/format', [FormatController::class, 'returnItemFormat']);
    Route::get('/lendings/status', [LoanController::class, 'status']);

    // Damage management
    Route::post('/items/{id}/damage', [DamageController::class, 'store']);
    Route::get('/items/damage/format', [FormatController::class, 'damageFormat']);
    Route::get('/damages', [DamageController::class, 'index']);

    // User management (admin only)
    // Using controller-level admin checks instead of middleware
    Route::get('/users', [UserController::class, 'index'])->middleware('auth:sanctum');
    Route::post('/users', [UserController::class, 'store'])->middleware('auth:sanctum');
    
    // Simple user management (admin only) - Test routes
    Route::get('/simple-users', [\App\Http\Controllers\SimpleUserController::class, 'index'])->middleware('auth:sanctum');
    Route::post('/simple-users', [\App\Http\Controllers\SimpleUserController::class, 'store'])->middleware('auth:sanctum');
    
// User format guide (moved outside admin middleware)
    Route::get('/users/format', [FormatController::class, 'userFormat']);
    
    // Admin test routes
    Route::get('/admin-gate-test', function() {
        try {
            // Check if user is admin
            if (!\Illuminate\Support\Facades\Auth::check() || !\Illuminate\Support\Facades\Auth::user()->is_admin) {
                return response()->json(['message' => 'This action is unauthorized.'], 403);
            }
            
            return response()->json([
                'status' => 'success',
                'message' => 'Admin gate test successful',
                'user' => \Illuminate\Support\Facades\Auth::user()->only('id', 'name', 'email', 'is_admin')
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ], 500);
        }
    })->middleware('auth:sanctum');
    
    // Direct test route without middleware
    Route::get('/test-admin-route', function() {
        try {
            $users = \App\Models\User::select('id', 'name', 'email')->limit(5)->get();
            return response()->json([
                'message' => 'Direct test route successful',
                'data' => $users,
                'auth_user' => \Illuminate\Support\Facades\Auth::check() ? \Illuminate\Support\Facades\Auth::user()->only('id', 'name', 'email', 'is_admin') : null
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ], 500);
        }
    })->middleware('auth:sanctum');
});

// Notification route (protected by token for cron jobs)
Route::post('/notifications/send-reminders', [NotificationController::class, 'sendReminders']);
Route::get('/notifications/send-reminders/format', [FormatController::class, 'sendRemindersFormat']);

// Legacy project routes
Route::apiResource('projects', ProjectController::class);
Route::get('/projects/format', [FormatController::class, 'projectFormat']);

// Include the comprehensive admin fix routes
require __DIR__.'/comprehensive_admin_fix.php';

// Include auth check test routes
require __DIR__.'/auth_check_test.php';

// Add a direct test route for checkinvitation middleware
Route::get('/test-checkinvitation', function (Request $request) {
    return response()->json([
        'status' => 'success',
        'message' => 'checkinvitation middleware is working',
        'timestamp' => now()->toIso8601String()
    ]);
})->middleware('checkinvitation');

// Include admin test routes
require __DIR__.'/admin_test_routes.php';

// Include dedicated admin routes
require __DIR__.'/admin.php';
