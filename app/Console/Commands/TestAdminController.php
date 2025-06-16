<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class TestAdminController extends Command
{
    protected $signature = 'test:admin';
    protected $description = 'Test the admin controller functionality';

    public function handle()
    {
        $this->info('Testing UserController functionality directly...');
        
        try {
            // Create a test instance of the controller
            $controller = new \App\Http\Controllers\UserController();
            
            // Test the index method
            $this->info('Testing index method...');
            $response = $controller->index();
            $data = json_decode($response->getContent(), true);
            
            $this->info('Response status: ' . $response->getStatusCode());
            $this->info('Users found: ' . count($data));
            
            // Test the store method with a mock request
            $this->info("\nTesting store method...");
            $request = new \Illuminate\Http\Request();
            $email = 'test' . time() . '@firda.nl';
            $request->merge([
                'email' => $email,
                'is_admin' => false
            ]);
            
            $storeResponse = $controller->store($request);
            $storeData = json_decode($storeResponse->getContent(), true);
            
            $this->info('Store response status: ' . $storeResponse->getStatusCode());
            $this->info('User created: ' . ($storeResponse->getStatusCode() === 201 ? 'Yes' : 'No'));
            if (isset($storeData['user']['id'])) {
                $this->info('New user ID: ' . $storeData['user']['id']);
            }
            if (isset($storeData['temp_password'])) {
                $this->info('Temp password: ' . $storeData['temp_password']);
            }
            
            // Test simple controller if it exists
            if (class_exists('\App\Http\Controllers\SimpleUserController')) {
                $this->info("\nTesting SimpleUserController...");
                $simpleController = new \App\Http\Controllers\SimpleUserController();
                $simpleResponse = $simpleController->index();
                $simpleData = json_decode($simpleResponse->getContent(), true);
                
                $this->info('Simple response status: ' . $simpleResponse->getStatusCode());
                $this->info('Simple users found: ' . count($simpleData));
                
                // Test simple store method
                $this->info("\nTesting simple store method...");
                $simpleEmail = 'simple_test' . time() . '@firda.nl';
                $request->merge([
                    'email' => $simpleEmail,
                    'is_admin' => false
                ]);
                
                $simpleStoreResponse = $simpleController->store($request);
                $simpleStoreData = json_decode($simpleStoreResponse->getContent(), true);
                
                $this->info('Simple store response status: ' . $simpleStoreResponse->getStatusCode());
                $this->info('Simple user created: ' . ($simpleStoreResponse->getStatusCode() === 201 ? 'Yes' : 'No'));
                if (isset($simpleStoreData['user']['id'])) {
                    $this->info('New simple user ID: ' . $simpleStoreData['user']['id']);
                }
            }
            
            $this->info("\nTest completed successfully!");
            return 0;
        } catch (\Exception $e) {
            $this->error('Error: ' . $e->getMessage());
            $this->error($e->getTraceAsString());
            return 1;
        }
    }
}
