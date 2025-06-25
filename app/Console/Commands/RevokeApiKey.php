<?php

namespace App\Console\Commands;

use App\Models\ApiKey;
use Illuminate\Console\Command;

class RevokeApiKey extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'api:revoke-key {id : The ID of the API key to revoke}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Revoke (deactivate) an API key';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $id = $this->argument('id');
        
        try {
            $apiKey = ApiKey::findOrFail($id);
            
            if (!$apiKey->active) {
                $this->info("API key '{$apiKey->name}' is already inactive.");
                return;
            }
            
            if (!$this->confirm("Are you sure you want to revoke the API key '{$apiKey->name}'?")) {
                $this->info('Operation cancelled.');
                return;
            }
            
            $apiKey->active = false;
            $apiKey->save();
            
            $this->info("API key '{$apiKey->name}' has been revoked successfully.");
        } catch (\Exception $e) {
            $this->error("Error revoking API key: {$e->getMessage()}");
        }
    }
}
