# 📄 Projectplan – Uitleen-API Firda

## Projecttitel
**Uitleen-API voor Firda**

## Samenvatting
Op Firda is veel uitleenmateriaal beschikbaar voor studenten en docenten. Dit project bouwt een Laravel API waarmee gebruikers het uitleensysteem kunnen gebruiken. Studenten kunnen materialen bekijken, en docenten (na inloggen) beheren de categorieën, items, uitleningen en inspecties. Ook worden e-mails verstuurd bij naderende of te late inleverdata. Deze API vormt de backend voor een toekomstige (web)applicatie.

## Doel van het project
Het doel is het ontwikkelen van een veilige en schaalbare uitleen-API waarmee:
- Studenten eenvoudig materialen kunnen opzoeken.
- Docenten materialen en uitleenprocessen kunnen beheren.
- Beheerders zicht hebben op terugbreng- en schadegegevens.
- E-mails worden verstuurd bij naderende deadlines en te late inlevering.

## Scope

### In scope
- Ontwikkeling van een RESTful API met Laravel
- Authenticatie en autorisatie (alleen docenten kunnen inloggen)
- CRUD-functionaliteit voor categorieën, items, docenten, uitleningen
- Automatische e-mails bij deadlines
- Logging van schade en uitleengeschiedenis
- Documentatie (projectplan, FO, TO, testplan, testscenario’s, testrapport)

### Out of scope
- Frontend (de API is bedoeld als basis voor een later te bouwen applicatie)
- Accountregistratie voor studenten (gebruikersbeheer beperkt tot docenten)
- Betalingsverwerking of facturatie (alleen logging voor schade)

## Tijdsplanning (4 weken)

| Week | Activiteiten |
|------|--------------|
| **Week 1** | Projectvoorbereiding, Git opzetten, projectplan + FO schrijven, databaseontwerp maken |
| **Week 2** | Bouw van categorie- en item-functionaliteit (CRUD), authenticatie, start uitleenlogica |
| **Week 3** | Mailfunctionaliteit + schade-inspectiesysteem + logging, afronden TO, testplan & scenario’s maken |
| **Week 4** | Testen, debuggen, testrapport schrijven, documentatie afronden, project opleveren |

## Rollen en verantwoordelijkheden

| Rol | Verantwoordelijke                       |
|-----|-----------------------------------------|
| Ontwikkelaar | Senne Visser                            |
| Code schrijven | Senne Visser                            |
| Documentatie maken | Senne Visser                            |
| Testen | Senne Visser                            |
| Feedback vragen | klasgenoten, docenten en gpt my beloved |
