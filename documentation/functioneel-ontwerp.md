# 📄 Functioneel Ontwerp – Uitleen-API Firda

## Doel van het systeem
De API maakt het mogelijk om uitleenmateriaal bij Firda digitaal te beheren. Studenten kunnen beschikbare apparatuur bekijken. Ingelogde gebruikers (docenten) beheren de uitleenprocessen, materialen, schade-inspecties en ontvangen automatische herinneringen via e-mail.

---

## Gebruikersrollen

### 🧑 Niet-ingelogde gebruiker (student)
- Kan categorieën opvragen
- Kan items per categorie bekijken
- Ziet van elk item: titel, foto's, omschrijving en status (beschikbaar/uitgeleend)

### 👨‍🏫 Ingelogde gebruiker (docent)
- Kan inloggen op de API
- Kan alle categorieën beheren (toevoegen, aanpassen, verwijderen)
- Kan alle items beheren (toevoegen, aanpassen, verwijderen)
- Kan uitleenregistraties beheren
- Kan andere docenten bekijken
- Krijgt e-mailmeldingen over inleveringen
- Noteert schade bij het terugnemen van items
- Ziet een overzicht van:
    - Items die vandaag teruggebracht moeten worden
    - Items die te laat zijn

---

## Functionaliteiten (per module)

## 🔐 Module: Account aanmaken

| Eigenschap                 | Omschrijving                                                                                                                                                                                                               |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Naam**                   | Registreren                                                                                                                                                                                                                |
| **Versie**                 | 1.0                                                                                                                                                                                                                        |
| **Actor**                  | Docent                                                                                                                                                                                                                     |
| **Preconditie**            | Gebruiker is niet ingelogd                                                                                                                                                                                                 |
| **Scenario**               | 1. Gebruiker opent registratiepagina<br>2. Voert naam, e-mailadres en wachtwoord in<br>3. API controleert of e-mailadres eindigt op `@firda.nl` of `@student.firda.nl`<br>4. Bij geldige gegevens wordt account aangemaakt |
| **Uitzonderingen**         | - Ongeldig e-mailadres (geen Firda-domein)<br>- E-mailadres bestaat al<br>- Wachtwoord te zwak                                                                                                                             |
| **Niet-functionele eisen** | - E-mailvalidatie vereist<br>- Registratie binnen 5 sec afgerond                                                                                                                                                           |
| **Postconditie**           | Gebruiker heeft een account en kan inloggen                                                                                                                                                                                |


## 🔐 Module: Inloggen

| Eigenschap                 | Omschrijving                                                                                                |
| -------------------------- | ----------------------------------------------------------------------------------------------------------- |
| **Naam**                   | Inloggen met geregistreerd account                                                                          |
| **Versie**                 | 1.1 (aangepast)                                                                                             |
| **Actor**                  | Docent                                                                                                      |
| **Preconditie**            | Account bestaat en gebruiker is niet ingelogd                                                               |
| **Scenario**               | 1. Gebruiker voert e-mailadres en wachtwoord in<br>2. API valideert gegevens<br>3. Token wordt teruggegeven |
| **Uitzonderingen**         | - Ongeldige login<br>- Geen netwerk<br>- E-mail bestaat niet                                                |
| **Niet-functionele eisen** | - Token is JWT of sanctum gebaseerd<br>- Reactietijd ≤ 2 sec                                                |
| **Postconditie**           | Gebruiker is ingelogd en kan API gebruiken                                                                  |

---

## 📂 Module: Categorieën bekijken

| Eigenschap             | Omschrijving                                                                 |
|------------------------|------------------------------------------------------------------------------|
| **Naam**               | Categorieën ophalen                                                          |
| **Versie**             | 1.0                                                                          |
| **Actor**              | Student (niet-ingelogde gebruiker)                                           |
| **Preconditie**        | Geen authenticatie vereist                                                   |
| **Scenario**           | 1. Student opent `/api/categories`<br>2. API retourneert categorieënlijst     |
| **Uitzonderingen**     | - API offline<br>- Netwerkproblemen                                          |
| **Niet-functionele eisen** | - Reactie ≤ 2 sec<br>- JSON-output                                         |
| **Postconditie**       | Categorieën zijn zichtbaar                                                   |

