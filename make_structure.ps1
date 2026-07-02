$directories = @(
    ".github/workflows",
    ".github/ISSUE_TEMPLATE",
    "app/Console/Commands",
    "app/Core",
    "app/Events",
    "app/Exceptions",
    "app/Helpers",
    "app/Http/Middleware",
    "app/Http/Requests",
    "app/Interfaces",
    "app/Jobs",
    "app/Libraries",
    "app/Listeners",
    "app/Mail",
    "app/Notifications",
    "app/Policies",
    "app/Providers",
    "app/Repositories",
    "app/Resources",
    "app/Services",
    "app/Traits",
    "app/Validators",
    "bootstrap/cache",
    "config",
    "database/migrations",
    "database/seeders",
    "database/factories",
    "docker/php",
    "docker/nginx",
    "docker/mysql",
    "docker/redis",
    "docs/api",
    "docs/architecture",
    "docs/manual",
    "modules",
    "plugins",
    "public/assets/css",
    "public/assets/js",
    "public/assets/images",
    "public/assets/fonts",
    "public/assets/vendor",
    "public/uploads",
    "public/installer",
    "resources/views/layouts",
    "resources/views/errors",
    "resources/views/emails",
    "resources/lang/en",
    "resources/lang/es",
    "resources/lang/fr",
    "resources/themes",
    "routes",
    "scripts",
    "storage/app/uploads",
    "storage/app/invoices",
    "storage/app/documents",
    "storage/app/contracts",
    "storage/app/reports",
    "storage/app/receipts",
    "storage/app/exports",
    "storage/app/imports",
    "storage/logs",
    "storage/cache",
    "storage/sessions",
    "storage/temp",
    "storage/backups",
    "tests/Unit",
    "tests/Feature",
    "tests/Browser"
)

foreach ($dir in $directories) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

$modules = @(
    "Authentication", "Dashboard", "CRM", "ERP", "Projects", "Tasks", 
    "Accounting", "Billing", "HRM", "Payroll", "Inventory", "Sales", 
    "Marketing", "Support", "Hosting", "Domains", "TrainingInstitute", 
    "SaaS", "Documents", "KnowledgeBase", "Reports", "Analytics", 
    "Settings", "Notifications", "AIAssistant", "VendorManagement", 
    "Procurement", "Assets", "Calendar", "WorkflowAutomation", 
    "AuditLogs", "ActivityLogs", "ClientPortal", "EmployeePortal", "API"
)

$moduleDirs = @("Controllers", "Models", "Views", "Routes", "Services", "Repositories", "Policies", "Validation", "Assets", "Docs")

foreach ($module in $modules) {
    foreach ($mdir in $moduleDirs) {
        New-Item -ItemType Directory -Force -Path "modules/$module/$mdir" | Out-Null
    }
}

$files = @(
    ".github/PULL_REQUEST_TEMPLATE.md",
    "app/Console/Scheduler.php",
    "app/Console/Kernel.php",
    "app/Core/BaseController.php",
    "app/Core/BaseModel.php",
    "app/Core/BaseService.php",
    "app/Core/BaseRepository.php",
    "app/Exceptions/Handler.php",
    "app/Exceptions/UnauthorizedException.php",
    "app/Helpers/StringHelper.php",
    "app/Helpers/DateHelper.php",
    "app/Helpers/FormatHelper.php",
    "app/Http/Kernel.php",
    "bootstrap/app.php",
    "config/app.php",
    "config/auth.php",
    "config/database.php",
    "config/modules.php",
    "config/mail.php",
    "config/services.php",
    "config/security.php",
    "public/index.php",
    "public/.htaccess",
    "routes/web.php",
    "routes/api.php",
    "routes/console.php",
    "routes/channels.php",
    "scripts/deploy.sh",
    "scripts/backup.sh",
    "scripts/monitor.sh",
    "storage/logs/sovryx.log",
    "storage/logs/error.log",
    "storage/logs/audit.log",
    "tests/bootstrap.php",
    ".env.example",
    ".gitignore",
    "phpunit.xml"
)

foreach ($file in $files) {
    if (-not (Test-Path $file)) {
        New-Item -ItemType File -Force -Path $file | Out-Null
    }
}
Write-Host "Folder structure created successfully!"
