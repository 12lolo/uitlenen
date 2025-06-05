<?php

namespace App\Console\Commands;

use App\Models\User;
use Carbon\Carbon;
use Illuminate\Console\Command;

class PruneExpiredInvitations extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:prune-expired-invitations';    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Remove user accounts with expired invitations (older than 6 hours and not verified)';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $cutoffTime = Carbon::now()->subHours(6);

        // Find users with expired invitations
        $expiredUsers = User::whereNull('email_verified_at')
            ->where('setup_completed', false)
            ->where('invitation_sent_at', '<', $cutoffTime)
            ->get();

        $count = $expiredUsers->count();

        if ($count > 0) {
            foreach ($expiredUsers as $user) {
                $this->info("Removing expired invitation for: {$user->email}");
                $user->delete();
            }

            $this->info("{$count} expired invitation(s) removed.");
        } else {
            $this->info("No expired invitations found.");
        }

        return 0;
    }
}
