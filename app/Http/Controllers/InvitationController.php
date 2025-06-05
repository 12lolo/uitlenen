<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class InvitationController extends Controller
{
    /**
     * Resend invitation for an unverified user
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function resend(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|string|email|exists:users,email',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $user = User::where('email', $request->email)->firstOrFail();

        // Check if user already verified their email
        if ($user->hasVerifiedEmail()) {
            return response()->json([
                'message' => 'E-mailadres is al geverifieerd.'
            ], 400);
        }

        // Update invitation time
        $user->update([
            'invitation_sent_at' => now()
        ]);

        // Send verification email
        $user->sendEmailVerificationNotification();

        return response()->json([
            'message' => 'Uitnodiging is opnieuw verzonden. De gebruiker ontvangt een nieuwe e-mail om het account te activeren.'
        ]);
    }
}
