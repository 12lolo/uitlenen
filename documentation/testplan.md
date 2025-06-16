
# 📋 **Testplan – Uitleen-API Firda**

## 1. Inleiding

Dit testplan beschrijft de strategie, aanpak, scope en uitvoering van de tests voor de uitleen-API die het beheer van uitleenmaterialen bij Firda ondersteunt. De API moet voldoen aan de gestelde functionele en niet-functionele eisen.

## 2. Doelstellingen

* Verifiëren dat de API de juiste functionaliteit biedt voor het beheren van materialen, uitleenprocessen, en gebruikersbeheer.
* Testen van de integriteit van gegevens zoals itemstatus, schade-informatie en uitleengegevens.
* Controleren of de prestaties en beveiliging voldoen aan de niet-functionele eisen.
* Verzekeren dat de API stabiel is en geen kritieke fouten vertoont.

## 3. Scope van testen

De scope omvat de volgende testgebieden:

* **Functionele tests**: Verifiëren van basisfunctionaliteit zoals het inloggen, het bekijken van categorieën, het beheren van items en het genereren van e-mailherinneringen.
* **Integratietests**: Verifiëren of alle onderdelen van het systeem correct samenwerken (bijv. API-interacties, databaseverbindingen, e-mailfunctionaliteit).
* **Beveiligingstests**: Testen of alleen geautoriseerde gebruikers toegang hebben tot bepaalde functionaliteiten.
* **Prestatie- en belastingtests**: Beoordelen van de snelheid en belastingscapaciteit van de API.
* **Gebruiksvriendelijkheid**: Zorgen dat de API goed communiceert met de front-end en gemakkelijk toegankelijk is voor de beoogde gebruikers.

## 4. Teststrategie

### 4.1 **Testmethoden**

* **Handmatige tests**: De meeste tests worden handmatig uitgevoerd, waarbij de API-aanroepen handmatig worden getest via Postman of een vergelijkbare tool.
* **Automatische tests**: Voor kritieke functionaliteit kunnen automatische tests worden geschreven met PHPUnit of een andere geschikte tool.

### 4.2 **Testsoorten**

* **Unit Tests**: Kleine eenheden van de API (bijv. individuele routes, validatie van gebruikersinvoer) zullen worden getest.
* **Functionele Tests**: Alle basisfunctionaliteit van de API zal worden getest (bijv. het toevoegen, bijwerken en verwijderen van items).
* **Integratietests**: Het testen van de interactie tussen de API en de database, evenals de communicatie met e-mailservers.
* **Security Tests**: Verifiëren of er beveiligingslekken zijn, zoals onbevoegde toegang of misbruik van de API.
* **Acceptatietests**: De API moet voldoen aan de eisen die gesteld zijn in het functionele ontwerp en moet worden goedgekeurd door de projectstakeholders.

## 5. Testcases

### 5.1 **Inloggen als docent**

| Test ID                | 01                                                                         |
| ---------------------- | -------------------------------------------------------------------------- |
| **Testcase**           | Inloggen met een geldig schoolaccount                                      |
| **Acties**             | 1. Vul geldig e-mailadres en wachtwoord in.<br>2. Druk op 'Inloggen'       |
| **Verwacht resultaat** | Gebruiker wordt ingelogd en krijgt toegang tot de API                      |
| **Opmerkingen**        | - Testen met een e-mailadres dat eindigt op @firda.nl of @student.firda.nl |

### 5.2 **Categorieën bekijken (student)**

| Test ID                | 02                                                    |
| ---------------------- | ----------------------------------------------------- |
| **Testcase**           | Bekijken van beschikbare categorieën zonder inloggen  |
| **Acties**             | 1. Maak een GET-verzoek naar `/api/categories`        |
| **Verwacht resultaat** | API retourneert een lijst met beschikbare categorieën |
| **Opmerkingen**        | Geen login vereist                                    |

### 5.3 **Item uitlenen (docent)**

| Test ID                | 03                                                                                                  |
| ---------------------- | --------------------------------------------------------------------------------------------------- |
| **Testcase**           | Een docent leent een item uit aan een student                                                       |
| **Acties**             | 1. Log in als docent.<br>2. Selecteer een item en vul studentgegevens in.<br>3. Bevestig uitlening. |
| **Verwacht resultaat** | Het item is gemarkeerd als uitgeleend en gekoppeld aan de student                                   |
| **Opmerkingen**        | Alleen beschikbaar items kunnen worden uitgeleend.                                                  |

### 5.4 **Schade registreren (docent)**

| Test ID                | 04                                                                              |
| ---------------------- | ------------------------------------------------------------------------------- |
| **Testcase**           | Het registreren van schade na terugname van een item                            |
| **Acties**             | 1. Markeer item als teruggebracht.<br>2. Voer schade in.<br>3. Sla schade op.   |
| **Verwacht resultaat** | Schade wordt correct geregistreerd in de database met datum en lenerinformatie. |
| **Opmerkingen**        | Schade moet optioneel foto’s bevatten.                                          |

### 5.5 **Automatische e-mailherinneringen**

| Test ID                | 05                                                                                            |
| ---------------------- | --------------------------------------------------------------------------------------------- |
| **Testcase**           | E-mailherinnering sturen voor iteminlevering                                                  |
| **Acties**             | 1. Wacht tot 24 uur voor inlevering.<br>2. Controleer of de student een herinnering ontvangt. |
| **Verwacht resultaat** | E-mail wordt correct verzonden en bevat herinnering voor inlevering.                          |
| **Opmerkingen**        | E-mail moet tijdig en duidelijk zijn.                                                         |

## 6. Testomgevingen

De tests worden uitgevoerd in de volgende omgevingen:

* **Development**: Lokale ontwikkelomgeving met PHPUnit en Postman voor handmatige tests.
* **Staging**: Een stagingomgeving die de productie-omgeving nabootst, met echte gegevens en e-mailfunctionaliteit.

## 7. Testdata

Er wordt gebruikgemaakt van testgegevens voor studenten, docenten, en uitleenitems. Testaccounts worden aangemaakt voor de tests:

* **Studenten**: Testaccounts met een e-mailadres eindigend op @firda.nl of @student.firda.nl.
* **Docenten**: Testaccounts met beheerdersrechten.

## 8. Risico’s en Beperkingen

* **Beveiligingstests**: Risico van niet-detectie van kwetsbaarheden zoals SQL-injectie en XSS.
* **Prestaties**: De belastingtest kan afhankelijk zijn van de beschikbaarheid van de stagingomgeving.

## 9. Goedkeuring

De testresultaten zullen worden goedgekeurd door de projectmanager en stakeholders.
