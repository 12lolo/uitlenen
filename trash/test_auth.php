<?php
// A simple script to test authentication with the API

$token = "5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585";
$url = "https://uitleensysteemfirda.nl/api/user"; // Endpoint to get current user info

echo "Testing authentication with token...\n";

// Initialize cURL
$ch = curl_init($url);

// Set cURL options
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Authorization: Bearer ' . $token
]);
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
    
    if ($info["http_code"] == 200) {
        echo "\nAuthentication successful! The token is valid.\n";
        $user = json_decode($response, true);
        echo "Logged in as: " . $user['name'] . " (" . $user['email'] . ")\n";
        echo "Admin privileges: " . ($user['is_admin'] ? "Yes" : "No") . "\n";
    } else {
        echo "\nAuthentication failed. The token may be invalid or expired.\n";
    }
}

// Close cURL handle
curl_close($ch);