---

## 📦 Module: Items bekijken

| Eigenschap             | Omschrijving                                                                 |
|------------------------|------------------------------------------------------------------------------|
| **Naam**               | Items per categorie bekijken                                                 |
| **Versie**             | 1.0                                                                          |
| **Actor**              | Student (niet-ingelogde gebruiker)                                           |
| **Preconditie**        | Categorieën zijn opgehaald                                                   |
| **Scenario**           | 1. Student klikt op categorie<br>2. Items worden geladen via API<br>3. Titel, foto's, omschrijving en status worden getoond |
| **Uitzonderingen**     | - Netwerkproblemen<br>- Fout in categorie-ID                                 |
| **Niet-functionele eisen** | - Laden ≤ 2 sec<br>- Mobielvriendelijke JSON                              |
| **Postconditie**       | Items zijn zichtbaar                                                         |

---

## ➕ Module: Item uitlenen

| Eigenschap             | Omschrijving                                                                 |
|------------------------|------------------------------------------------------------------------------|
| **Naam**               | Item uitlenen aan student                                                    |
| **Versie**             | 1.0                                                                          |
| **Actor**              | Docent                                                                       |
| **Preconditie**        | Docent is ingelogd en item is beschikbaar                                   |
| **Scenario**           | 1. Docent selecteert item<br>2. Voert studentgegevens en uitleendatum in<br>3. Bevestigt uitlening<br>4. Uitleen wordt opgeslagen |
| **Uitzonderingen**     | - Item niet beschikbaar<br>- Onjuiste gegevens<br>- Geen login               |
| **Niet-functionele eisen** | - Max. 5 sec<br>- Veilige opslag (HTTPS + validatie)                     |
| **Postconditie**       | Item is gekoppeld aan student en gemarkeerd als uitgeleend                  |

---

## ✅ Module: Item terugnemen + inspectie

| Eigenschap             | Omschrijving                                                                 |
|------------------------|------------------------------------------------------------------------------|
| **Naam**               | Item retourneren en inspecteren                                              |
| **Versie**             | 1.0                                                                          |
| **Actor**              | Docent                                                                       |
| **Preconditie**        | Het item is uitgeleend                                                       |
| **Scenario**           | 1. Item wordt gescand of geselecteerd<br>2. Visuele inspectie volgt<br>3. Schade (indien aanwezig) wordt geregistreerd<br>4. Item wordt als teruggebracht gemarkeerd |
| **Uitzonderingen**     | - Item-ID niet gevonden<br>- Schade niet geregistreerd<br>- Geen login       |
| **Niet-functionele eisen** | - Inspectieformulier moet mobiel werken<br>- Binnen 3 min af te handelen |
| **Postconditie**       | Item is terug, schade is (eventueel) geregistreerd                          |

---

## 🛠 Module: Schade registreren

| Eigenschap             | Omschrijving                                                                 |
|------------------------|------------------------------------------------------------------------------|
| **Naam**               | Schade toevoegen aan logboek                                                 |
| **Versie**             | 1.0                                                                          |
| **Actor**              | Docent                                                                       |
| **Preconditie**        | Item wordt geïnspecteerd na retourneren                                     |
| **Scenario**           | 1. Docent vult schadeformulier in<br>2. Beschrijving en foto's optioneel<br>3. API slaat de schade op met datum en lenergegevens |
| **Uitzonderingen**     | - Formulier onvolledig<br>- Fout in item-ID                                  |
| **Niet-functionele eisen** | - Duidelijke invoervelden<br>- Formvalidatie                              |
| **Postconditie**       | Schade is geregistreerd en gekoppeld aan item en student                    |

---

## ⏰ Module: Te laat / Vandaag terug overzicht

