# CRM Module (Elite Standard)

## Business Requirements
- Complete management of Sales Pipeline.
- Multi-tenant data isolation.
- Lead lifecycle tracking (New -> Won/Lost).
- Financial forecasting (Expected Revenue).

## Architecture
- **Model:** `Lead.php` (Entity definition)
- **Validator:** `LeadValidator.php` (Strict business rule validation)
- **Repository:** `LeadRepository.php` (Complex PDO logic, tenant isolated)
- **Service:** `LeadService.php` (Business layer orchestration)
- **Controller:** `LeadController.php` (HTTP interface)

## UI
- Bootstrap 5 offcanvas/modal forms.
- DataTables for searching/sorting (to be implemented via layout).
- Aggregate metrics cards.

## Future Improvements
- Integrate PHPMailer to send welcome emails on 'Qualified' stage.
- Add activity logging for state transitions.