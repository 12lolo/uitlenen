#!/bin/bash
# Script to test the database connection on the server

# Connect to server
echo "Testing database connection..."
echo "Please provide the correct database credentials:"
read -p "Database host (default: localhost): " DB_HOST
DB_HOST=${DB_HOST:-localhost}

read -p "Database name (default: u540587252_uitlenen): " DB_DATABASE
DB_DATABASE=${DB_DATABASE:-u540587252_uitlenen}

read -p "Database username (default: u540587252_uitlenen): " DB_USERNAME
DB_USERNAME=${DB_USERNAME:-u540587252_uitlenen}

read -sp "Database password: " DB_PASSWORD
echo ""

# Create a temporary PHP script to test the connection
cat > db_test.php << EOL
<?php
\$host = '$DB_HOST';
\$db   = '$DB_DATABASE';
\$user = '$DB_USERNAME';
\$pass = '$DB_PASSWORD';
\$charset = 'utf8mb4';

\$dsn = "mysql:host=\$host;dbname=\$db;charset=\$charset";
\$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];

echo "Testing connection to \$db on \$host as \$user...\\n";

try {
    \$pdo = new PDO(\$dsn, \$user, \$pass, \$options);
    echo "Connection successful!\\n";
    
    // Test if we can create tables
    \$pdo->exec("CREATE TABLE IF NOT EXISTS test_connection (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255))");
    echo "Test table created successfully.\\n";
    
    // Clean up test table
    \$pdo->exec("DROP TABLE test_connection");
    echo "Test table dropped.\\n";
    
    echo "Database permissions verified.\\n";
} catch (PDOException \$e) {
    echo "Connection failed: " . \$e->getMessage() . "\\n";
    exit(1);
}
?>
EOL

# Run the test script
php db_test.php

# If successful, update the .env file with the correct credentials
if [ $? -eq 0 ]; then
    echo "Updating .env file with the correct database credentials..."
    
    # Create or update .env file with the provided credentials
    cat > .env << EOL
APP_NAME="Uitleensysteem Firda"
APP_ENV=production
APP_KEY=base64:fLJy1/qP6VuNUzqkdX7SdC2vqkAGMh1Dy/cdfnzrPXU=
APP_DEBUG=false
APP_URL=https://uitleensysteemfirda.nl

APP_LOCALE=nl
APP_FALLBACK_LOCALE=nl
APP_FAKER_LOCALE=nl_NL

BCRYPT_ROUNDS=12

LOG_CHANNEL=stack
LOG_STACK=single
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=$DB_HOST
DB_PORT=3306
DB_DATABASE=$DB_DATABASE
DB_USERNAME=$DB_USERNAME
DB_PASSWORD=$DB_PASSWORD

SESSION_DRIVER=database
SESSION_LIFETIME=120

CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync

# Mail configuration
MAIL_MAILER=smtp
MAIL_HOST=smtp.hostinger.com
MAIL_PORT=465
MAIL_USERNAME=info@uitleensysteemfirda.nl
MAIL_PASSWORD=Uitlenen1!
MAIL_ENCRYPTION=ssl
MAIL_FROM_ADDRESS=info@uitleensysteemfirda.nl
MAIL_FROM_NAME="\${APP_NAME}"

# Sanctum configuration
SANCTUM_STATEFUL_DOMAINS=uitleensysteemfirda.nl
SESSION_DOMAIN=uitleensysteemfirda.nl
EOL

    echo "Running migrations..."
    php artisan migrate --force
    
    echo "Seeding database..."
    php artisan db:seed --force
    
    echo "Setting up storage link..."
    php artisan storage:link
    
    echo "Optimizing application..."
    php artisan optimize
    
    echo "Setup complete!"
else
    echo "Database connection failed. Please check your credentials and try again."
    exit 1
fi

# Cleanup
rm db_test.php
