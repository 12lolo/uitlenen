# 📄 Functioneel Ontwerp – Uitleen Website & App Firda

## Doel van het systeem
De website en mobiele app maken het mogelijk om het uitleensysteem van Firda eenvoudig te gebruiken. Studenten kunnen items bekijken en hun uitleningen bijhouden. Docenten kunnen het volledige uitleensysteem beheren, inclusief categorieën, items, uitleningen en inspecties. Beide frontends maken gebruik van de bestaande Uitleen-API.

---

## Gebruikersrollen

### 🧑 Student (website en app)
- Kan categorieën bekijken
- Kan items per categorie bekijken
- Ziet van elk item: titel, foto's, omschrijving en status (beschikbaar/uitgeleend)
- Kan eigen uitleningen zien
- Krijgt herinneringen voor inleverdatum (email en push-notificaties)
- Kan QR-code scannen om items te identificeren (alleen in app)

### 👨‍🏫 Docent (website en app)
- Kan inloggen op de website en app
- Kan alle categorieën beheren (toevoegen, aanpassen, verwijderen)
- Kan alle items beheren (toevoegen, aanpassen, verwijderen)
- Kan uitleenregistraties beheren
- Kan andere docenten bekijken
- Krijgt notificaties over inleveringen
- Kan QR-codes scannen voor snel uitlenen/innemen (alleen in app)
- Kan schade bij het terugnemen van items registreren
- Ziet een dashboard met:
    - Items die vandaag teruggebracht moeten worden
    - Items die te laat zijn
    - Statistieken over uitleningen

---

## Functionaliteiten (per platform)

## 🌐 Website Frontend

### 📲 Module: Startpagina

| Eigenschap                 | Omschrijving                                                                                                |
| -------------------------- | ----------------------------------------------------------------------------------------------------------- |
| **Naam**                   | Homepagina van Uitleensysteem                                                                               |
| **Versie**                 | 1.0                                                                                                         |
| **Actor**                  | Student/Docent                                                                                              |
| **Preconditie**            | Gebruiker heeft een browser en toegang tot het internet                                                      |
| **Scenario**               | 1. Gebruiker opent de website<br>2. Ziet welkomstpagina met uitleg over het systeem<br>3. Kan navigeren naar categorieën of items<br>4. Ziet login-optie (voor docenten) |
| **Uitzonderingen**         | - API onbereikbaar<br>- Netwerkproblemen                                                                    |
| **Niet-functionele eisen** | - Laadtijd ≤ 2 sec<br>- Volledig responsive (mobiel, tablet, desktop)<br>- Toegankelijk volgens WCAG 2.1    |
| **Postconditie**           | Gebruiker kan het systeem verkennen of inloggen                                                             |

### 🔐 Module: Inloggen (Website)

| Eigenschap                 | Omschrijving                                                                                                |
| -------------------------- | ----------------------------------------------------------------------------------------------------------- |
| **Naam**                   | Docent inloggen                                                                                             |
| **Versie**                 | 1.0                                                                                                         |
| **Actor**                  | Docent                                                                                                      |
| **Preconditie**            | Docent heeft een geldig account in het systeem                                                              |
| **Scenario**               | 1. Docent klikt op 'Inloggen'<br>2. Voert e-mailadres en wachtwoord in<br>3. Drukt op login-knop<br>4. Wordt doorgestuurd naar docentendashboard |
| **Uitzonderingen**         | - Ongeldige inloggegevens<br>- API onbereikbaar<br>- Account geblokkeerd                                    |
| **Niet-functionele eisen** | - Inlogproces ≤ 3 sec<br>- Duidelijke foutmeldingen<br>- Wachtwoord reset optie beschikbaar                 |
| **Postconditie**           | Docent is ingelogd en heeft toegang tot alle beheerfuncties                                                 |

### 📂 Module: Categorie Overzicht (Website)

| Eigenschap             | Omschrijving                                                                 |
|------------------------|------------------------------------------------------------------------------|
| **Naam**               | Categorieën bekijken                                                         |
| **Versie**             | 1.0                                                                          |
| **Actor**              | Student/Docent                                                               |
| **Preconditie**        | Geen                                                                         |
| **Scenario**           | 1. Gebruiker navigeert naar 'Categorieën'<br>2. Ziet grid of lijst van alle categorieën<br>3. Kan op een categorie klikken om items te zien |
| **Uitzonderingen**     | - Geen categorieën beschikbaar<br>- API onbereikbaar                         |
| **Niet-functionele eisen** | - Weergave binnen 2 sec<br>- Visueel aantrekkelijk grid met afbeeldingen<br>- Zoekveld beschikbaar |
| **Postconditie**       | Gebruiker ziet alle beschikbare categorieën                                  |

