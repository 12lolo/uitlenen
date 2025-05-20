<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;
use App\Mail\TestEmail;
use Illuminate\Support\Facades\Validator;

class TestController extends Controller
{
    /**
     * Send a test email to verify mail configuration.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function testEmail(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'recipient' => 'required|email',
            'subject' => 'nullable|string|max:255',
            'message' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $recipient = $request->input('recipient');
            $subject = $request->input('subject', 'Test Email from Firda Lending API');
            $message = $request->input('message', 'This is a test email to verify the mail server configuration is working correctly.');

            Mail::to($recipient)->send(new TestEmail($subject, $message));

            return response()->json([
                'status' => 'success',
                'message' => "Test email sent to {$recipient}",
                'mail_config' => [
                    'driver' => config('mail.default'),
                    'host' => config('mail.mailers.smtp.host'),
                    'port' => config('mail.mailers.smtp.port'),
                    'from_address' => config('mail.from.address'),
                    'encryption' => config('mail.mailers.smtp.encryption'),
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to send test email',
                'error' => $e->getMessage(),
                'mail_config' => [
                    'driver' => config('mail.default'),
                    'host' => config('mail.mailers.smtp.host'),
                    'port' => config('mail.mailers.smtp.port'),
                    'from_address' => config('mail.from.address'),
                    'encryption' => config('mail.mailers.smtp.encryption'),
                ]
            ], 500);
        }
    }
}
