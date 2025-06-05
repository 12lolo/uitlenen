#!/bin/bash

# This script tests the email reminder system by running both the scheduler and the command directly
# Since time simulation doesn't actually work with Laravel scheduler without more complex code,
# this script just runs the commands and shows the results.

echo "====== Testing Email Reminder System ======"

# Run the scheduler
echo "1. Running Laravel scheduler..."
php artisan schedule:run

# Run the email reminders command directly
echo "2. Running email reminders command directly..."
php artisan email:reminders

echo "Scheduler test completed!"
echo ""
echo "Note: To create test loans and test the full reminder system, use:"
echo "./test_email_reminders.sh"
