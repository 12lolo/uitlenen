<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Belangrijk: Je geleend item is nu te laat</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
        }
        .header {
            background-color: #dc2626;
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
            border-left: 4px solid #dc2626;
        }
        .warning {
            font-weight: bold;
            color: #dc2626;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Te Laat: Actie Vereist</h1>
    </div>

    <div class="content">
        <p>Beste lener,</p>

        <p class="warning">Het volgende item had gisteren ingeleverd moeten worden bij Firda:</p>

        <div class="item-details">
            <p><strong>Item:</strong> {{ $loan->item->title }}</p>
            <p><strong>Uitleendatum:</strong> {{ $loan->loan_date->format('d-m-Y') }}</p>
            <p><strong>Inleverdatum:</strong> {{ $loan->return_date->format('d-m-Y') }}</p>
            <p><strong>Status:</strong> <span class="warning">TE LAAT</span></p>
        </div>

        <p>Lever het item zo snel mogelijk in om verdere maatregelen te voorkomen. Als er omstandigheden zijn waardoor je het item niet kunt inleveren, neem dan direct contact op met een docent.</p>

        <p>Met vriendelijke groet,<br>
        Het Firda Uitleensysteem</p>
    </div>

    <div class="footer">
        <p>Deze e-mail is automatisch verzonden vanaf het Firda Uitleensysteem. Niet beantwoorden.</p>
    </div>
</body>
</html>
