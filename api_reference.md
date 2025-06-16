# Uitleensysteem API Routes Reference

This document provides a quick reference for the most commonly used API routes in the Uitleensysteem application.

## Authentication

### Login
**Endpoint:** `POST /api/login`

**Request Body:**
```json
{
  "email": "your_email@example.com",
  "password": "your_password"
}
```

**Response:**
```json
{
  "token": "your_access_token",
  "user": {
    "id": 1,
    "name": "User Name",
    "email": "your_email@example.com",
    "role": "admin"
  }
}
```

## Categories

### Get All Categories
**Endpoint:** `GET /api/categories`

**Response:**
```json
[
  {
    "id": 1,
    "name": "Electronics",
    "description": "Electronic devices and equipment"
  },
  {
    "id": 2,
    "name": "Books",
    "description": "Reading materials"
  }
]
```

### Create Category
**Endpoint:** `POST /api/categories`

**Request Body:**
```json
{
  "name": "New Category",
  "description": "Description of the new category"
}
```

**Response:**
```json
{
  "message": "Categorie succesvol aangemaakt",
  "category": {
    "name": "New Category",
    "description": "Description of the new category",
    "id": 3
  }
}
```

## Items

### Get All Items
**Endpoint:** `GET /api/items`

**Response:**
```json
[
  {
    "id": 1,
    "name": "Laptop",
    "description": "Dell XPS 13",
    "category_id": 1,
    "status": "available",
    "location": "Storage Room A",
    "inventory_number": "INV-001"
  }
]
```

### Get Item by ID
**Endpoint:** `GET /api/items/{id}`

**Response:**
```json
{
  "id": 1,
  "name": "Laptop",
  "description": "Dell XPS 13",
  "category_id": 1,
  "status": "available",
  "location": "Storage Room A",
  "inventory_number": "INV-001"
}
```

### Create Item
**Endpoint:** `POST /api/items`

**Request Body:**
```json
{
  "title": "New Item",
  "description": "Description of the new item",
  "category_id": 1,
  "status": "available",
  "location": "Storage location",
  "inventory_number": "INV-002"
}
```

**Response:**
```json
{
  "message": "Item succesvol aangemaakt",
  "item": {
    "title": "New Item",
    "description": "Description of the new item",
    "category_id": 1,
    "status": "available",
    "location": "Storage location",
    "inventory_number": "INV-002",
    "id": 2
  }
}
```

### Update Item
**Endpoint:** `PUT /api/items/{id}`

**Request Body:**
```json
{
  "title": "Updated Item Name",
  "description": "Updated description",
  "category_id": 1,
  "status": "unavailable",
  "location": "New Location",
  "inventory_number": "INV-002"
}
```

### Delete Item
**Endpoint:** `DELETE /api/items/{id}`

**Response:**
```json
{
  "message": "Item succesvol verwijderd"
}
```

## Loans (Lendings)

### Get All Loans
**Endpoint:** `GET /api/lendings`

**Response:**
```json
[
  {
    "id": 1,
    "item_id": 1,
    "student_name": "John Doe",
    "student_email": "john.doe@student.firda.nl",
    "loaned_at": "2025-06-10T14:30:00",
    "due_date": "2025-06-17T14:30:00",
    "returned_at": null,
    "notes": "For class project",
    "user_id": 1
  }
]
```

### Create Loan
**Endpoint:** `POST /api/lendings`

**Request Body:**
```json
{
  "item_id": 1,
  "student_name": "John Doe",
  "student_email": "john.doe@student.firda.nl",
  "due_date": "2025-06-19",
  "notes": "For class project"
}
```

**Response:**
```json
{
  "message": "Item succesvol uitgeleend",
  "loan": {
    "item_id": 1,
    "student_name": "John Doe",
    "student_email": "john.doe@student.firda.nl",
    "due_date": "2025-06-19",
    "notes": "For class project",
    "user_id": 1,
    "id": 1
  }
}
```

### Return Item
**Endpoint:** `POST /api/lendings/{id}/return`

**Request Body:**
```json
{
  "condition": "good",
  "notes": "Returned in good condition"
}
```

**Response:**
```json
{
  "message": "Item succesvol geretourneerd",
  "loan": {
    "id": 1,
    "item_id": 1,
    "student_name": "John Doe",
    "student_email": "john.doe@student.firda.nl",
    "loaned_at": "2025-06-10T14:30:00",
    "due_date": "2025-06-17T14:30:00",
    "returned_at": "2025-06-12T09:45:00",
    "return_notes": "Returned in good condition",
    "notes": "For class project",
    "user_id": 1,
    "returned_to_user_id": 1
  }
}
```

## Damage Reports

### Report Damage
**Endpoint:** `POST /api/items/{id}/damage`

**Request Body:**
```json
{
  "description": "Cracked screen",
  "severity": "moderate"
}
```

**Response:**
```json
{
  "message": "Schade succesvol gemeld",
  "damage": {
    "item_id": 1,
    "description": "Cracked screen",
    "severity": "moderate",
    "reported_by": 1,
    "id": 1
  }
}
```

### Get All Damages
**Endpoint:** `GET /api/damages`

**Response:**
```json
[
  {
    "id": 1,
    "item_id": 1,
    "description": "Cracked screen",
    "severity": "moderate",
    "reported_at": "2025-06-12T10:15:00",
    "reported_by": 1,
    "item": {
      "id": 1,
      "name": "Laptop",
      "description": "Dell XPS 13"
    }
  }
]
```

## User Management (Admin Only)

### Get All Users
**Endpoint:** `GET /api/users`

**Response:**
```json
[
  {
    "id": 1,
    "name": "Admin User",
    "email": "admin@firda.nl",
    "role": "admin",
    "department": "IT"
  },
  {
    "id": 2,
    "name": "Regular User",
    "email": "user@firda.nl",
    "role": "user",
    "department": "Science"
  }
]
```

### Create User
**Endpoint:** `POST /api/users`

**Request Body:**
```json
{
  "name": "New User",
  "email": "newuser@firda.nl",
  "password": "secure_password",
  "role": "user",
  "department": "Mathematics"
}
```

**Response:**
```json
{
  "message": "Gebruiker succesvol aangemaakt",
  "user": {
    "name": "New User",
    "email": "newuser@firda.nl",
    "role": "user",
    "department": "Mathematics",
    "id": 3
  }
}
```

## Format Endpoints

These endpoints provide information about the expected format for creating or updating resources:

- **Login Format:** `GET /api/login/format`
- **Register Format:** `GET /api/register/format`
- **Category Format:** `GET /api/categories/format`
- **Category Update Format:** `GET /api/categories/update/format`
- **Item Format:** `GET /api/items/format`
- **Item Update Format:** `GET /api/items/update/format`
- **Lending Format:** `GET /api/lendings/format`
- **Return Item Format:** `GET /api/lendings/return/format`
- **Damage Format:** `GET /api/items/damage/format`
- **User Format:** `GET /api/users/format`

Use these endpoints to get the expected JSON structure for your requests.
