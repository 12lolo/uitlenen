<?php
// Verify comprehensive admin functionality fix

$token = "5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585";
// Use local development URL instead of production
$baseUrl = "http://localhost:8000/api";

function makeRequest($method, $endpoint, $data = null) {
    global $token, $baseUrl;
    
    $ch = curl_init($baseUrl . $endpoint);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Authorization: Bearer ' . $token
    ]);
    
    if ($data && ($method == 'POST' || $method == 'PUT')) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    }
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    return [
        'code' => $httpCode,
        'response' => json_decode($response, true)
    ];
}

echo "===== VERIFYING COMPREHENSIVE ADMIN FIX =====\n\n";

// 0. Check the health check endpoint
echo "0. Testing health check endpoint...\n";
$result = makeRequest('GET', '/admin-health-check');
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 200) {
    echo "✅ Admin routes are being loaded correctly.\n\n";
} else {
    echo "❌ Admin routes might not be loaded correctly.\n\n";
}

// 1. Apply the fix
echo "1. Applying the comprehensive fix...\n";
$result = makeRequest('GET', '/comprehensive-admin-fix/fix_admin_june_2025');
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 200) {
    echo "✅ Comprehensive fix applied successfully.\n";
    if (isset($result['response']['actions'])) {
        echo "Actions performed:\n";
        foreach ($result['response']['actions'] as $action) {
            echo "  - " . $action . "\n";
        }
    }
    echo "\n";
} else {
    echo "❌ Failed to apply comprehensive fix.\n";
    if (isset($result['response']['message'])) {
        echo "Error: " . $result['response']['message'] . "\n";
    }
    echo "\n";
}

// 2. Test direct route (no admin middleware)
echo "2. Testing direct route (no admin middleware)...\n";
$result = makeRequest('GET', '/direct-user-test');
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 200) {
    echo "✅ Direct route is working.\n";
    echo "Current user: " . json_encode($result['response']['current_user'] ?? 'Not available') . "\n";
    echo "Number of users: " . count($result['response']['users'] ?? []) . "\n\n";
} else {
    echo "❌ Direct route failed.\n";
    if (isset($result['response']['message'])) {
        echo "Error: " . $result['response']['message'] . "\n";
    }
    echo "\n";
}

// 3. Test standard admin route
echo "3. Testing standard admin route (GET /users)...\n";
$result = makeRequest('GET', '/users');
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 200) {
    echo "✅ Standard admin route is working.\n";
    echo "Number of users: " . count($result['response'] ?? []) . "\n\n";
} else {
    echo "❌ Standard admin route failed.\n";
    if (isset($result['response']['message'])) {
        echo "Error: " . $result['response']['message'] . "\n";
    }
    echo "\n";
}

// 4. Test simple admin route
echo "4. Testing simple admin route (GET /simple-users)...\n";
$result = makeRequest('GET', '/simple-users');
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 200) {
    echo "✅ Simple admin route is working.\n";
    echo "Number of users: " . count($result['response']['users'] ?? []) . "\n\n";
} else {
    echo "❌ Simple admin route failed.\n";
    if (isset($result['response']['message'])) {
        echo "Error: " . $result['response']['message'] . "\n";
    }
    echo "\n";
}

// 5. Test creating a user
$testEmail = "test" . time() . "@firda.nl";
echo "5. Testing user creation (POST /users with email: $testEmail)...\n";
$result = makeRequest('POST', '/users', [
    'email' => $testEmail,
    'is_admin' => false
]);
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 201) {
    echo "✅ User creation is working.\n";
    echo "User ID: " . ($result['response']['user']['id'] ?? 'Not available') . "\n";
    echo "Temporary password: " . ($result['response']['temp_password'] ?? 'Not provided') . "\n\n";
} else {
    echo "❌ User creation failed.\n";
    if (isset($result['response']['message'])) {
        echo "Error: " . $result['response']['message'] . "\n";
    }
    echo "\n";
}

// 6. Test creating a user with simple controller
$testEmail = "simple_test" . time() . "@firda.nl";
echo "6. Testing simple user creation (POST /simple-users with email: $testEmail)...\n";
$result = makeRequest('POST', '/simple-users', [
    'email' => $testEmail,
    'is_admin' => false
]);
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 201) {
    echo "✅ Simple user creation is working.\n";
    echo "User ID: " . ($result['response']['user']['id'] ?? 'Not available') . "\n";
    echo "Temporary password: " . ($result['response']['temp_password'] ?? 'Not provided') . "\n\n";
} else {
    echo "❌ Simple user creation failed.\n";
    if (isset($result['response']['message'])) {
        echo "Error: " . $result['response']['message'] . "\n";
    }
    echo "\n";
}

echo "===== VERIFICATION COMPLETED =====\n";
echo "If any tests failed, please check the server logs for more details.\n";
echo "Log location: /var/www/uitleensysteemfirda.nl/storage/logs/laravel-*.log\n";
