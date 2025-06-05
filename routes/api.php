<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
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

// Help routes
Route::get('/help', [HelpController::class, 'publicHelp']);
Route::get('/help/authenticated', [HelpController::class, 'authenticatedHelp'])->middleware('auth:sanctum');

// Authentication routes
Route::post('/login', [AuthController::class, 'login']);
Route::get('/login/format', [FormatController::class, 'loginFormat']);
Route::post('/register', [AuthController::class, 'register']);
Route::get('/register/format', [FormatController::class, 'registerFormat']);
Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');

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
Route::middleware('auth:sanctum')->group(function () {
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
    Route::middleware('admin')->group(function () {
        Route::get('/users', [UserController::class, 'index']);
        Route::post('/users', [UserController::class, 'store']);
        Route::get('/users/format', [FormatController::class, 'userFormat']);
    });
});

// Notification route (protected by token for cron jobs)
Route::post('/notifications/send-reminders', [NotificationController::class, 'sendReminders']);
Route::get('/notifications/send-reminders/format', [FormatController::class, 'sendRemindersFormat']);

// Legacy project routes
Route::apiResource('projects', ProjectController::class);
Route::get('/projects/format', [FormatController::class, 'projectFormat']);