| Eigenschap             | Omschrijving                                                                 |
|------------------------|------------------------------------------------------------------------------|
| **Naam**               | Inleverstatusoverzicht                                                       |
| **Versie**             | 1.0                                                                          |
| **Actor**              | Docent (beheerscherm)                                                        |
| **Preconditie**        | Docent is ingelogd                                                           |
| **Scenario**           | 1. Docent opent overzicht<br>2. API toont items van vandaag + te laat        |
| **Uitzonderingen**     | - Geen data beschikbaar<br>- Fout in datumfilter                             |
| **Niet-functionele eisen** | - Overzicht ≤ 2 sec laden<br>- Sortering op datum vereist                |
| **Postconditie**       | Docent ziet welke studenten aangesproken moeten worden                      |

---

## 📧 Module: Automatische e-mails

| Eigenschap             | Omschrijving                                                                 |
|------------------------|------------------------------------------------------------------------------|
| **Naam**               | Uitleenherinnering per e-mail                                                |
| **Versie**             | 1.0                                                                          |
| **Actor**              | Systeem                                                                       |
| **Preconditie**        | Een uitleenitem nadert zijn retourdatum                                     |
| **Scenario**           | 1. 24 uur voor inlevering: student ontvangt herinnering<br>2. 24 uur ná deadline: herinnering te laat |
| **Uitzonderingen**     | - Geen e-mailadres geregistreerd<br>- Mailserver down                        |
| **Niet-functionele eisen** | - E-mails worden dagelijks verstuurd via geplande taak<br>- Herinneringen in duidelijke taal |
| **Postconditie**       | Student ontvangt tijdige waarschuwingen via e-mail                          |

---

## ⚙️ Module: Categoriebeheer

| Eigenschap             | Omschrijving                                                                 |
|------------------------|------------------------------------------------------------------------------|
| **Naam**               | Categorieën aanmaken, wijzigen, verwijderen                                  |
| **Versie**             | 1.0                                                                          |
| **Actor**              | Docent (ingelogd)                                                            |
| **Preconditie**        | Docent is ingelogd                                                           |
| **Scenario**           | 1. Docent maakt een nieuwe categorie aan<br>2. Of wijzigt/bepaalt bestaande<br>3. API voert actie uit |
| **Uitzonderingen**     | - Ongeldige invoer<br>- Dubbele naam                                         |
| **Niet-functionele eisen** | - Validatie vereist<br>- Snelle bewerking (≤ 2 sec)                      |
| **Postconditie**       | Categorie is correct bijgewerkt                                              |

---

## 👥 Module: Docenten beheren

| Eigenschap             | Omschrijving                                                                 |
|------------------------|------------------------------------------------------------------------------|
| **Naam**               | Docentenoverzicht en toevoegen                                               |
| **Versie**             | 1.1                                                                          |
| **Actor**              | Docent (alleen admin)                                                        |
| **Preconditie**        | Docent is ingelogd en heeft adminrechten                                     |
| **Scenario**           | 1. Admin-docent opent `/api/users`<br>2. Ziet alle geregistreerde docenten<br>3. Kan een nieuwe docent toevoegen met naam en e-mailadres |
| **Uitzonderingen**     | - Geen adminrechten → toegang geweigerd<br>- Ongeldige gegevens              |
| **Niet-functionele eisen** | - Alleen accounts met @firda.nl of @student.firda.nl toegestaan<br>- Validatie vereist |
| **Postconditie**       | Nieuwe docent is geregistreerd                                               |

---

## Automatische e-mails

De API stuurt automatisch een e-mail naar de lener:
- **24 uur voor inlevering** van een item
- **24 uur nadat de inleverdatum is verstreken**, als het item nog niet is ingeleverd
- E-mail bevat een herinnering met details van het item en de lener
- E-mail verificeert of het e-mailadres geldig is (bijv. `@firda.nl` of `@student.firda.nl`)

---
## 📚 API Overzicht

