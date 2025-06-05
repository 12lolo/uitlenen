<?php

namespace Tests\Feature;

use App\Models\User;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\URL;
use Tests\TestCase;

class InvitationExpiryTest extends TestCase
{
    use RefreshDatabase;

    public function test_expired_invitation_returns_error(): void
    {
        // Create a user with an expired invitation (over 6 hours old)
        $user = User::factory()->create([
            'email_verified_at' => null,
            'setup_completed' => false,
            'invitation_sent_at' => Carbon::now()->subHours(7)
        ]);

        // Generate verification URL
        $verificationUrl = URL::temporarySignedRoute(
            'verification.verify',
            Carbon::now()->addMinutes(360),
            [
                'id' => $user->id,
                'hash' => sha1($user->email),
            ]
        );

        // Parse URL to get the path and query
        $parsedUrl = parse_url($verificationUrl);
        $path = $parsedUrl['path'];
        parse_str($parsedUrl['query'], $query);

        // Make request to verification endpoint
        $response = $this->get($path . '?' . http_build_query($query));

        // Assert the response includes an expired invitation message
        $response->assertStatus(403)
                 ->assertJson([
                     'message' => 'Uitnodiging is verlopen. Vraag een nieuwe uitnodiging aan.',
                     'invitation_expired' => true
                 ]);
    }

    public function test_active_invitation_allows_verification(): void
    {
        // Create a user with a valid invitation (less than 6 hours old)
        $user = User::factory()->create([
            'email_verified_at' => null,
            'setup_completed' => false,
            'invitation_sent_at' => Carbon::now()->subHours(5)
        ]);

        // Generate verification URL
        $verificationUrl = URL::temporarySignedRoute(
            'verification.verify',
            Carbon::now()->addMinutes(360),
            [
                'id' => $user->id,
                'hash' => sha1($user->email),
            ]
        );

        // Parse URL to get the path and query
        $parsedUrl = parse_url($verificationUrl);
        $path = $parsedUrl['path'];
        parse_str($parsedUrl['query'], $query);

        // Make request to verification endpoint
        $response = $this->get($path . '?' . http_build_query($query));

        // Assert the response does not include an expired invitation message
        $response->assertStatus(200);
    }
}
