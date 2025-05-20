    /**
     * Define the application's command schedule.
     */
    protected function schedule(Schedule $schedule): void
    {
        // Run email reminders every day at 9:00 AM
        $schedule->command('email:reminders')->dailyAt('09:00');
    }