### 📦 Module: Items per Categorie (Website)

| Eigenschap             | Omschrijving                                                                 |
|------------------------|------------------------------------------------------------------------------|
| **Naam**               | Items binnen een categorie bekijken                                          |
| **Versie**             | 1.0                                                                          |
| **Actor**              | Student/Docent                                                               |
| **Preconditie**        | Gebruiker heeft een categorie geselecteerd                                   |
| **Scenario**           | 1. Gebruiker klikt op een categorie<br>2. Ziet alle items binnen die categorie<br>3. Kan filteren op beschikbaarheid<br>4. Ziet per item een foto, titel, beschrijving en status |
| **Uitzonderingen**     | - Geen items in deze categorie<br>- API onbereikbaar                         |
| **Niet-functionele eisen** | - Pagination voor grote aantallen items<br>- Filtermogelijkheden<br>- Sorteeropties (naam, beschikbaarheid) |
| **Postconditie**       | Gebruiker ziet alle items binnen de gekozen categorie                        |

### 📊 Module: Docenten Dashboard (Website)

| Eigenschap             | Omschrijving                                                                 |
|------------------------|------------------------------------------------------------------------------|
| **Naam**               | Dashboard voor docenten                                                      |
| **Versie**             | 1.0                                                                          |
| **Actor**              | Docent                                                                       |
| **Preconditie**        | Docent is ingelogd                                                          |
| **Scenario**           | 1. Docent logt in<br>2. Wordt doorgestuurd naar dashboard<br>3. Ziet statistieken, vandaag inleverbare items, te late items<br>4. Heeft snelkoppelingen naar uitlenen, beheer, etc. |
| **Uitzonderingen**     | - Sessie verlopen<br>- API onbereikbaar                                      |
| **Niet-functionele eisen** | - Real-time updates<br>- Duidelijke datavisualisaties<br>- Interactieve elementen |
| **Postconditie**       | Docent heeft overzicht van belangrijke systeem-informatie                    |

### ➕ Module: Item Uitlenen (Website)

| Eigenschap             | Omschrijving                                                                 |
|------------------------|------------------------------------------------------------------------------|
| **Naam**               | Item uitlenen aan student                                                    |
| **Versie**             | 1.0                                                                          |
| **Actor**              | Docent                                                                       |
| **Preconditie**        | Docent is ingelogd, item is beschikbaar                                     |
| **Scenario**           | 1. Docent selecteert 'Nieuw uitlenen'<br>2. Selecteert een item (via zoeken of browsen)<br>3. Voert studentgegevens in<br>4. Stelt retourdatum in<br>5. Bevestigt uitlening |
| **Uitzonderingen**     | - Item niet beschikbaar<br>- Ongeldige studentgegevens<br>- API-fout         |
| **Niet-functionele eisen** | - Zoekfunctie voor items en studenten<br>- Datumpicker voor retourdatum<br>- Bevestigingsmail optie |
| **Postconditie**       | Item is uitgeleend aan student en niet meer beschikbaar voor anderen         |

### ✅ Module: Item Inleveren (Website)

| Eigenschap             | Omschrijving                                                                 |
|------------------------|------------------------------------------------------------------------------|
| **Naam**               | Item innemen en inspecteren                                                  |
| **Versie**             | 1.0                                                                          |
| **Actor**              | Docent                                                                       |
| **Preconditie**        | Docent is ingelogd, item is uitgeleend                                      |
| **Scenario**           | 1. Docent selecteert 'Item innemen'<br>2. Zoekt het uitgeleende item<br>3. Voert inspectie uit via checklijst<br>4. Registreert eventuele schade<br>5. Bevestigt inname |
| **Uitzonderingen**     | - Item niet gevonden<br>- API-fout bij inname                                |
| **Niet-functionele eisen** | - Foto-upload mogelijkheid voor schade<br>- Intuïtieve inspectie-interface<br>- Historieweergave van item |
| **Postconditie**       | Item is ingenomen, eventuele schade geregistreerd, en item weer beschikbaar  |

### 🔧 Module: Categorie- en Itembeheer (Website)

