# 📄 Projectplan – Uitleen-API Firda

## Projecttitel
**Uitleen-API voor Firda**

---

## Aanleiding
Binnen Firda wordt regelmatig gebruikgemaakt van uitleenmateriaal zoals laptops, camera’s, kabels en andere apparatuur. Op dit moment gebeurt het uitlenen grotendeels handmatig of via losse documenten, wat foutgevoelig en onoverzichtelijk is. Er is behoefte aan een centrale oplossing om het uitleenproces te automatiseren en te structureren. Een API vormt de technische basis voor een later te bouwen front-end, zoals een web- of mobiele applicatie.

---

## Doelstellingen
Het project heeft als doel om een veilige, overzichtelijke en schaalbare backend (API) te bouwen waarmee het uitleenproces binnen Firda digitaal beheerd kan worden. De API moet:

- Studenten in staat stellen beschikbare materialen te bekijken.
- Docenten (na inloggen) categorieën, items, uitleningen en inspecties kunnen beheren.
- Automatisch e-mails versturen bij naderende of te late inlevermomenten.
- Informatie bieden over schadehistorie en uitleengeschiedenis.

---

## Verwacht Resultaat
Een werkende Laravel RESTful API met:
- Volledige CRUD-functionaliteit voor categorieën, items, uitleenacties en inspecties.
- Authenticatie en autorisatie (alleen docenten kunnen inloggen).
- Automatische e-mailnotificaties bij deadlines.
- Logging van schade en uitleengeschiedenis.
- Volledige documentatie (projectplan, FO, TO, testplan, testscenario’s, testrapport).

---

## Afbakening

### In scope
- Ontwikkeling van de Laravel RESTful API
- Authenticatie/Autorisatie (inloggen alleen voor docenten)
- CRUD-functionaliteit voor categorieën, items, docenten, uitleningen en inspecties
- Automatische e-mails bij deadlines of te laat inleveren
- Logging van schade en uitleenhistorie
- Documentatie schrijven

### Out of scope
- Frontend (web/app) ontwikkeling
- Accountregistratie voor studenten
- Betalingen, facturatie of schadevergoeding
- Gebruik van Microsoft-accounts of externe loginproviders

---

## Risico’s
- **Tijdgebrek:** Door een krappe deadline (4 weken) kan niet alles gerealiseerd worden.
- **Complexiteit van e-mailfunctionaliteit:** Het automatisch versturen van e-mails vereist goede timing en foutafhandeling.
- **Testafhankelijkheid:** Het testen is deels afhankelijk van beschikbaarheid van anderen (klasgenoten/docenten).

---

## Verwachte effecten
- **Efficiënt beheer:** Docenten kunnen efficiënter uitleenmateriaal beheren.
- **Inzicht en controle:** Meer zicht op wie welk materiaal heeft en wanneer dit terug moet.
- **Voorkomen van misbruik:** Door logging en inspecties is schade of misbruik beter te traceren.
- **Voorbereiding op verdere digitalisering:** De API kan later worden gebruikt in een volledige uitleenapplicatie.

---

## Randvoorwaarden
- Het project moet gebouwd worden in Laravel 10 (of recenter)
- MySQL/MariaDB moet beschikbaar zijn als database
- PHP 8.1+ vereist
- Applicatie draait lokaal of in een testomgeving via Laravel Sail of Docker
- Alleen e-mails met @firda.nl en @student.firda.nl mogen een account registreren

---

## Fasering

| Fase | Activiteiten |
|------|--------------|
| **Initiatie** | Opstellen van projectplan, functioneel ontwerp en databaseontwerp |
| **Ontwikkeling** | Bouwen van de API-functionaliteiten en authenticatie |
| **Uitbreiding** | Toevoegen van e-mailnotificaties, inspectiesysteem en logging |
| **Testen** | Testen met testscenario’s, feedback verzamelen, bugfixes doorvoeren |
| **Oplevering** | Documentatie afronden, testrapport schrijven, code opleveren |

---

## Planning (4 weken)

