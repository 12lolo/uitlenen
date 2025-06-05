#!/bin/bash

# This script helps test the entire reminder email system
# It will create test data and run the email reminders command

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}====== Testing Loan Reminder System ======${NC}"

# Step 1: Create a test loan that's due tomorrow
echo -e "${BLUE}Step 1: Creating test data...${NC}"

# Get tomorrow's date in Y-m-d format
TOMORROW=$(date -d "tomorrow" +%Y-%m-%d)
# Get yesterday's date in Y-m-d format
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d)

# Create a test record directly in the database for a loan due tomorrow
echo -e "Creating a loan due tomorrow (${TOMORROW})..."
php artisan tinker --execute="
    \$item = \App\Models\Item::first();
    if (!\$item) {
        echo 'No items found in the database. Please create some items first.';
        exit;
    }
    
    // Create a loan due tomorrow
    \$tomorrowLoan = new \App\Models\Loan();
    \$tomorrowLoan->item_id = \$item->id;
    \$tomorrowLoan->student_name = 'Test Student';
    \$tomorrowLoan->student_email = 'test@example.com';
    \$tomorrowLoan->loaned_at = now();
    \$tomorrowLoan->due_date = '$TOMORROW';
    \$tomorrowLoan->notes = 'Test loan due tomorrow';
    \$tomorrowLoan->user_id = 1;
    \$tomorrowLoan->save();
    
    echo 'Created loan #' . \$tomorrowLoan->id . ' due tomorrow';
    
    // Create a loan due yesterday (overdue)
    \$overdueLoan = new \App\Models\Loan();
    \$overdueLoan->item_id = \$item->id;
    \$overdueLoan->student_name = 'Overdue Student';
    \$overdueLoan->student_email = 'overdue@example.com';
    \$overdueLoan->loaned_at = now()->subDays(7);
    \$overdueLoan->due_date = '$YESTERDAY';
    \$overdueLoan->notes = 'Test loan that is overdue';
    \$overdueLoan->user_id = 1;
    \$overdueLoan->save();
    
    echo '\nCreated loan #' . \$overdueLoan->id . ' that is overdue';
"

# Step 2: Run the email reminders command
echo -e "\n${BLUE}Step 2: Running email reminders command...${NC}"
php artisan email:reminders

echo -e "\n${GREEN}Test completed!${NC}"
echo -e "${GREEN}If your email system is configured correctly, emails should have been sent to:${NC}"
echo -e "- test@example.com (due tomorrow reminder)"
echo -e "- overdue@example.com (overdue reminder)"
echo -e "\n${BLUE}Note:${NC} To check if emails were actually sent, look at your email configuration"
echo -e "and check the mail logs or the mailbox for the test addresses."
echo -e "\n${BLUE}To clean up the test data, run:${NC}"
echo -e "php artisan tinker --execute=\"\\App\\Models\\Loan::where('student_email', 'test@example.com')->orWhere('student_email', 'overdue@example.com')->delete();\""
