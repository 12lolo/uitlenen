<?php
// A simple script to test creating an item using the API with cURL

$token = "5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585";
$url = "https://uitleensysteemfirda.nl/api/items";

// First, let's check if we can access the site at all
echo "Testing connection to the website...\n";
$testCh = curl_init("https://uitleensysteemfirda.nl");
curl_setopt($testCh, CURLOPT_RETURNTRANSFER, true);
curl_setopt($testCh, CURLOPT_HEADER, true);
curl_setopt($testCh, CURLOPT_NOBODY, true);
curl_exec($testCh);
$testInfo = curl_getinfo($testCh);
curl_close($testCh);

echo "Website status code: " . $testInfo["http_code"] . "\n\n";

// Now try creating an item
echo "Attempting to create a new item...\n";

$data = [
    "title" => "Test Smartphone",
    "description" => "Testing smartphone item creation",
    "category_id" => 1,
    "status" => "available",
    "location" => "IT Storage Room",
    "inventory_number" => "INV-TEST-001"
];

// Initialize cURL
$ch = curl_init($url);

// Set cURL options
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Authorization: Bearer ' . $token
]);
curl_setopt($ch, CURLOPT_VERBOSE, true);
curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);

// Execute cURL request
$response = curl_exec($ch);
$info = curl_getinfo($ch);

// Check for errors
if (curl_errno($ch)) {
    echo "cURL Error: " . curl_error($ch) . "\n";
} else {
    echo "HTTP Status Code: " . $info["http_code"] . "\n";
    echo "Response:\n";
    echo $response . "\n";
    
    // Let's try to get all items to see if our item was created
    echo "\nRetrieving all items to check if creation was successful...\n";
    $getItemsCh = curl_init("https://uitleensysteemfirda.nl/api/items");
    curl_setopt($getItemsCh, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($getItemsCh, CURLOPT_HTTPHEADER, [
        'Authorization: Bearer ' . $token
    ]);
    $itemsResponse = curl_exec($getItemsCh);
    curl_close($getItemsCh);
    
    if ($itemsResponse) {
        $items = json_decode($itemsResponse, true);
        echo "Total items: " . count($items) . "\n";
        
        // Search for our newly created item
        $found = false;
        foreach ($items as $item) {
            if (isset($item['title']) && $item['title'] === 'Test Smartphone') {
                echo "Found our newly created item with ID: " . $item['id'] . "\n";
                $found = true;
                break;
            }
        }
        
        if (!$found) {
            echo "Our newly created item was not found in the list.\n";
        }
    } else {
        echo "Failed to retrieve items list.\n";
    }
}

// Close cURL handle
curl_close($ch);