| Week | Activiteiten |
|------|--------------|
| **Week 1** | Projectvoorbereiding, Git opzetten, projectplan + FO schrijven, databaseontwerp maken |
| **Week 2** | Bouw van categorie- en item-functionaliteit (CRUD), authenticatie, start uitleenlogica |
| **Week 3** | Mailfunctionaliteit + schade-inspectiesysteem + logging, afronden TO, testplan & scenario’s maken |
| **Week 4** | Testen, debuggen, testrapport schrijven, documentatie afronden, project opleveren |

---
## 📆 Gedetailleerde Planning (4 weken)

### 🗓️ Week 1 – Voorbereiding & Basisfunctionaliteit

| Dag       | Ochtend                                         | Middag                                         |
|-----------|--------------------------------------------------|------------------------------------------------|
| Maandag   | Projectstructuur opzetten (Laravel, Git)        | `.env`, README en Docker/Sail configuratie     |
| Dinsdag   | Functioneel Ontwerp (FO) schrijven               | Databaseontwerp + ERD uitwerken                |
| Woensdag  | Models + Migrations: `Category`, `Item`          | Seeder + testdata aanmaken                     |
| Donderdag | Routes + basiscontrollers opzetten               | CRUD-functionaliteit voor categorieën          |
| Vrijdag   | CRUD voor items afronden                         | Unit tests voor basislogica                    |

---

### 🗓️ Week 2 – Authenticatie & Uitleenlogica

| Dag       | Ochtend                                         | Middag                                         |
|-----------|--------------------------------------------------|------------------------------------------------|
| Maandag   | Inloggen via Laravel Sanctum implementeren       | Middleware + roltoegang (alleen docenten)      |
| Dinsdag   | CRUD voor docentbeheer                           | Modelrelaties testen + inputvalidatie         |
| Woensdag  | Start uitleenlogica (`Loan` model, routes)       | Uitleen- en inleveracties implementeren        |
| Donderdag | Testen met Postman of Insomnia                   | Validatiefouten netjes afvangen                |
| Vrijdag   | Functionele testcases schrijven                  | FO/TO bijwerken indien nodig                   |

---

### 🗓️ Week 3 – E-mailfunctionaliteit & Inspecties

| Dag       | Ochtend                                         | Middag                                         |
|-----------|--------------------------------------------------|------------------------------------------------|
| Maandag   | Mailtemplates maken (reminders, te laat)         | Laravel jobs + queues opzetten voor mails      |
| Dinsdag   | Laravel scheduler instellen (cron in `Kernel`)   | Mailfunctionaliteit testen met fake SMTP       |
| Woensdag  | `Inspection` model en schade-logica toevoegen    | Inspecties testen + logging implementeren      |
| Donderdag | Uitleenhistorie logica toevoegen                 | Refactoren + API response cleanup              |
| Vrijdag   | Technisch Ontwerp (TO) afronden                  | Testplan + testscenario’s schrijven            |

---

### 🗓️ Week 4 – Testen, Debuggen & Opleveren

| Dag       | Ochtend                                      | Middag                                         |
|-----------|----------------------------------------------|------------------------------------------------|
| Maandag   | Handmatige tests uitvoeren                   | Bugfixes doorvoeren + feedback verwerken       |
| Dinsdag   | Feature tests schrijven (Laravel test suite) | Login en autorisatie grondig testen            |
| Woensdag  | Testrapport schrijven                        | Documentatie controleren en aanvullen          |
| Donderdag | README finaliseren                           | Opleverversie voorbereiden (code & docs)       |
| Vrijdag   | (Optioneel) Presentatie voorbereiden         | Project inleveren (GitHub of ZIP)              |

---
## Rollen en verantwoordelijkheden

| Rol | Verantwoordelijke |
|-----|-------------------|
| Ontwikkelaar | Senne Visser |
| Code schrijven | Senne Visser |
| Documentatie maken | Senne Visser |
| Testen | Klasgenoten, docenten en ChatGPT 😉 |

