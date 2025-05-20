<?php

namespace App\Http\Controllers;

use App\Models\Loan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;
use Carbon\Carbon;
use App\Mail\DueReminder;
use App\Mail\OverdueReminder;

class NotificationController extends Controller
{
    /**
     * Send email reminders for due and overdue items
     * This endpoint is meant to be called by a cron job
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function sendReminders(Request $request)
    {
        // Security: Check if the request has a valid token
        // In a real app, you would validate a cron token here
        // For now we're skipping that part

        $today = Carbon::today();
        $tomorrow = Carbon::tomorrow();

        // Send reminders for items due tomorrow
        $dueTomorrow = Loan::with(['item', 'item.category'])
            ->whereDate('due_date', $tomorrow)
            ->whereNull('returned_at')
            ->get();

        $dueReminderCount = 0;
        foreach ($dueTomorrow as $loan) {
            Mail::to($loan->student_email)
                ->send(new DueReminder($loan));
            $dueReminderCount++;
        }

        // Send reminders for overdue items (24 hours after due date)
        $yesterday = Carbon::yesterday();
        $overdue = Loan::with(['item', 'item.category'])
            ->whereDate('due_date', $yesterday)
            ->whereNull('returned_at')
            ->get();

        $overdueReminderCount = 0;
        foreach ($overdue as $loan) {
            Mail::to($loan->student_email)
                ->send(new OverdueReminder($loan));
            $overdueReminderCount++;
        }

        return response()->json([
            'message' => 'Herinneringen verstuurd',
            'due_reminders_sent' => $dueReminderCount,
            'overdue_reminders_sent' => $overdueReminderCount
        ]);
    }
}
