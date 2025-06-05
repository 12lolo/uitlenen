# Email Reminder Automation Guide

This guide explains how to set up the automatic reminder system for your loan management application to send reminder emails every morning at 8:00 AM.

## How Reminders Work

Your application is configured to:

1. Check for loans due tomorrow and send due reminders
2. Check for loans that became overdue yesterday and send overdue reminders

The system uses Laravel's scheduler to automate this process. The scheduler is configured to run the `email:reminders` command every day at 8:00 AM.

## Setting Up Automation on Your Web Hosting

For the scheduled tasks to run automatically, you need to set up a cron job on your web hosting. This cron job will run Laravel's scheduler every minute, and the scheduler will determine which tasks need to be executed.

### Step 1: Access Your Web Hosting Control Panel

Most web hosts provide a control panel (like cPanel, Plesk, etc.) where you can set up cron jobs.

### Step 2: Set Up a Cron Job

Create a new cron job that runs every minute with the following command:

```
* * * * * cd /path-to-your-project && php artisan schedule:run >> /dev/null 2>&1
```

Replace `/path-to-your-project` with the actual path to your Laravel application on the server.

For example, if your application is in `/home/username/public_html/uitlenen`, the command would be:

```
* * * * * cd /home/username/public_html/uitlenen && php artisan schedule:run >> /dev/null 2>&1
```

#### Using the Setup Script

The application includes a helper script that generates the correct cron job command for your system:

```
chmod +x setup_cron.sh
./setup_cron.sh
```

This will output the exact command you should add to your server's crontab.

### Step 3: Verify Your Email Configuration

Make sure your application is configured to send emails correctly. Check your `.env` file for the email settings:

```
MAIL_MAILER=smtp
MAIL_HOST=your-smtp-server.com
MAIL_PORT=587
MAIL_USERNAME=your-email@example.com
MAIL_PASSWORD=your-password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=your-email@example.com
MAIL_FROM_NAME="${APP_NAME}"
```

### Step 4: Test the Reminder System

The application includes two test scripts to help you verify that the reminder system is working correctly:

#### Basic Command Test

You can manually test the reminder email command by running:

```
php artisan email:reminders
```

This will check for any loans due tomorrow or overdue yesterday and send reminder emails accordingly.

#### Complete Testing with Test Data

For a more thorough test that creates test loans and sends real emails:

```
chmod +x test_email_reminders.sh
./test_email_reminders.sh
```

This script will:
1. Create a test loan due tomorrow with email "test@example.com"
2. Create a test loan that is overdue with email "overdue@example.com"
3. Run the email reminders command
4. Show you how to clean up the test data

#### Testing the Scheduler

If you want to test that your scheduled task is configured correctly:

```
./test_scheduler.sh
```

This will run both the Laravel scheduler and the email reminders command directly to show you what would happen.

## Troubleshooting

If reminders aren't being sent:

1. **Check Cron Job**: Verify that your cron job is running correctly. Most hosting providers provide a log of cron job executions.

2. **Check Laravel Logs**: Look at `storage/logs/laravel.log` for any errors related to the scheduler or email sending.

3. **Test Email Sending**: Use the test email route to verify that your application can send emails:
   ```
   POST /api/test/email
   {
     "recipient": "your-email@example.com",
     "subject": "Test Email",
     "message": "Testing the email system"
   }
   ```

4. **Check the Database**: Verify that your loans have the correct due dates and student email addresses.

## Understanding the Code

The reminder system consists of:

- **SendReminderEmails Command**: Located at `app/Console/Commands/SendReminderEmails.php`, this is the command that checks for due and overdue loans and sends emails.

- **Laravel Scheduler**: Configured in `app/Console/Kernel.php` to run the command daily at 8:00 AM.

- **Email Templates**: Located at `resources/views/emails/due-reminder.blade.php` and `resources/views/emails/overdue-reminder.blade.php`.