| Eigenschap             | Omschrijving                                                                 |
|------------------------|------------------------------------------------------------------------------|
| **Naam**               | Beheer van categorieën en items                                              |
| **Versie**             | 1.0                                                                          |
| **Actor**              | Docent                                                                       |
| **Preconditie**        | Docent is ingelogd                                                          |
| **Scenario**           | 1. Docent navigeert naar 'Beheer'<br>2. Kan kiezen tussen categorieën of items<br>3. Kan bestaande items wijzigen/verwijderen<br>4. Kan nieuwe items toevoegen |
| **Uitzonderingen**     | - API-fout bij opslaan<br>- Ongeldige invoer                                 |
| **Niet-functionele eisen** | - Drag-and-drop voor afbeeldingen<br>- Rijke tekstbewerker voor beschrijvingen<br>- Bulk-acties mogelijk |
| **Postconditie**       | Categorieën en items zijn bijgewerkt in het systeem                          |

## 📱 Mobiele App

### 🏠 Module: Startscherm (App)

| Eigenschap             | Omschrijving                                                                 |
|------------------------|------------------------------------------------------------------------------|
| **Naam**               | App Startscherm                                                              |
| **Versie**             | 1.0                                                                          |
| **Actor**              | Student/Docent                                                               |
| **Preconditie**        | App is geïnstalleerd op mobiel apparaat                                      |
| **Scenario**           | 1. Gebruiker opent app<br>2. Ziet startscherm met categorieën, scannerknop, en inlogoptie<br>3. Kan navigeren naar verschillende functies |
| **Uitzonderingen**     | - Geen internetverbinding (beperkte functionaliteit)<br>- App crash          |
| **Niet-functionele eisen** | - Snelle laadtijd (≤ 1 sec)<br>- Werkt offline voor basisfuncties<br>- Intuïtieve navigatie |
| **Postconditie**       | Gebruiker kan app-functies gebruiken                                         |

### 📷 Module: QR Scanner (App)

| Eigenschap             | Omschrijving                                                                 |
|------------------------|------------------------------------------------------------------------------|
| **Naam**               | QR-code scannen voor items                                                   |
| **Versie**             | 1.0                                                                          |
| **Actor**              | Student/Docent                                                               |
| **Preconditie**        | App heeft cameratoegang                                                      |
| **Scenario**           | 1. Gebruiker tikt op scannerknop<br>2. Camera opent<br>3. Scant QR-code op item<br>4. Ziet itemdetails<br>5. Docent kan direct uitlenen/innemen |
| **Uitzonderingen**     | - Camera werkt niet<br>- Ongeldige QR-code<br>- Item niet gevonden           |
| **Niet-functionele eisen** | - Snelle scanherkenning<br>- Werkt bij verschillende lichtomstandigheden<br>- Geeft feedback bij scannen |
| **Postconditie**       | Gebruiker ziet itemdetails of kan actie uitvoeren                            |

### 🔔 Module: Push Notificaties (App)

| Eigenschap             | Omschrijving                                                                 |
|------------------------|------------------------------------------------------------------------------|
| **Naam**               | Herinneringen via push-notificaties                                          |
| **Versie**             | 1.0                                                                          |
| **Actor**              | Student/Docent                                                               |
| **Preconditie**        | App heeft toestemming voor notificaties                                      |
| **Scenario**           | 1. Systeem detecteert naderende inleverdatum<br>2. Push-notificatie wordt verzonden<br>3. Gebruiker ontvangt melding op apparaat<br>4. Kan direct naar item navigeren |
| **Uitzonderingen**     | - Notificaties uitgeschakeld<br>- Apparaat offline                           |
| **Niet-functionele eisen** | - Niet-opdringerige meldingen<br>- Configureerbare notificaties<br>- Werkt op iOS en Android |
| **Postconditie**       | Gebruiker is herinnerd aan inleverdatum                                      |

### 📴 Module: Offline Modus (App)

| Eigenschap             | Omschrijving                                                                 |
|------------------------|------------------------------------------------------------------------------|
| **Naam**               | Offline functionaliteit                                                      |
| **Versie**             | 1.0                                                                          |
| **Actor**              | Student/Docent                                                               |
| **Preconditie**        | Gebruiker heeft app eerder gebruikt met internetverbinding                   |
| **Scenario**           | 1. App detecteert geen internetverbinding<br>2. Schakelt naar offline modus<br>3. Gebruiker kan eerder geladen categorieën en items bekijken<br>4. Acties worden in wachtrij geplaatst voor synchronisatie |
| **Uitzonderingen**     | - Eerste gebruik zonder internet<br>- Lokale data corrupt                     |
| **Niet-functionele eisen** | - Duidelijke indicatie van offline status<br>- Intelligente caching van relevante data<br>- Automatische synchronisatie bij herstel verbinding |
| **Postconditie**       | Gebruiker kan basisinformatie bekijken zonder internet                       |

