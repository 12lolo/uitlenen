#!/bin/bash
# Script to deploy admin functionality fixes to production

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===== DEPLOYING ADMIN FUNCTIONALITY FIXES =====${NC}"

# 1. Backup the original files
echo -e "${GREEN}Creating backup of original files...${NC}"
cd /home/senne/projects/uitlenen
mkdir -p backups/$(date +%Y%m%d)
cp app/Http/Controllers/UserController.php backups/$(date +%Y%m%d)/UserController.php.bak

# 2. Create a zip file of the modified files
echo -e "${GREEN}Creating zip file of modified files...${NC}"
zip -j admin_fix.zip app/Http/Controllers/UserController.php

# 3. Upload the files to the production server
echo -e "${GREEN}Uploading files to production server...${NC}"
# NOTE: This command would need to be adjusted with your actual server details
# scp admin_fix.zip user@uitleensysteemfirda.nl:/tmp/

# 4. Commands to run on the server (this would be executed via SSH)
echo -e "${GREEN}Commands to run on the production server:${NC}"
echo "
# Extract the files
cd /var/www/uitleensysteemfirda.nl
cp app/Http/Controllers/UserController.php app/Http/Controllers/UserController.php.bak
unzip -o /tmp/admin_fix.zip -d app/Http/Controllers/
rm /tmp/admin_fix.zip

# Clear Laravel cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Set proper permissions
chown -R www-data:www-data app/Http/Controllers/
chmod 644 app/Http/Controllers/UserController.php
"

# 5. Local file to test on your development environment
echo -e "${GREEN}Creating a test script to verify the changes...${NC}"
cat << 'EOF' > verify_admin_fix.php
<?php
// Verify admin functionality fix

$token = "5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585";
$baseUrl = "https://uitleensysteemfirda.nl/api";

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

echo "Verifying admin functionality fix:\n\n";

// 1. Test getting all users
$result = makeRequest('GET', '/users');
echo "GET /users status code: " . $result['code'] . "\n";
if ($result['code'] == 200) {
    echo "✅ Success! Admin user listing is working.\n";
    echo "Users found: " . count($result['response']) . "\n\n";
} else {
    echo "❌ Error: Admin user listing still not working.\n";
    print_r($result['response']);
    echo "\n";
}

// 2. Test creating a new user
$testEmail = "test" . time() . "@firda.nl";
$result = makeRequest('POST', '/users', [
    'email' => $testEmail,
    'is_admin' => false
]);

echo "POST /users status code: " . $result['code'] . "\n";
if ($result['code'] == 201) {
    echo "✅ Success! Admin user creation is working.\n";
    echo "New user created with email: " . $testEmail . "\n";
    echo "Temporary password: " . ($result['response']['temp_password'] ?? 'Not provided') . "\n";
} else {
    echo "❌ Error: Admin user creation still not working.\n";
    print_r($result['response']);
}
EOF

chmod +x verify_admin_fix.php

echo -e "${YELLOW}===== ADMIN FUNCTIONALITY FIXES PREPARED =====${NC}"
echo -e "${GREEN}Note: You need to manually upload admin_fix.zip to the server and run the commands.${NC}"
echo -e "${GREEN}After deployment, run php verify_admin_fix.php to verify the fix.${NC}"
