# REST API Documentation

Sovryx OS provides a comprehensive RESTful API for seamless integration with mobile applications, desktop clients, and third-party services.

**Base URL:** `https://yourdomain.com/api/v1`

---

## 🔒 Authentication

The API uses **Bearer Token** authentication. Tokens are generated upon successful login and must be included in the header of all subsequent requests.

**Header Format:**
```http
Authorization: Bearer <your_access_token>
Accept: application/json
Content-Type: application/json
```

---

## 🚦 Standard Status Codes

Sovryx OS API utilizes standard HTTP status codes:

| Code | Status | Description |
| :--- | :--- | :--- |
| `200` | OK | Request succeeded. |
| `201` | Created | Resource successfully created. |
| `400` | Bad Request | Validation error or malformed request. |
| `401` | Unauthorized | Missing or invalid authentication token. |
| `403` | Forbidden | Authenticated, but lacks required role/permission. |
| `404` | Not Found | The requested resource does not exist. |
| `429` | Too Many Requests | Rate limit exceeded. |
| `500` | Internal Server Error | Server-side application error. |

---

## 📦 Standard Response Format

All responses (success and error) follow a consistent JSON structure.

**Success Response:**
```json
{
  "success": true,
  "message": "Resource retrieved successfully.",
  "data": { ... }
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Validation failed.",
  "errors": {
    "email": ["The email field is required."]
  }
}
```

---

## 📚 Endpoints Overview

Below is a subset of the available API endpoints. Detailed documentation for all 100+ endpoints can be generated via Swagger/OpenAPI.

### 1. Authentication

#### `POST /auth/login`
Authenticates a user and returns a token.

**Request Body:**
```json
{
  "email": "admin@sovryxtech.com",
  "password": "securepassword123"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6...",
    "user": {
      "id": 1,
      "name": "Super Admin",
      "roles": ["admin"]
    }
  }
}
```

---

### 2. CRM (Clients)

#### `GET /clients`
Retrieve a paginated list of clients.

**Query Parameters:**
- `page` (int): Page number (default: 1)
- `limit` (int): Results per page (default: 20)
- `search` (string): Search by name or email.

#### `POST /clients`
Create a new client.

**Request Body:**
```json
{
  "company_name": "Acme Corp",
  "contact_name": "John Doe",
  "email": "john@acme.com",
  "phone": "+1234567890"
}
```

#### `GET /clients/{id}`
Retrieve specific client details.

#### `PUT /clients/{id}`
Update client information.

#### `DELETE /clients/{id}`
Delete (or soft-delete) a client.

---

### 3. Billing & Invoicing

#### `POST /invoices`
Generate a new invoice.

**Request Body:**
```json
{
  "client_id": 45,
  "issue_date": "2023-10-01",
  "due_date": "2023-10-15",
  "items": [
    {
      "description": "Web Development Services",
      "quantity": 1,
      "unit_price": 5000.00,
      "tax_rate": 13.0
    }
  ]
}
```

#### `POST /invoices/{id}/pay`
Record a payment against an invoice.

**Request Body:**
```json
{
  "amount": 5650.00,
  "payment_method": "Bank Transfer",
  "reference_number": "TXN-987654321"
}
```

---

### 4. Projects & Tasks

#### `GET /projects`
List all active projects.

#### `POST /projects/{id}/tasks`
Add a new task to a project.

**Request Body:**
```json
{
  "title": "Design Database Schema",
  "assigned_to": 12,
  "priority": "High",
  "due_date": "2023-10-05"
}
```

---

### 5. IT Operations

#### `GET /domains/expiring`
Get a list of domains expiring within the next 30 days.

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "domain_name": "exampleclient.com",
      "client_id": 14,
      "expiry_date": "2023-10-10",
      "days_remaining": 8
    }
  ]
}
```

---

## 🚧 Rate Limiting

To ensure stability, the API enforces rate limiting:
- **Authenticated Requests:** 1000 requests per hour per token.
- **Unauthenticated Requests (Login):** 10 requests per minute per IP.

If limits are exceeded, the API returns a `429 Too Many Requests` status with a `Retry-After` header.
