<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AccountSetupController extends Controller
{
    /**
     * Complete the account setup after email verification
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function completeSetup(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|exists:users,id',
            'name' => 'required|string|max:255',
            'password' => 'required|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $user = User::findOrFail($request->user_id);

        // Check if the account setup is already completed
        if ($user->setup_completed) {
            return response()->json([
                'message' => 'Account setup is al voltooid.'
            ], 400);
        }

        // Check if email is verified
        if (!$user->hasVerifiedEmail()) {
            return response()->json([
                'message' => 'U moet uw e-mailadres verifiëren voordat u de accountinstelling kunt voltooien.'
            ], 400);
        }

        // Update user account
        $user->update([
            'name' => $request->name,
            'password' => Hash::make($request->password),
            'setup_completed' => true
        ]);

        return response()->json([
            'message' => 'Account setup succesvol voltooid.'
        ]);
    }

    /**
     * Check if a user is eligible for account setup
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function checkSetupStatus(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|exists:users,id',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $user = User::findOrFail($request->user_id);

        $status = [
            'setup_completed' => $user->setup_completed,
            'email_verified' => $user->hasVerifiedEmail(),
            'can_complete_setup' => $user->hasVerifiedEmail() && !$user->setup_completed
        ];

        return response()->json($status);
    }
}
