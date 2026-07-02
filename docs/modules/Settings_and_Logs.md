# ⚙️ Settings, Audit & Activity Logs Module

## 1. Business Overview
Enterprise systems require intense auditability and highly flexible configurations. The Settings & Logs module allows Super Admins to define company-wide parameters (Currency, Timezones, API Keys) while simultaneously maintaining an immutable ledger of every critical action performed by any user in the system, ensuring complete compliance and accountability.

## 2. User Story
- **As an Administrator**, I want to configure the company's tax rates, upload our logo for invoices, and configure the SMTP email settings.
- **As a Compliance Officer**, I need to trace exactly who deleted an invoice and at what time, using an unalterable audit log.

## 3. Database Design
**Tables:**
- `settings`: `id`, `key` (e.g., `company_name`, `default_currency`), `value` (Text/JSON), `category` (e.g., `general`, `email`, `integrations`).
- `audit_logs`: `id`, `user_id`, `module` (e.g., `Invoice`), `action` (`CREATED`, `UPDATED`, `DELETED`), `record_id`, `old_values` (JSON), `new_values` (JSON), `ip_address`, `created_at`.
- `activity_logs`: `id`, `user_id`, `description` (e.g., "Logged in", "Downloaded report"), `created_at`.

## 4. Folder Structure
```text
modules/Settings/
├── Controllers/
│   ├── SettingController.php
│   └── AuditLogController.php
├── Models/
│   ├── Setting.php
│   └── AuditLog.php
├── Services/
│   ├── SettingsService.php
│   └── LoggerService.php
├── Repositories/
│   └── AuditRepository.php
├── Routes/
│   └── web.php
└── Views/
    ├── settings/
    │   ├── general.php
    │   └── integrations.php
    └── logs/
        └── index.php
```

## 5. Controllers
- `SettingController`: Renders forms for various configuration categories and processes bulk updates.
- `AuditLogController`: Provides a read-only, paginated, and filterable view of the `audit_logs` table.

## 6. Models
- `Setting`: Uses accessor/mutator methods to automatically decode/encode JSON values when interacting with complex settings (like API configurations).
- `AuditLog`: Relates to the `User` model to display who performed the action.

## 7. Services
- `SettingsService`: Handles the retrieval of settings, caching them globally (e.g., `Cache::rememberForever('settings')`) so the application doesn't query the database hundreds of times per request.
- `LoggerService`: A centralized service called by other modules (via Events/Observers) to write to the `audit_logs` and `activity_logs` tables.

## 8. Repository
- `AuditRepository`: Handles complex filtering for the logs UI (e.g., filtering by Date Range, Module, and User).

## 9. Routes
**Web (`routes/web.php`):**
- `GET /settings/general`
- `POST /settings/update`
- `GET /audit-logs`

## 10. Views
- `settings/general.php`: A vertical tabbed interface (Bootstrap Nav Pills) allowing seamless navigation between General, Financial, Email, and Integration settings.
- `logs/index.php`: A high-density DataTable showing the audit trail, with a "View Details" modal for deep JSON diffs.

## 11. API Endpoints
- `GET /api/v1/settings/public` - Returns non-sensitive settings (like company logo URL, default currency) required for the frontend.

## 12. Validation
- `UpdateSettingsRequest`: Extremely strict validation. E.g., `default_currency` must be a valid 3-letter ISO code. `smtp_port` must be numeric.

## 13. Permissions
- `manage_settings`: Required to alter configurations.
- `view_audit_logs`: Required to view the immutable ledger.

## 14. Workflow (Audit Logging)
1. User updates a Client record in the CRM module.
2. The CRM Repository fires a `ModelUpdated` event.
3. The `LoggerService` listens to this event. It captures the `old` state and the `new` state.
4. `LoggerService` writes a JSON diff to the `audit_logs` table asynchronously (via Jobs, if configured) to prevent slowing down the user's request.

## 15. UI Components
- **JSON Diff Viewer:** A specialized UI component in the Audit Log modal that highlights what changed (e.g., Red for old value, Green for new value).
- **Toggle Switches:** Bootstrap 5 switches for boolean settings (e.g., "Enable Maintenance Mode").

## 16. Security
- **Immutability:** The `audit_logs` table does NOT have an `UPDATE` or `DELETE` API/Controller method. It is append-only by design.
- **Cache Invalidation:** When settings are updated, the `SettingsService` must immediately purge the Redis/File cache to prevent serving stale configurations.

## 17. Testing
- **Integration Tests:** Update a setting via POST and verify that the database updates AND the cache is flushed.
- **Event Tests:** Mock a database update in another module and assert that the `LoggerService` correctly intercepts and writes to the `audit_logs` table.

## 18. Future Improvements
- Integrate with external SIEM (Security Information and Event Management) tools to forward critical audit logs (like privilege escalations) to external compliance servers in real-time.
