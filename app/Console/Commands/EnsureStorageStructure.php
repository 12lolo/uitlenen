<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\File;

class EnsureStorageStructure extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:ensure-storage-structure';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Ensure storage directory structure exists with proper permissions';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Ensuring storage directory structure...');

        // Define directories to create and make writable
        $directories = [
            storage_path('app/public'),
            storage_path('framework/cache'),
            storage_path('framework/sessions'),
            storage_path('framework/views'),
            storage_path('framework/testing'),
            storage_path('logs'),
            base_path('bootstrap/cache'),
        ];

        // Create specific log files if they don't exist
        $logFiles = [
            storage_path('logs/laravel.log'),
            storage_path('logs/scheduler.log'),
            storage_path('logs/reminder-due.log'),
            storage_path('logs/reminder-overdue.log'),
            storage_path('logs/prune-invitations.log'),
            storage_path('logs/storage-structure.log'),
        ];

        // Create directories
        foreach ($directories as $directory) {
            if (!File::exists($directory)) {
                File::makeDirectory($directory, 0775, true);
                $this->info("Created directory: {$directory}");
            }

            // Ensure directory is writable
            if (!is_writable($directory)) {
                chmod($directory, 0775);
                $this->info("Made directory writable: {$directory}");
            }
        }

        // Create log files
        foreach ($logFiles as $logFile) {
            if (!File::exists($logFile)) {
                File::put($logFile, "");
                chmod($logFile, 0664);
                $this->info("Created log file: {$logFile}");
            }
        }

        $this->info('Storage directory structure is ready!');
        
        return Command::SUCCESS;
    }
}
