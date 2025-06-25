# Uitleensysteem API Routes Reference

This document provides a quick reference for the most commonly used API routes in the Uitleensysteem application.

## Authentication Methods

The API supports two types of authentication:

### 1. User Authentication (Bearer Token)

For user-based authentication, users must log in to obtain a token:

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
  "access_token": "your_access_token",
  "token_type": "Bearer",
  "user": {
    "id": 1,
    "name": "User Name",
    "email": "your_email@example.com",
    "is_admin": true
  }
}
```

**Using the token:**
```
Authorization: Bearer your_access_token
```

### 2. API Key Authentication

For machine-to-machine or application-based authentication, use API keys:

**Header:**
```
X-API-KEY: your_api_key
```

For detailed information on API key management, see [API Key Guide](/docs/api_key_guide.md).

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

## API Key Protected Endpoints

These endpoints can be accessed using an API key for machine-to-machine communication.

### Get Available Items
**Endpoint:** `GET /api/items/available`
**Authentication:** API Key (X-API-KEY header)

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Laptop Dell XPS 13",
      "description": "High-performance laptop for development",
      "serial_number": "XPS-13-9380-001",
      "purchase_date": "2023-01-15",
      "status": "available",
      "category_id": 1,
      "category": {
        "id": 1,
        "name": "Electronics",
        "description": "Electronic devices and equipment"
      }
    },
    {
      "id": 2,
      "name": "Projector BenQ",
      "description": "4K projector for presentations",
      "serial_number": "BQ-4K-2023-002",
      "purchase_date": "2023-02-20",
      "status": "available",
      "category_id": 1,
      "category": {
        "id": 1,
        "name": "Electronics",
        "description": "Electronic devices and equipment"
      }
    }
  ]
}
```

### Get Overdue Loans
**Endpoint:** `GET /api/lendings/overdue`
**Authentication:** API Key (X-API-KEY header)

**Response:**
```json
{
  "data": [
    {
      "id": 5,
      "user_id": 3,
      "item_id": 7,
      "loan_date": "2023-05-01T00:00:00.000000Z",
      "due_date": "2023-05-15T00:00:00.000000Z",
      "returned_at": null,
      "notes": "Extended project use",
      "item": {
        "id": 7,
        "name": "DSLR Camera",
        "description": "Canon EOS 5D Mark IV",
        "serial_number": "CN-5D4-2022-007"
      },
      "user": {
        "id": 3,
        "name": "Jane Smith",
        "email": "jane.smith@firda.nl"
      }
    }
  ]
}
```