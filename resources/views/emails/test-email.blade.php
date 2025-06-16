<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>{{ $emailSubject }}</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
        }
        .header {
            background-color: #2563eb;
            color: white;
            padding: 20px;
            text-align: center;
        }
        .content {
            padding: 20px;
            background-color: #f9fafb;
        }
        .footer {
            background-color: #f3f4f6;
            padding: 15px;
            text-align: center;
            font-size: 14px;
            color: #6b7280;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Test Email</h1>
    </div>

    <div class="content">
        <p>{{ $emailMessage }}</p>

        <p>This email was sent at: {{ now()->format('Y-m-d H:i:s') }}</p>

        <p>If you're receiving this email, your mail server configuration is working correctly!</p>

        <p>Mail configuration details:</p>
        <ul>
            <li>Driver: {{ config('mail.default') }}</li>
            <li>Host: {{ config('mail.mailers.smtp.host') }}</li>
            <li>Port: {{ config('mail.mailers.smtp.port') }}</li>
            <li>From Address: {{ config('mail.from.address') }}</li>
            <li>Encryption: {{ config('mail.mailers.smtp.encryption') }}</li>
        </ul>
    </div>

    <div class="footer">
        <p>This is an automated test email from the Firda Lending API. No action is required.</p>
    </div>
</body>
</html>
