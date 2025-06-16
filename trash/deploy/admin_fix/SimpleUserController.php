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
