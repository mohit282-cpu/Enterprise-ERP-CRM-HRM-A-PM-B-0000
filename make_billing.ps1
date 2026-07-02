$basePath = "z:\xampp\htdocs\Enterprise-ERP-CRM-HRM-A-PM-B-0000"

# Directories
$dirs = @(
    "database\migrations",
    "modules\Billing\Models",
    "modules\Billing\Repositories",
    "modules\Billing\Services",
    "modules\Billing\Controllers",
    "modules\Billing\Routes",
    "modules\Billing\Views\invoices",
    "modules\Billing\Views\payments"
)

foreach ($dir in $dirs) {
    $fullPath = Join-Path $basePath $dir
    if (-not (Test-Path $fullPath)) { New-Item -ItemType Directory -Force -Path $fullPath | Out-Null }
}

# 1. Database Migration
$migrationPath = Join-Path $basePath "database\migrations\2026_01_07_000000_create_billing_tables.php"
$migrationContent = @'
<?php
class CreateBillingTables {
    public function up($db) {
        $sql = "
        CREATE TABLE receipts (
            id INT AUTO_INCREMENT PRIMARY KEY,
            receipt_number VARCHAR(100) NOT NULL UNIQUE,
            payment_id INT NOT NULL,
            customer_id INT NOT NULL,
            amount DECIMAL(15,4) NOT NULL,
            issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE,
            FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
        );

        CREATE TABLE refunds (
            id INT AUTO_INCREMENT PRIMARY KEY,
            payment_id INT NOT NULL,
            amount DECIMAL(15,4) NOT NULL,
            reason TEXT,
            processed_by INT,
            processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE RESTRICT,
            FOREIGN KEY (processed_by) REFERENCES users(id) ON DELETE SET NULL
        );

        CREATE TABLE invoice_templates (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            html_content LONGTEXT,
            css_content LONGTEXT,
            is_default BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        ";
        $db->exec($sql);
    }
    public function down($db) {
        $db->exec("DROP TABLE IF EXISTS invoice_templates, refunds, receipts;");
    }
}
'@
Set-Content -Path $migrationPath -Value $migrationContent -Encoding UTF8

# 2. Models
$invoiceModelPath = Join-Path $basePath "modules\Billing\Models\Invoice.php"
Set-Content -Path $invoiceModelPath -Value "<?php namespace Modules\Billing\Models; use App\Core\BaseModel; class Invoice extends BaseModel { protected string `$table = 'invoices'; }" -Encoding UTF8

$paymentModelPath = Join-Path $basePath "modules\Billing\Models\Payment.php"
Set-Content -Path $paymentModelPath -Value "<?php namespace Modules\Billing\Models; use App\Core\BaseModel; class Payment extends BaseModel { protected string `$table = 'payments'; }" -Encoding UTF8

# 3. Repositories
$invoiceRepoPath = Join-Path $basePath "modules\Billing\Repositories\InvoiceRepository.php"
$invoiceRepoContent = @'
<?php
namespace Modules\Billing\Repositories;
use Modules\Billing\Models\Invoice;
use PDO;

class InvoiceRepository {
    private Invoice $model;
    public function __construct(Invoice $model) { $this->model = $model; }

    public function createInvoice(array $data): int {
        $stmt = $this->model->getDb()->prepare("
            INSERT INTO invoices (invoice_number, customer_id, subtotal, tax_total, grand_total, status, issue_date, due_date) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ");
        $stmt->execute([
            $data['invoice_number'], $data['customer_id'], $data['subtotal'], 
            $data['tax_total'], $data['grand_total'], 'draft', $data['issue_date'], $data['due_date']
        ]);
        return (int)$this->model->getDb()->lastInsertId();
    }
}
'@
Set-Content -Path $invoiceRepoPath -Value $invoiceRepoContent -Encoding UTF8

# 4. Services
$invoiceServicePath = Join-Path $basePath "modules\Billing\Services\InvoiceService.php"
$invoiceServiceContent = @'
<?php
namespace Modules\Billing\Services;
use Modules\Billing\Repositories\InvoiceRepository;

class InvoiceService {
    private InvoiceRepository $repo;
    const VAT_RATE = 0.13; // 13% VAT

