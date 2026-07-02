# API Documentation

Sovryx OS exposes a highly secure REST API for headless operations.

## 1. Base URL
All API requests must prefix the URI with `/api/` (e.g., `https://erp.sovryx.com/api/reports/finance`).

## 2. Authentication
Every request must include an `Authorization` header containing a valid Bearer token.
`Authorization: Bearer d3b07384d113edec49eaa6238ad5ff00`

If this token is missing or invalid, the global `ApiMiddleware` will instantly terminate the request with a `401 Unauthorized`.

## 3. Standardized Responses
All endpoints extending `App\Core\ApiController` return a strict JSON format:
```json
{
  "success": true,
  "message": "Operation completed.",
  "data": { ... }
}
```

## 4. Swagger UI
You can view the interactive, auto-generated OpenAPI 3.0 specification by navigating to `/api/docs` in your browser.
