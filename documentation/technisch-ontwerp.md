# 📄 Technisch Ontwerp – Uitleen-API Firda

## Doel van het systeem

Het doel van het technische ontwerp is om de backend van de uitleen-API goed te structureren. We zorgen ervoor dat de API gebruiksvriendelijk, goed gestructureerd, en uitbreidbaar is.

---

## 1. **Architectuur en technologieën**

### Architectuur

De API wordt gebouwd in Laravel en volgt de MVC-architectuur (Model-View-Controller):

* **Model**: Beheert de data en database-interacties.
* **View**: Niet van toepassing, aangezien het een API is.
* **Controller**: Verwerkt de logica en voert acties uit zoals het ophalen van data en het uitvoeren van validaties.

### Technologieën

* **Backend**: Laravel (PHP Framework)
* **Database**: MySQL of MariaDB
* **Authenticatie**: Custom login met e-mailvalidatie voor Firda-mailadressen
* **API**: RESTful API-structuur, gebaseerd op de REST-conventies
* **Validatie**: Laravel's ingebouwde validaties voor invoerbeveiliging
* **E-mail**: Laravel’s ingebouwde mailfunctionaliteit voor notificaties

---

## 2. **Database-structuur**

De database wordt opgezet in MySQL/MariaDB met de volgende tabellen:

### 🗃 **Users**

| Veldnaam    | Type         | Beschrijving                                                                   |
| ----------- | ------------ | ------------------------------------------------------------------------------ |
| id          | INT          | Unieke identificatie van de gebruiker                                          |
| name        | VARCHAR(255) | Naam van de gebruiker                                                          |
| email       | VARCHAR(255) | E-mailadres van de gebruiker (moet eindigen op @firda.nl of @student.firda.nl) |
| password    | VARCHAR(255) | Gehasht wachtwoord                                                             |
| is\_admin   | BOOLEAN      | Bepaalt of de gebruiker een admin is (default: false)                          |
| created\_at | TIMESTAMP    | Timestamp van aanmaak                                                          |
| updated\_at | TIMESTAMP    | Timestamp van laatste wijziging                                                |

### 🗃 **Categories**

| Veldnaam    | Type         | Beschrijving                          |
| ----------- | ------------ | ------------------------------------- |
| id          | INT          | Unieke identificatie van de categorie |
| name        | VARCHAR(255) | Naam van de categorie                 |
| description | TEXT         | Beschrijving van de categorie         |
| created\_at | TIMESTAMP    | Timestamp van aanmaak                 |
| updated\_at | TIMESTAMP    | Timestamp van laatste wijziging       |

### 🗃 **Items**

| Veldnaam     | Type                                                 | Beschrijving                                            |
| ------------ | ---------------------------------------------------- | ------------------------------------------------------- |
| id           | INT                                                  | Unieke identificatie van het item                       |
| title        | VARCHAR(255)                                         | Titel van het item                                      |
| description  | TEXT                                                 | Omschrijving van het item                               |
| status       | ENUM('beschikbaar', 'uitgeleend', 'onder inspectie') | Huidige status van het item                             |
| category\_id | INT                                                  | Verwijzing naar de categorie van het item (foreign key) |
| created\_at  | TIMESTAMP                                            | Timestamp van aanmaak                                   |
| updated\_at  | TIMESTAMP                                            | Timestamp van laatste wijziging                         |

### 🗃 **Loans (Uitleenregistraties)**

| Veldnaam     | Type      | Beschrijving                                                                          |
| ------------ | --------- | ------------------------------------------------------------------------------------- |
| id           | INT       | Unieke identificatie van de uitleenregistratie                                        |
| item\_id     | INT       | Verwijzing naar het uitgeleende item (foreign key)                                    |
| user\_id     | INT       | Verwijzing naar de lener (student) (foreign key)                                      |
| loan\_date   | TIMESTAMP | Datum van uitleen                                                                     |
| return\_date | TIMESTAMP | Datum waarop het item teruggebracht moet worden                                       |
| returned\_at | TIMESTAMP | Datum waarop het item daadwerkelijk is teruggebracht (null als het nog niet terug is) |
| created\_at  | TIMESTAMP | Timestamp van aanmaak                                                                 |
| updated\_at  | TIMESTAMP | Timestamp van laatste wijziging                                                       |

