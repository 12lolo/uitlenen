#!/bin/bash
# Production environment check script
# This script checks the status of the production environment

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# SSH connection details
SSH_USER="u540587252"
SSH_HOST="92.113.19.61"
SSH_PORT="65002"
REMOTE_PATH="/home/u540587252/domains/uitleensysteemfirda.nl/public_html"

echo -e "${GREEN}=== Checking Production Environment ===${NC}"

# Connect to SSH and run checks
ssh -p $SSH_PORT $SSH_USER@$SSH_HOST << 'EOF'
cd /home/u540587252/domains/uitleensysteemfirda.nl/public_html

echo -e "\n=== System Information ==="
php -v
echo ""
php -m | grep -E "pdo_mysql|mbstring|openssl|tokenizer|xml|ctype|json|bcmath|fileinfo"

echo -e "\n=== Laravel Version ==="
php artisan --version

echo -e "\n=== Storage Permissions ==="
ls -la storage/
ls -la bootstrap/cache/

echo -e "\n=== Environment ==="
grep -E "^APP_ENV|^APP_DEBUG|^APP_URL" .env

echo -e "\n=== Database Connection ==="
php artisan migrate:status --no-ansi | head -n 10

echo -e "\n=== File Structure ==="
find . -maxdepth 1 -type f -name "*.sh" | sort
find . -type d -maxdepth 1 | sort

echo -e "\n=== Cron Jobs ==="
crontab -l 2>/dev/null || echo "No cron jobs found"

echo -e "\n=== Recent Log Entries ==="
if [ -f "storage/logs/laravel.log" ]; then
  tail -n 10 storage/logs/laravel.log
else
  echo "No log file found"
fi

echo -e "\n=== Server Information ==="
echo "PHP Version: $(php -r 'echo PHP_VERSION;')"
echo "Max Upload Size: $(php -r 'echo ini_get("upload_max_filesize");')"
echo "Max Post Size: $(php -r 'echo ini_get("post_max_size");')"
echo "Memory Limit: $(php -r 'echo ini_get("memory_limit");')"
echo "Max Execution Time: $(php -r 'echo ini_get("max_execution_time");')"

echo -e "\n=== Check Complete ==="
EOF

echo -e "\n${GREEN}=== Production Environment Check Completed ===${NC}"
