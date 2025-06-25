<?php

namespace App\Console\Commands;

use App\Models\ApiKey;
use Illuminate\Console\Command;

class ListApiKeys extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'api:list-keys';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'List all API keys';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $apiKeys = ApiKey::all();
        
        if ($apiKeys->isEmpty()) {
            $this->info('No API keys found.');
            return;
        }
        
        $rows = $apiKeys->map(function ($key) {
            // Only show first 8 characters of the key for security
            $partialKey = substr($key->key, 0, 8) . '...';
            
            return [
                'id' => $key->id,
                'name' => $key->name,
                'key' => $partialKey,
                'active' => $key->active ? 'Yes' : 'No',
                'expires_at' => $key->expires_at ? $key->expires_at->format('Y-m-d H:i:s') : 'Never',
                'created_at' => $key->created_at->format('Y-m-d H:i:s'),
            ];
        })->toArray();
        
        $this->table(
            ['ID', 'Name', 'Key (partial)', 'Active', 'Expires At', 'Created At'],
            $rows
        );
    }
}