    public function __construct(InvoiceRepository $repo) { $this->repo = $repo; }

    public function generateInvoice(array $data): int {
        // Calculate VAT 13%
        $subtotal = (float)$data['subtotal'];
        $tax = $subtotal * self::VAT_RATE;
        $grandTotal = $subtotal + $tax;

        $invoiceData = [
            'invoice_number' => 'INV-' . strtoupper(uniqid()),
            'customer_id' => $data['customer_id'],
            'subtotal' => $subtotal,
            'tax_total' => $tax,
            'grand_total' => $grandTotal,
            'issue_date' => date('Y-m-d'),
            'due_date' => date('Y-m-d', strtotime('+30 days'))
        ];

        return $this->repo->createInvoice($invoiceData);
    }
}
'@
Set-Content -Path $invoiceServicePath -Value $invoiceServiceContent -Encoding UTF8

$pdfServicePath = Join-Path $basePath "modules\Billing\Services\PdfService.php"
$pdfServiceContent = @'
<?php
namespace Modules\Billing\Services;

class PdfService {
    /**
     * Abstracted PDF generator. Can hook into DomPDF or mpdf later.
     */
    public function generateInvoicePdf(int $invoiceId): string {
        // Stub for Phase 2: Render HTML template and stream PDF
        return "PDF_STREAM_DATA_FOR_INVOICE_$invoiceId";
    }
}
'@
Set-Content -Path $pdfServicePath -Value $pdfServiceContent -Encoding UTF8

$notificationServicePath = Join-Path $basePath "modules\Billing\Services\NotificationService.php"
$notificationServiceContent = @'
<?php
namespace Modules\Billing\Services;

class NotificationService {
    /**
     * Stub for Phase 2: WhatsApp & Email integrations
     */
    public function sendInvoiceViaWhatsApp(int $invoiceId, string $phone): bool {
        // e.g. Twilio API call
        return true;
    }

    public function sendInvoiceViaEmail(int $invoiceId, string $email): bool {
        // e.g. PHPMailer or SMTP service
        return true;
    }
}
'@
Set-Content -Path $notificationServicePath -Value $notificationServiceContent -Encoding UTF8

# 5. Controllers
$invoiceControllerPath = Join-Path $basePath "modules\Billing\Controllers\InvoiceController.php"
$invoiceControllerContent = @'
<?php
namespace Modules\Billing\Controllers;
use App\Core\BaseController;
use Modules\Billing\Services\InvoiceService;

class InvoiceController extends BaseController {
    private InvoiceService $service;
    public function __construct(InvoiceService $service) { $this->service = $service; }

    public function index() {
        return $this->view('invoices/index', [], 'Billing');
    }

    public function create() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $id = $this->service->generateInvoice($_POST);
            return $this->redirect("/billing/invoices/$id");
        }
        return $this->view('invoices/create', [], 'Billing');
    }
}
'@
Set-Content -Path $invoiceControllerPath -Value $invoiceControllerContent -Encoding UTF8

# 6. Routes
$webRoutesPath = Join-Path $basePath "modules\Billing\Routes\web.php"
Set-Content -Path $webRoutesPath -Value "<?php return [ 'GET /billing/invoices' => [Modules\Billing\Controllers\InvoiceController::class, 'index'], 'POST /billing/invoices' => [Modules\Billing\Controllers\InvoiceController::class, 'create'] ];" -Encoding UTF8

$apiRoutesPath = Join-Path $basePath "modules\Billing\Routes\api.php"
Set-Content -Path $apiRoutesPath -Value "<?php return [ ];" -Encoding UTF8

# 7. Views
$invoiceIndexView = Join-Path $basePath "modules\Billing\Views\invoices\index.php"
$invoiceIndexViewContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Invoices - Billing</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container mt-4">
        <h2>Invoices</h2>
        <a href="/billing/invoices/create" class="btn btn-primary">Create Invoice</a>
        <!-- List will go here -->
    </div>
</body>
</html>
'@
Set-Content -Path $invoiceIndexView -Value $invoiceIndexViewContent -Encoding UTF8

Write-Host "Billing module Phase 1 built successfully."
