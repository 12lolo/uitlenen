<?php

namespace App\Http\Middleware;

use Closure;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckInvitationExpiry
{
    /**
     * Handle an incoming request and check if the invitation has expired.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Get user from the route parameter
        $userId = $request->route('id') ?? $request->user_id;

        if (!$userId) {
            return $next($request);
        }

        $user = \App\Models\User::find($userId);

        if (!$user) {
            return $next($request);
        }

        // If the user is already verified or setup completed, continue
        if ($user->hasVerifiedEmail() || $user->setup_completed) {
            return $next($request);
        }

        // Check if invitation is older than 6 hours
        if ($user->invitation_sent_at && $user->invitation_sent_at->diffInHours(now()) > 6) {
            return response()->json([
                'message' => 'Uitnodiging is verlopen. Vraag een nieuwe uitnodiging aan.',
                'invitation_expired' => true
            ], 403);
        }

        return $next($request);
    }
}