| Module                         | Endpoint                            | Methode | Authenticatie  | Beschrijving                                            |
|--------------------------------| ----------------------------------- | ------- | -------------- | ------------------------------------------------------- |
| 🔐 Inloggen                    | `/api/login`                        | POST    | ❌              | Inloggen met geregistreerd account                      |
| 🧾 Registreren                 | `/api/register`                     | POST    | ❌              | Account aanmaken (alleen @firda.nl / @student.firda.nl) |
| 📂 Categorieën bekijken        | `/api/categories`                   | GET     | ❌              | Lijst met alle categorieën                              |
| 📦 Items per categorie         | `/api/categories/{id}/items`        | GET     | ❌              | Lijst van items binnen een bepaalde categorie           |
| 📦 Itemdetails                 | `/api/items/{id}`                   | GET     | ❌              | Informatie over een specifiek item                      |
| ⚙️ Categoriebeheer             | `/api/categories`                   | POST    | ✅              | Nieuwe categorie aanmaken                               |
|                                | `/api/categories/{id}`              | PUT     | ✅              | Categorie wijzigen                                      |
|                                | `/api/categories/{id}`              | DELETE  | ✅              | Categorie verwijderen                                   |
| 📦 Itembeheer                  | `/api/items`                        | POST    | ✅              | Nieuw item toevoegen                                    |
|                                | `/api/items/{id}`                   | PUT     | ✅              | Item wijzigen                                           |
|                                | `/api/items/{id}`                   | DELETE  | ✅              | Item verwijderen                                        |
| ➕ Uitleenregistratie           | `/api/lendings`                     | POST    | ✅              | Item uitlenen aan student                               |
| ✅ Item retourneren + inspectie | `/api/lendings/{id}/return`         | POST    | ✅              | Item terugnemen en schade inspecteren                   |
| 🛠 Schade registreren          | `/api/items/{id}/damage`            | POST    | ✅              | Schade registreren bij een item                         |
| ⏰ Inleverstatus-overzicht      | `/api/lendings/status`              | GET     | ✅              | Overzicht van items die vandaag of te laat zijn         |
| 📧 Herinneringsmails (cron)    | `/api/notifications/send-reminders` | POST    | ✅ (cron token) | Verstuur herinneringen (voor en na inleverdatum)        |
| 👥 Docentenoverzicht           | `/api/users`                              | GET     | ✅              | Lijst van geregistreerde docenten                |
| 👥 Docent toevoegen            | `/api/users`                           | POST    | ✅ (admin)     | Nieuwe docent aanmaken (alleen door admins)      |

---
## ⚙️ Gebruikte Technologieën

Het systeem is gebouwd als RESTful API met de volgende stack:

- Laravel 11 (PHP 8
- MySQL voor opslag van uitleen-, schade- en gebruikersdata
- Laravel Mail voor het automatisch verzenden van herinneringen
- JSON als standaarduitwisselingsformaat
---

## Belangrijke regels / logica
- Alleen docenten hebben beheertoegang (na inloggen)
- Een item kan slechts 1x tegelijk uitgeleend worden
- Inspectie bij terugname is verplicht en leidt eventueel tot schade-registratie
- De uitleengeschiedenis en schadehistorie worden bewaard in een logboek
- Alleen docenten kunnen inloggen
- Alleen docenten met adminrechten kunnen nieuwe docenten toevoegen


---
## 🔐 Beveiliging & Toegang
- Alleen gebruikers met een @firda.nl Microsoft-account kunnen inloggen
- Alle gevoelige acties (zoals uitlenen, verwijderen, wijzigen) vereisen een geldig access token
- Data wordt alleen uitgewisseld via een HTTPS-verbinding
- Niet-ingelogde gebruikers hebben uitsluitend leesrechten op categorieën en items
- Rate limiting is ingesteld op publieke endpoints om misbruik te voorkomen

---

## Toekomstige uitbreiding (optioneel)
- Rollenbeheer met beheerdersrol
- QR-code scanning voor sneller uitlenen
- Frontend integratie via Vue.js of een mobiele app
