<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class VerifyUser extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:verify-user {email : The email of the user to verify}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Manually verify a user and mark their setup as completed';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $email = $this->argument('email');
        
        $user = User::where('email', $email)->first();
        
        if (!$user) {
            $this->error("User with email {$email} not found!");
            return 1;
        }
        
        // Mark email as verified
        if (!$user->hasVerifiedEmail()) {
            $user->markEmailAsVerified();
            $this->info("Email verified for {$email}");
        } else {
            $this->line("Email already verified for {$email}");
        }
        
        // Mark setup as completed
        if (!$user->setup_completed) {
            $user->setup_completed = true;
            $user->save();
            $this->info("Setup marked as completed for {$email}");
        } else {
            $this->line("Setup already completed for {$email}");
        }
        
        $this->info("User {$email} is now fully verified and setup is completed.");
        
        return 0;
    }
}
