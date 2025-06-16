<?php
// A simple PHP script to test update and delete operations with the API

$token = "5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585";
$baseUrl = "https://uitleensysteemfirda.nl/api";

// Function to make API requests
function makeRequest($method, $endpoint, $data = null) {
    global $token, $baseUrl;
    
    $ch = curl_init($baseUrl . $endpoint);
    
    // Set common options
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Authorization: Bearer ' . $token
    ]);
    
    // For POST or PUT requests, add the JSON data
    if ($data && ($method == 'POST' || $method == 'PUT')) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    }
    
    // Execute the request
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    return [
        'code' => $httpCode,
        'response' => json_decode($response, true)
    ];
}

// Test 1: Create a new test item
echo "===== TESTING API UPDATE AND DELETE OPERATIONS =====\n\n";

echo "1. Creating a new test item...\n";
$createItemResult = makeRequest('POST', '/items', [
    'title' => 'PHP Test Item',
    'description' => 'Created for update/delete testing',
    'category_id' => 1,
    'status' => 'available',
    'location' => 'Test Location',
    'inventory_number' => 'PHP-TEST-001'
]);

print_r($createItemResult);

// Extract the item ID for later use
$itemId = $createItemResult['response']['item']['id'] ?? null;

if (!$itemId) {
    die("Failed to create test item. Aborting tests.\n");
}

echo "\n2. Updating the test item (ID: $itemId)...\n";
$updateItemResult = makeRequest('PUT', "/items/$itemId", [
    'title' => 'Updated PHP Test Item',
    'description' => 'This item has been updated via PHP',
    'category_id' => 1,
    'status' => 'unavailable',
    'location' => 'New Test Location',
    'inventory_number' => 'PHP-TEST-001-UPDATED'
]);

print_r($updateItemResult);

echo "\n3. Getting the updated item to verify changes...\n";
$getItemResult = makeRequest('GET', "/items/$itemId");
print_r($getItemResult);

echo "\n4. Deleting the test item (ID: $itemId)...\n";
$deleteItemResult = makeRequest('DELETE', "/items/$itemId");
print_r($deleteItemResult);

echo "\n5. Verifying the item was deleted...\n";
$verifyDeleteResult = makeRequest('GET', "/items/$itemId");
print_r($verifyDeleteResult);

echo "\n===== API TESTING COMPLETED =====\n";
