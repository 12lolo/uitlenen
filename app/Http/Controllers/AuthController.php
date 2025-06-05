<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Handle user login
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        if (!Auth::attempt($request->only('email', 'password'))) {
            throw ValidationException::withMessages([
                'email' => ['De opgegeven inloggegevens zijn onjuist.'],
            ]);
        }

        $user = User::where('email', $request->email)->firstOrFail();

        // Check if email is verified
        if (!$user->hasVerifiedEmail()) {
            return response()->json([
                'message' => 'E-mailadres is niet geverifieerd. Controleer uw e-mail om uw account te verifiëren.'
            ], 403);
        }

        // Check if account setup is completed
        if (!$user->setup_completed) {
            return response()->json([
                'message' => 'Account setup is niet voltooid. Voltooi de setup via de verificatie-e-mail.',
                'setup_required' => true,
                'user_id' => $user->id
            ], 403);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => $user
        ]);
    }

    /**
     * Handle user registration
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // Verify that the email ends with @firda.nl or @student.firda.nl
        $email = $request->email;
        if (!str_ends_with($email, '@firda.nl') && !str_ends_with($email, '@student.firda.nl')) {
            return response()->json([
                'message' => 'Alleen e-mailadressen eindigend op @firda.nl of @student.firda.nl zijn toegestaan'
            ], 422);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $email,
            'password' => Hash::make($request->password),
            'is_admin' => false, // Default to regular user
        ]);

        // Send verification email
        $user->sendEmailVerificationNotification();

        return response()->json([
            'message' => 'Gebruiker succesvol geregistreerd. Controleer uw e-mail om uw account te verifiëren.',
            'user' => $user
        ], 201);
    }

    /**
     * Handle user logout
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Succesvol uitgelogd'
        ]);
    }
}
