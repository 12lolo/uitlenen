<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #eee; border-radius: 5px;">
    <h2 style="color: #333;">Activeer uw {{ config('app.name') }} account</h2>
    <p>Hallo,</p>
    <p>U bent uitgenodigd om een account aan te maken op {{ config('app.name') }}. Om uw account te activeren, klikt u op de onderstaande knop om uw e-mailadres te verifiëren:</p>
    <div style="text-align: center; margin: 30px 0;">
        <a href="{{ $verificationUrl }}" style="background-color: #4CAF50; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px; font-weight: bold;">E-mailadres verifiëren</a>
    </div>
    <p>Na verificatie kunt u uw account instellen door uw naam en een wachtwoord in te stellen.</p>
    <p>Als u niet op de knop kunt klikken, kopieer dan deze URL en plak deze in uw browser:</p>
    <p style="word-break: break-all;">{{ $verificationUrl }}</p>
    <p>Deze link is 6 uur geldig. Als u niet binnen 6 uur verifieert, moet er een nieuwe uitnodiging worden aangevraagd.</p>
    <p>Met vriendelijke groet,<br>Het team van {{ config('app.name') }}</p>
</div>
