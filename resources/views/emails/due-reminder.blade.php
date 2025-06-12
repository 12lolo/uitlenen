<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Herinnering: Je geleend item moet morgen worden ingeleverd</title>
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
        .item-details {
            margin: 20px 0;
            padding: 15px;
            background-color: white;
            border-left: 4px solid #2563eb;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Herinnering Inleveren</h1>
    </div>

    <div class="content">
        <p>Beste lener,</p>

        <p>Dit is een vriendelijke herinnering dat je onderstaand item <strong>morgen</strong> moet inleveren bij Firda:</p>

        <div class="item-details">
            <p><strong>Item:</strong> {{ $loan->item->title }}</p>
            <p><strong>Uitleendatum:</strong> {{ $loan->loan_date->format('d-m-Y') }}</p>
            <p><strong>Inleverdatum:</strong> {{ $loan->return_date->format('d-m-Y') }}</p>
        </div>

        <p>Zorg ervoor dat je het item in goede staat inlevert. Als je niet in staat bent om het item morgen in te leveren, neem dan direct contact op met een docent.</p>

        <p>Met vriendelijke groet,<br>
        Het Firda Uitleensysteem</p>
    </div>

    <div class="footer">
        <p>Deze e-mail is automatisch verzonden vanaf het Firda Uitleensysteem. Niet beantwoorden.</p>
    </div>
</body>
</html>
