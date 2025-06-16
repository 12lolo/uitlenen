<?php

namespace App\Console;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;

class Kernel extends ConsoleKernel
{
    /**
     * Define the application's command schedule.
     */
    protected function schedule(Schedule $schedule): void
    {
        // Run email reminders every day at 8:00 AM
        $schedule->command('email:reminders')->dailyAt('08:00');
        
        // Prune expired invitations every 6 hours
        $schedule->command('app:prune-expired-invitations')->everyHours(6);
        
        // Ensure storage structure daily
        $schedule->command('app:ensure-storage-structure')->daily()->at('01:00')
            ->appendOutputTo(storage_path('logs/storage-structure.log'));
    }

    /**
     * Register the commands for the application.
     */
    protected function commands(): void
    {
        $this->load(__DIR__.'/Commands');

        require base_path('routes/console.php');
    }
}
