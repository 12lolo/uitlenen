<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Carbon\Carbon;
use App\Models\Loan;
use Illuminate\Support\Facades\Mail;
use App\Mail\DueReminder;
use App\Mail\OverdueReminder;

class SendReminderEmails extends Command
{
    protected $signature = 'email:reminders';
    protected $description = 'Send reminder emails for items due soon or overdue';    public function handle()
    {
        $this->sendDueReminders();
        $this->sendOverdueReminders();

        $this->info('Reminder emails sent successfully!');
        return Command::SUCCESS;
    }

    private function sendDueReminders()
    {
        // Find loans that are due in 24 hours
        $tomorrow = Carbon::tomorrow();
        $dueLoans = Loan::whereNull('returned_at')
            ->whereDate('due_date', $tomorrow)
            ->get();        $this->info("Found {$dueLoans->count()} loans due tomorrow");

        foreach ($dueLoans as $loan) {
            // Only send if we have student email
            if ($loan->student_email) {
                Mail::to($loan->student_email)
                    ->send(new DueReminder($loan));

                $this->line("Sent due reminder for loan #{$loan->id}");
            }
        }
    }    private function sendOverdueReminders()
    {
        // Find loans that were due yesterday and still not returned
        $yesterday = Carbon::yesterday();
        $overdueLoans = Loan::whereNull('returned_at')
            ->whereDate('due_date', $yesterday)
            ->get();

        $this->info("Found {$overdueLoans->count()} loans that became overdue yesterday");

        foreach ($overdueLoans as $loan) {
            // Only send if we have student email
            if ($loan->student_email) {
                Mail::to($loan->student_email)
                    ->send(new OverdueReminder($loan));

                $this->line("Sent overdue reminder for loan #{$loan->id}");
            }
        }
    }
}
