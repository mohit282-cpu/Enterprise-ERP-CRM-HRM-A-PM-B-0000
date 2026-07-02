# Testing Guide

Quality assurance is paramount for **Sovryx OS**. Since the system handles enterprise financials, payroll, and CRM data, rigorous testing is mandated for all contributions.

This guide outlines the testing strategies, tools, and expectations for the project.

---

## 🧪 1. Unit Testing

Unit tests ensure that individual components (Classes, Methods, Services) function correctly in isolation.

- **Tool:** `PHPUnit`
- **Location:** `/tests/Unit/`
- **Focus Areas:**
  - Mathematical calculations (e.g., Tax calculation, Payroll deductions).
  - String formatting and data sanitization Helpers.
  - Core Service logic isolated from the database.

**Running Unit Tests:**
```bash
./vendor/bin/phpunit --testsuite Unit
```

**Example Unit Test:**
```php
public function test_invoice_total_calculation_with_tax()
{
    $calculator = new InvoiceCalculator();
    $subtotal = 1000.00;
    $taxRate = 13.0; // 13%
    
    $total = $calculator->calculateTotal($subtotal, $taxRate);
    
    $this->assertEquals(1130.00, $total);
}
```

---

## 🔗 2. Integration Testing

Integration tests verify that different parts of the system (Controllers, Models, Database) work together seamlessly.

- **Tool:** `PHPUnit` (with an in-memory or dedicated testing database).
- **Location:** `/tests/Integration/`
- **Focus Areas:**
  - API endpoint responses (JSON structure and status codes).
  - Database CRUD operations (ensuring records are saved and retrieved correctly).
  - Middleware behavior (e.g., testing if an unauthorized user is blocked).

**Running Integration Tests:**
```bash
# Ensure you are using the .env.testing file
php sovryx migrate --env=testing
./vendor/bin/phpunit --testsuite Integration
```

---

## 🛡 3. Security Testing

Security tests are designed to exploit the application to ensure defenses hold up against OWASP Top 10 vulnerabilities.

- **Static Application Security Testing (SAST):**
  - Run tools like **PHPStan** or **Psalm** to detect logical flaws and type issues.
- **Dynamic Checks:**
  - Ensure CSRF tokens are validated on POST requests.
  - Attempt SQL injection strings in integration tests to ensure PDO parameterization blocks them.
  - Check XSS by injecting `<script>` tags into text inputs and ensuring they are escaped upon rendering.

---

## 🚀 4. Performance Testing

Enterprise ERPs must remain fast even with millions of ledger entries.

- **Tools:** Apache JMeter, K6, or Laravel Dusk (if using a specific framework wrapper).
- **Focus Areas:**
  - API load limits (ensuring endpoints respond in <200ms under load).
  - Database query optimization (checking for N+1 issues).
  - Memory leak detection during heavy cron jobs (e.g., mass billing generation).

---

## 🌐 5. API Testing

The REST API must be strictly verified as it serves external clients and mobile apps.

- **Tool:** Postman (Collections) or PHPUnit integration tests.
- **Expectations:**
  - Every endpoint must be tested for `200 OK` success paths.
  - Every endpoint must be tested for `422 Validation Error` paths.
  - Every endpoint must be tested for `401/403 Auth` failures.

---

## 🖥 6. UI & E2E Testing (Future Implementation)

End-to-End (E2E) testing mimics real user behavior in a browser environment.

- **Proposed Tools:** Cypress, Selenium, or Playwright.
- **Focus Areas:**
  - Critical user journeys (e.g., Admin logs in -> creates Client -> creates Invoice -> marks as Paid).
  - Verifying JavaScript behavior (e.g., AJAX modals opening, DataTables sorting).
  - Checking responsive design breakpoints.

---

## 📜 Code Coverage Requirements

Sovryx OS maintains a strict code coverage requirement to ensure system reliability.

- **Minimum Total Coverage:** `80%`
- **Minimum Core Coverage:** `95%` (Billing, Auth, Payroll, Accounting)

To generate a coverage report (Requires Xdebug):
```bash
./vendor/bin/phpunit --coverage-html public/coverage-report/
```
