#!/bin/bash

# Get the current directory (absolute path to the Laravel project)
LARAVEL_PATH=$(pwd)

# Generate cron job command
CRON_CMD="* * * * * cd $LARAVEL_PATH && php artisan schedule:run >> /dev/null 2>&1"

echo "Here's the cron job command you should add to your server:"
echo ""
echo "$CRON_CMD"
echo ""
echo "To add this to your crontab, run:"
echo "crontab -e"
echo ""
echo "Then add the line above to the file and save it."
echo ""
echo "If you're using a hosting control panel, copy the cron job command and paste it into your hosting's cron job interface."
