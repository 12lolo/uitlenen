#!/bin/bash
# Script to set up cron jobs for the application

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

echo -e "${GREEN}=== Setting up cron jobs for Laravel scheduler ===${NC}"

# Connect to SSH and set up cron jobs
ssh -p $SSH_PORT $SSH_USER@$SSH_HOST << 'EOF'
cd /home/u540587252/domains/uitleensysteemfirda.nl/public_html

# Create a temporary crontab file
(crontab -l 2>/dev/null || echo "") > crontab_temp

# Add Laravel scheduler if not already there
if ! grep -q "artisan schedule:run" crontab_temp; then
    echo "* * * * * cd /home/u540587252/domains/uitleensysteemfirda.nl/public_html && php artisan schedule:run >> storage/logs/scheduler.log 2>&1" >> crontab_temp
    echo "Added Laravel scheduler to crontab"
else
    echo "Laravel scheduler already in crontab"
fi

# Add email reminder cronjob if needed (adjust timing as needed)
if ! grep -q "artisan reminder:send-due" crontab_temp; then
    echo "0 8 * * * cd /home/u540587252/domains/uitleensysteemfirda.nl/public_html && php artisan reminder:send-due >> storage/logs/reminder-due.log 2>&1" >> crontab_temp
    echo "Added due reminder cron job"
else
    echo "Due reminder cron job already exists"
fi

if ! grep -q "artisan reminder:send-overdue" crontab_temp; then
    echo "0 8 * * * cd /home/u540587252/domains/uitleensysteemfirda.nl/public_html && php artisan reminder:send-overdue >> storage/logs/reminder-overdue.log 2>&1" >> crontab_temp
    echo "Added overdue reminder cron job"
else
    echo "Overdue reminder cron job already exists"
fi

# Add storage structure maintenance job (runs daily at 1 AM)
if ! grep -q "artisan app:ensure-storage-structure" crontab_temp; then
    echo "0 1 * * * cd /home/u540587252/domains/uitleensysteemfirda.nl/public_html && php artisan app:ensure-storage-structure >> storage/logs/storage-structure.log 2>&1" >> crontab_temp
    echo "Added storage structure maintenance job (runs daily at 1 AM)"
else
    echo "Storage structure maintenance job already exists"
fi

# Add expired invitations cleanup job (runs every 6 hours)
if ! grep -q "artisan app:prune-expired-invitations" crontab_temp; then
    echo "0 */6 * * * cd /home/u540587252/domains/uitleensysteemfirda.nl/public_html && php artisan app:prune-expired-invitations >> storage/logs/prune-invitations.log 2>&1" >> crontab_temp
    echo "Added invitation cleanup cron job (runs every 6 hours)"
else
    # Update existing job to run every 6 hours if it's set to daily
    sed -i 's/0 0 \* \* \* cd \/home\/u540587252\/domains\/uitleensysteemfirda\.nl\/public_html && php artisan app:prune-expired-invitations/0 \*\/6 \* \* \* cd \/home\/u540587252\/domains\/uitleensysteemfirda\.nl\/public_html \&\& php artisan app:prune-expired-invitations >> storage\/logs\/prune-invitations.log 2>\&1/g' crontab_temp
    echo "Updated invitation cleanup cron job to run every 6 hours"
fi

# Install the new crontab
crontab crontab_temp
rm crontab_temp

# Verify crontab was set
echo -e "\nCurrent crontab:"
crontab -l

echo -e "\nCron jobs have been set up successfully!"
EOF

echo -e "\n${GREEN}=== Cron setup completed ===${NC}"
