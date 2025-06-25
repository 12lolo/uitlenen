<?php

namespace App\Console\Commands;

use App\Models\ApiKey;
use Illuminate\Console\Command;

class GenerateApiKey extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'api:generate-key {name} {--expires=}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Generate a new API key for application access';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $name = $this->argument('name');
        $expires = $this->option('expires');
        
        $expiresAt = $expires ? new \DateTime($expires) : null;
        
        try {
            $apiKey = ApiKey::generate($name, $expiresAt);
            
            $this->info('API key generated successfully!');
            $this->table(
                ['ID', 'Name', 'Key', 'Expires At'],
                [[$apiKey->id, $apiKey->name, $apiKey->key, $apiKey->expires_at ? $apiKey->expires_at->format('Y-m-d H:i:s') : 'Never']]
            );
            
            $this->info('Make sure to copy this key now as it won\'t be fully displayed again for security reasons.');
        } catch (\Exception $e) {
            $this->error("Error generating API key: {$e->getMessage()}");
        }
    }
}
