# 📄 Projectplan – Uitleen Website & App Firda

## Projecttitel
**Uitleen Website & Mobiele App voor Firda**

---

## Aanleiding
Na het succesvol ontwikkelen van de Uitleen-API voor Firda, is er nu behoefte aan gebruiksvriendelijke frontends waarmee zowel studenten als docenten het uitleensysteem kunnen gebruiken. De reeds ontwikkelde API biedt alle benodigde functionaliteit op de backend, maar er is nog geen toegankelijke interface voor eindgebruikers. Daarom willen we nu een website en mobiele app ontwikkelen die de API-functionaliteit ontsluiten.

---

## Doelstellingen
Het project heeft als doel om een gebruiksvriendelijke website en mobiele app te bouwen die de bestaande Uitleen-API integreren. De frontends moeten:

- Studenten in staat stellen beschikbare materialen te bekijken en hun huidige uitleningen te zien.
- Docenten (na inloggen) toegang geven tot het volledige beheer van categorieën, items, uitleningen en inspecties.
- Eenvoudig te gebruiken zijn op zowel desktop als mobiele apparaten.
- Intuïtieve interfaces bieden voor het uitlenen en inleveren van items, inclusief schade-inspectie.
- Overzichtelijke dashboards tonen met actuele status van uitleningen.

---

## Verwacht Resultaat
- Een responsieve web-applicatie met:
  - Publieke itemcatalogus voor studenten
  - Beveiligd beheerderspaneel voor docenten
  - Intuïtieve interfaces voor alle API-functionaliteiten
  
- Een mobiele app (Android & iOS) met:
  - Snelle QR-code scanner voor uitlenen/inleveren
  - Push-notificaties voor herinneringen
  - Offline functionaliteit voor basis item-informatie
  - Synchronisatie met de API bij netwerkverbinding

