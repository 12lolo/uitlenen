<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class SimpleUserController extends Controller
{
    /**
     * Display a listing of all users (teachers) - simplified version without potential problematic code
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index()
    {
        try {
            // Check if user is admin using Auth facade
            if (!Auth::check() || !Auth::user()->is_admin) {
                return response()->json(['message' => 'This action is unauthorized.'], 403);
            }
            
            // Simplest possible implementation
            $users = User::all(['id', 'name', 'email', 'is_admin', 'created_at']);
            return response()->json($users);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Store a new user without email verification - simplified version for testing
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request)
    {
        try {
            // Check if user is admin using Auth facade
            if (!Auth::check() || !Auth::user()->is_admin) {
                return response()->json(['message' => 'This action is unauthorized.'], 403);
            }
            
            $validator = Validator::make($request->all(), [
                'email' => 'required|string|email|max:255|unique:users',
                'is_admin' => 'boolean'
            ]);

            if ($validator->fails()) {
                return response()->json(['errors' => $validator->errors()], 422);
            }

            // Verify email format
            $email = $request->email;
            if (!str_ends_with($email, '@firda.nl')) {
                return response()->json([
                    'message' => 'Docent e-mail moet eindigen op @firda.nl'
                ], 422);
            }

            // Create user without sending email
            $user = User::create([
                'name' => 'New User (No Email)',
                'email' => $email,
                'password' => Hash::make(Str::random(16)),
                'is_admin' => $request->is_admin ?? false,
                'setup_completed' => false,
                'invitation_sent_at' => now(),
                'email_verified_at' => now() // Auto verify for testing
            ]);

            return response()->json([
                'message' => 'User created successfully (no email sent)',
                'user' => $user->only('id', 'name', 'email', 'is_admin', 'created_at')
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }
}
