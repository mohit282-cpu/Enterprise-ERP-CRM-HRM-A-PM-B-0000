$basePath = "z:\xampp\htdocs\Enterprise-ERP-CRM-HRM-A-PM-B-0000"
$modulesPath = Join-Path $basePath "modules"

$modules = @(
    "Authentication", "CRM", "Accounting", "Billing", "HRM", "Projects", 
    "Inventory", "Hosting", "Domains", "Support", "Marketing", "Reports", 
    "Settings", "API", "Tasks", "Payroll", "Sales", "TrainingInstitute", 
    "SaaS", "Documents", "KnowledgeBase", "Analytics", "Notifications", 
    "AIAssistant", "VendorManagement", "Procurement", "Assets", "Calendar", 
    "WorkflowAutomation", "AuditLogs", "ActivityLogs", "ClientPortal", "EmployeePortal"
)

foreach ($module in $modules) {
    $docsPath = Join-Path $modulesPath "$module\Docs"
    
    # Ensure Docs directory exists
    if (-not (Test-Path $docsPath)) {
        New-Item -ItemType Directory -Force -Path $docsPath | Out-Null
    }

    $readmePath = Join-Path $docsPath "README.md"
    
    $description = ""
    switch ($module) {
        "Authentication" { $description = "Handles User Login, Registration, RBAC, and Sessions." }
        "CRM" { $description = "Customer Relationship Management. Tracks leads, deals, and customers." }
        "Accounting" { $description = "Manages General Ledger, Chart of Accounts, and Journal Entries." }
        "Billing" { $description = "Handles Invoices, Estimates, and Payments." }
        "HRM" { $description = "Human Resource Management for Employee records, Attendance, and Leave." }
        "Projects" { $description = "Project Management, milestones, and gantt charts." }
        "Inventory" { $description = "Warehouse tracking, stock movements, and product catalog." }
        "Hosting" { $description = "Server and hosting management." }
        "Domains" { $description = "Domain registration and DNS management." }
        "Support" { $description = "Helpdesk, ticketing, and customer support." }
        "Marketing" { $description = "Email campaigns, newsletters, and marketing automation." }
        "Reports" { $description = "Custom report generator across all modules." }
        "Settings" { $description = "Global system configuration and module settings." }
        "API" { $description = "External REST API gateway for integrations." }
        default { $description = "Core module for handling $module specific business logic." }
    }

    $content = @"
# $module Module

$description

## Architecture
This module follows the Sovryx OS HMVC Architecture, implementing:
- **Controllers:** HTTP Request handling
- **Services:** Business Logic processing
- **Repositories:** Database interaction (Repository Pattern)
- **Models:** Data structures
- **Views:** Module-specific UI components

## Developer Guidelines
- Ensure all business logic remains in the `Services/` directory.
- Database access must only happen via the `Repositories/`.
- Adhere to PSR-12 and strict typing for PHP 8.3+.
"@

    Set-Content -Path $readmePath -Value $content -Encoding UTF8
}

Write-Host "Generated README files for all modules successfully."