### 🔄 Module: Synchronisatie (App)

| Eigenschap             | Omschrijving                                                                 |
|------------------------|------------------------------------------------------------------------------|
| **Naam**               | Data synchroniseren                                                          |
| **Versie**             | 1.0                                                                          |
| **Actor**              | Systeem                                                                      |
| **Preconditie**        | Internetverbinding hersteld na offline gebruik                               |
| **Scenario**           | 1. App detecteert internetverbinding<br>2. Controleert op wachtende acties<br>3. Synchroniseert wijzigingen met server<br>4. Downloadt nieuwe data |
| **Uitzonderingen**     | - Conflicterende wijzigingen<br>- Synchronisatiefout<br>- Verbinding verbroken tijdens synchronisatie |
| **Niet-functionele eisen** | - Achtergrondproces zonder gebruikersinterferentie<br>- Intelligente conflictoplossing<br>- Voortgangsindicatie bij grote updates |
| **Postconditie**       | App en server hebben dezelfde, bijgewerkte data                              |

---

## Automatische Notificaties

Het systeem stuurt automatisch notificaties:
- **Via e-mail** (zowel website als app)
  - 24 uur voor inlevering van een item
  - 24 uur nadat de inleverdatum is verstreken
  - Bij succesvolle uitlening of inname
  
- **Via push-notificatie** (alleen app)
  - 24 uur voor inlevering
  - Dag van inlevering
  - 24 uur na verstrijken deadline
  - Bij statuswijziging van uitgeleend item

---
## 🔄 Integratie met API

De website en app maken gebruik van de bestaande API-endpoints:

| Functionaliteit          | API Endpoint                         | Methode | Doel                                                  |
|--------------------------|--------------------------------------|---------|-------------------------------------------------------|
| Authenticatie            | `/api/login`                         | POST    | Inloggen voor docenten                                |
| Categorieën ophalen      | `/api/categories`                    | GET     | Lijst met alle categorieën tonen                      |
| Items per categorie      | `/api/categories/{id}/items`         | GET     | Items binnen een specifieke categorie weergeven       |
| Item details             | `/api/items/{id}`                    | GET     | Details van een specifiek item tonen                  |
| Item uitlenen            | `/api/lendings`                      | POST    | Nieuwe uitlening registreren                          |
| Item innemen             | `/api/lendings/{id}/return`          | POST    | Item terugnemen en inspecteren                        |
| Uitleenstatus            | `/api/lendings/status`               | GET     | Overzicht van huidige uitleningen en deadlines        |
| QR-code scannen          | `/api/items/by-qr/{code}`            | GET     | Item informatie ophalen via QR-code                   |

---

## 🔐 Beveiliging & Toegang

- Website en app gebruiken HTTPS voor alle communicatie
- JWT tokens worden veilig opgeslagen
  - Website: in HttpOnly cookies of localStorage (afhankelijk van beveiligingsvereisten)
  - App: in beveiligde opslag (Keychain voor iOS, EncryptedSharedPreferences voor Android)
- Sessie timeout na 30 minuten inactiviteit
- Biometrische authenticatie optie in de app (vingerafdruk/gezichtsherkenning)
- Data caching volgt privacy-richtlijnen

---

## 🎨 Gebruikersinterface

### Website
- Responsive design voor alle schermformaten
- Moderne, intuïtieve interface met consistente navigatie
- Dashboard met data-visualisaties voor docenten
- Toegankelijk volgens WCAG 2.1 richtlijnen

### App
- Native look-and-feel voor zowel iOS als Android
- Bottom navigation voor belangrijke functies
- Zwevende actieknop voor QR-scanner
- Offline indicator
- Donkere modus ondersteuning

---

## Toekomstige uitbreiding (optioneel)
- Barcode scanning naast QR-codes
- Reserveringssysteem voor items
- Chatfunctie voor directe communicatie
- Geavanceerde analytics en rapportages
- Integratie met schoolrooster