- Volledige documentatie (projectplan, FO, TO, testplan, testscenario's, testrapport).

---

## Afbakening

### In scope
- Ontwikkeling responsieve website met Vue.js frontend
- Ontwikkeling mobiele app met React Native
- Integratie met bestaande Uitleen-API
- QR-code functionaliteit voor snel uitlenen/inleveren
- Dashboard voor docenten met status-overzichten
- Push-notificaties voor mobiele app
- Offline functionaliteit in mobiele app

### Out of scope
- Aanpassingen aan de bestaande API (behalve eventuele bugfixes)
- Ontwikkeling van nieuwe API-endpoints specifiek voor de frontends
- Integratie met andere schoolsystemen
- Deep learning of AI-functionaliteiten
- Admin-paneel voor systeembeheerders

---

## Risico's
- **API-wijzigingen:** Als de bestaande API onverwacht wordt aangepast, kan dit impact hebben op de frontends.
- **Complexiteit van offline synchronisatie:** Het correct synchroniseren van offline data kan technisch uitdagend zijn.
- **Cross-platform uitdagingen:** Verschillen tussen Android en iOS kunnen tot extra ontwikkeltijd leiden.
- **Toegankelijkheid:** Het garanderen van goede gebruiksvriendelijkheid voor alle gebruikersgroepen kan complex zijn.

---

## Verwachte effecten
- **Gebruiksgemak:** Studenten en docenten kunnen het uitleensysteem gemakkelijk gebruiken zonder technische kennis.
- **Tijdsbesparing:** Het proces van uitlenen en inleveren wordt aanzienlijk versneld door de intuïtieve interfaces.
- **Betere naleving:** Door herinneringen en push-notificaties worden items vaker op tijd ingeleverd.
- **Minder administratie:** Docenten hebben minder handmatig werk door de geautomatiseerde frontends.

---

## Randvoorwaarden
- De Uitleen-API moet operationeel en toegankelijk zijn
- Voor de website: moderne browsers moeten ondersteund worden (Chrome, Firefox, Safari, Edge)
- Voor de mobiele app: minimaal Android 8.0+ en iOS 12.0+
- Internetverbinding voor realtime synchronisatie (behalve basisfunctionaliteit in de app)
- Capaciteit voor het versturen van push-notificaties

---

## Fasering

| Fase | Activiteiten |
|------|--------------|
| **Initiatie** | Opstellen van projectplan, functioneel ontwerp en wireframes |
| **Web Ontwikkeling** | Bouwen van de responsieve website met Vue.js |
| **App Ontwikkeling** | Ontwikkelen van de mobiele app met React Native |
| **Integratie** | API-integratie, offline functionaliteit, QR-code scanning |
| **Testen** | Gebruikerstests, cross-browser/device tests, bugfixes |
| **Oplevering** | Documentatie afronden, deployment, app store publicatie |

---

## Planning (12 weken)

| Week | Activiteiten |
|------|--------------|
| **Week 1-2** | Projectvoorbereiding, wireframes maken, projectplan + FO schrijven |
| **Week 3-5** | Ontwikkeling website basis, studenten- en docentenportaal |
| **Week 6-9** | Ontwikkeling mobiele app, QR-scanner, offline functionaliteit |
| **Week 10** | Integratie en testen van beide platforms |
| **Week 11** | Gebruikerstests, feedback verwerken, bugfixes |
| **Week 12** | Documentatie afronden, deployment, app stores publicatie |

---
## 📆 Gedetailleerde Planning (12 weken)

### 🗓️ Week 1-2 – Voorbereiding & Design

| Dag       | Ochtend                                         | Middag                                         |
|-----------|--------------------------------------------------|------------------------------------------------|
| Maandag   | Projectstructuur opzetten (Git, projectmanagement) | UI/UX principes definiëren voor consistentie |
| Dinsdag   | Wireframes website studenten (Figma)            | Wireframes website docenten (Figma)            |
| Woensdag  | Wireframes mobiele app studenten                | Wireframes mobiele app docenten                |
| Donderdag | Design systeem opzetten (kleuren, componenten)  | Functioneel Ontwerp (FO) schrijven             |
| Vrijdag   | Technisch Ontwerp (TO) schrijven                | API integratiestrategie uitwerken              |

---

### 🗓️ Week 3-5 – Website Ontwikkeling

| Dag       | Ochtend                                         | Middag                                         |
|-----------|--------------------------------------------------|------------------------------------------------|
| Maandag   | Vue.js project setup en routing                 | API service connectie implementeren            |
| Dinsdag   | Component bibliotheek opzetten                  | Authenticatie implementeren                    |
| Woensdag  | Studentenportaal ontwikkelen                    | Itemcatalogus en zoekfunctie                   |
| Donderdag | Docentenportaal basis ontwikkelen               | CRUD-interfaces voor categorieën               |
| Vrijdag   | CRUD-interfaces voor items                      | Dashboard voor uitleenstatus                   |

---

### 🗓️ Week 6-9 – Mobiele App Ontwikkeling

| Dag       | Ochtend                                         | Middag                                         |
|-----------|--------------------------------------------------|------------------------------------------------|
| Maandag   | React Native project setup                      | Navigatiestructuur opzetten                    |
| Dinsdag   | API service voor mobiel implementeren           | Authenticatie en offline storage               |
| Woensdag  | Studentenschermen ontwikkelen                   | QR-code scanner implementeren                  |
| Donderdag | Docentenschermen ontwikkelen                    | Push-notificaties implementeren                |
| Vrijdag   | Offline synchronisatie ontwikkelen              | Testing en debugging                           |

---

### 🗓️ Week 10 – Integratie & Testen

| Dag       | Ochtend                                      | Middag                                         |
|-----------|----------------------------------------------|------------------------------------------------|
| Maandag   | Website finaliseren en deployen              | Cross-browser tests uitvoeren                  |
| Dinsdag   | App builden voor Android                     | App builden voor iOS                           |
| Woensdag  | Integratie testen website met API            | Integratie testen app met API                  |
| Donderdag | End-to-end tests schrijven                   | Performance tests uitvoeren                    |
| Vrijdag   | Bugfixes doorvoeren                          | Testrapport bijwerken                          |

---

### 🗓️ Week 11-12 – Gebruikerstests & Oplevering

| Dag       | Ochtend                                      | Middag                                         |
|-----------|----------------------------------------------|------------------------------------------------|
| Maandag   | Gebruikerstests met studenten                | Gebruikerstests met docenten                   |
| Dinsdag   | Feedback verwerken website                   | Feedback verwerken app                         |
| Woensdag  | Final bugfixes doorvoeren                    | App store submissie voorbereiden               |
| Donderdag | Deployment scripts finaliseren               | App store publicatie                           |
| Vrijdag   | Documentatie afronden                        | Project opleveren                              |

---
## Rollen en verantwoordelijkheden

| Rol | Verantwoordelijke |
|-----|-------------------|
| Projectleider | Senne Visser |
| Frontend Developer (Web) | Senne Visser |
| Frontend Developer (App) | Senne Visser |
| UI/UX Designer | Senne Visser |
| Tester | Klasgenoten, docenten en studenten |
