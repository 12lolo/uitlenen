<?php

/**
 * Sample PHP client for API key authentication
 * 
 * This script demonstrates how to call API endpoints using an API key in PHP.
 * It uses Guzzle HTTP client for making the requests.
 * 
 * Requirements:
 * - PHP 7.4 or higher
 * - Guzzle HTTP client (can be installed via Composer)
 * 
 * Installation:
 * composer require guzzlehttp/guzzle
 */

require_once 'vendor/autoload.php';

use GuzzleHttp\Client;
use GuzzleHttp\Exception\RequestException;

// Configuration
$apiBaseUrl = 'http://localhost:8000/api'; // Using localhost for local testing
$apiKey = 'Ngh3FZoFwQcba0lT01GxA5mg1rT9qH986049evAQYrcGbyRDOGfMOYkNy9G3gll6'; // The API key we generated

// Create a Guzzle client with default headers
$client = new Client([
    'base_uri' => $apiBaseUrl,
    'headers' => [
        'X-API-KEY' => $apiKey,
        'Accept' => 'application/json',
    ],
]);

/**
 * Make an API call and return the response
 *
 * @param Client $client
 * @param string $endpoint
 * @return array
 */
function callApi(Client $client, string $endpoint): array
{
    try {
        echo "Calling: {$endpoint}\n";
        $response = $client->get($endpoint);
        $data = json_decode($response->getBody(), true);
        
        return [
            'success' => true,
            'data' => $data,
        ];
    } catch (RequestException $e) {
        echo "Error: " . $e->getMessage() . "\n";
        
        return [
            'success' => false,
            'message' => $e->getMessage(),
        ];
    }
}

// Test API endpoints
echo "Testing API Key Authentication...\n";
echo "Using API key: " . substr($apiKey, 0, 8) . "... (truncated for security)\n\n";

// Get available items
$availableItems = callApi($client, '/items/available');
if ($availableItems['success']) {
    echo "Available Items:\n";
    echo json_encode($availableItems['data'], JSON_PRETTY_PRINT) . "\n\n";
}

// Get overdue loans
$overdueLoans = callApi($client, '/lendings/overdue');
if ($overdueLoans['success']) {
    echo "Overdue Loans:\n";
    echo json_encode($overdueLoans['data'], JSON_PRETTY_PRINT) . "\n\n";
}

echo "API testing complete!\n";
