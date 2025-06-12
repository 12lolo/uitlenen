<?php

namespace App\Http\Controllers;

use Illuminate\Auth\Events\Verified;
use Illuminate\Foundation\Auth\EmailVerificationRequest;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\URL;

class VerificationController extends Controller
{
    /**
     * Mark the authenticated user's email address as verified.
     *
     * @param  Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function verify(Request $request)
    {
        $user = User::findOrFail($request->id);

        if (! hash_equals((string) $request->hash, sha1($user->getEmailForVerification()))) {
            return response()->json([
                'message' => 'Ongeldige verificatielink.'
            ], 403);
        }

        if ($user->hasVerifiedEmail()) {
            return response()->json([
                'message' => 'E-mailadres is al geverifieerd.'
            ]);
        }

        if ($user->markEmailAsVerified()) {
            event(new Verified($user));
        }

        // Check if user needs to complete account setup
        if (!$user->setup_completed) {
            // You can redirect to a frontend page with the user ID as a parameter
            // for completing the account setup
            $setupUrl = config('app.frontend_url', 'http://localhost:3000') . '/complete-setup/' . $user->id;

            return response()->json([
                'message' => 'E-mailadres succesvol geverifieerd.',
                'setup_required' => true,
                'user_id' => $user->id,
                'setup_url' => $setupUrl
            ]);
        }

        return response()->json([
            'message' => 'E-mailadres succesvol geverifieerd.'
        ]);
    }

    /**
     * Resend the email verification notification.
     *
     * @param  Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function resend(Request $request)
    {
        if ($request->user()->hasVerifiedEmail()) {
            return response()->json([
                'message' => 'E-mailadres is al geverifieerd.'
            ]);
        }

        $request->user()->sendEmailVerificationNotification();

        return response()->json([
            'message' => 'Verificatie-e-mail opnieuw verzonden.'
        ]);
    }
}