### 🗃 **Damage Logs (Schade-logboek)**

| Veldnaam            | Type      | Beschrijving                                       |
| ------------------- | --------- | -------------------------------------------------- |
| id                  | INT       | Unieke identificatie van het schadebericht         |
| item\_id            | INT       | Verwijzing naar het beschadigde item (foreign key) |
| damage\_description | TEXT      | Beschrijving van de schade                         |
| damage\_date        | TIMESTAMP | Datum waarop de schade is vastgesteld              |
| created\_at         | TIMESTAMP | Timestamp van aanmaak                              |
| updated\_at         | TIMESTAMP | Timestamp van laatste wijziging                    |

---

## 3. **API Routes**

De API-routes zijn RESTful en volgen de conventies voor resourcebeheer:

### **Authenticatie**

* `POST /api/register`: Registreer een nieuwe gebruiker (alleen Firda e-mailadressen toegestaan)
* `POST /api/login`: Log in met e-mail en wachtwoord
* `POST /api/logout`: Log uit

### **Categorieën**

* `GET /api/categories`: Haal alle categorieën op
* `POST /api/categories`: Maak een nieuwe categorie aan (alleen door docenten)
* `PUT /api/categories/{id}`: Werk een categorie bij (alleen door docenten)
* `DELETE /api/categories/{id}`: Verwijder een categorie (alleen door docenten)

### **Items**

* `GET /api/items`: Haal alle items op
* `GET /api/items/{id}`: Haal een specifiek item op
* `POST /api/items`: Maak een nieuw item aan (alleen door docenten)
* `PUT /api/items/{id}`: Werk een item bij (alleen door docenten)
* `DELETE /api/items/{id}`: Verwijder een item (alleen door docenten)

### **Uitleenregistraties**

* `GET /api/loans`: Haal alle uitleenregistraties op
* `POST /api/loans`: Registreer een uitleenactie (alleen door docenten)
* `PUT /api/loans/{id}`: Werk de uitleenregistratie bij (bijvoorbeeld het inleveren van een item)

### **Schade-logboek**

* `POST /api/damages`: Voeg een schade-informatie toe (alleen door docenten bij retour)
* `GET /api/damages`: Haal alle schade-informatie op

### **Automatische e-mails**

De e-mails worden automatisch gestuurd bij het inleveren van items via een scheduler in Laravel:

* **24 uur voor inlevering**
* **24 uur na de inleverdatum, indien het item niet is ingeleverd**

---

## 4. **Middleware en Validatie**

### **Middleware**

* **auth**: Beveiligde routes die alleen toegankelijk zijn voor ingelogde gebruikers (docenten).
* **admin**: Beveiligde routes die alleen toegankelijk zijn voor admin-gebruikers (docenten met beheerdersrechten).

### **Validatie**

* Validatie van e-mailadressen voor registratie (moet eindigen op `@firda.nl` of `@student.firda.nl`).
* Validatie van invoer bij het toevoegen of bewerken van items en categorieën.
* Validatie bij uitleenregistraties, bijvoorbeeld: item moet beschikbaar zijn, student moet geregistreerd zijn.

---

## 5. **E-mailfunctionaliteit**

De e-mailfunctionaliteit wordt geregeld via Laravel’s ingebouwde `Mail` facade:

* **Uitleenherinnering**: Een herinnering 24 uur voor de inleverdatum.
* **Te-late herinnering**: Een e-mail wordt 24 uur na de inleverdatum gestuurd als het item nog niet is ingeleverd.

---

## 6. **Extra Notities**

* **Authenticatie**: Gebruik een op maat gemaakte registratie en login voor gebruikers.
* **JWT tokens** voor beveiligde sessies tussen frontend en API.
* **Tijdregistratie** voor uitleen en retour van items om automatisch te bepalen of een item te laat is.
