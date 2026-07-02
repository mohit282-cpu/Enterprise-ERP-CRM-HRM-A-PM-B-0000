$basePath = "z:\xampp\htdocs\Enterprise-ERP-CRM-HRM-A-PM-B-0000"

# Directories
$dirs = @(
    "database\migrations",
    "modules\CRM\Models",
    "modules\CRM\Repositories",
    "modules\CRM\Services",
    "modules\CRM\Controllers",
    "modules\CRM\Routes",
    "modules\CRM\Views\customers",
    "modules\CRM\Views\leads"
)

foreach ($dir in $dirs) {
    $fullPath = Join-Path $basePath $dir
    if (-not (Test-Path $fullPath)) { New-Item -ItemType Directory -Force -Path $fullPath | Out-Null }
}

# 1. Database Migration
$migrationPath = Join-Path $basePath "database\migrations\2026_01_06_000000_create_crm_tables.php"
$migrationContent = @'
<?php
class CreateCrmTables {
    public function up($db) {
        $sql = "
        CREATE TABLE contacts (
            id INT AUTO_INCREMENT PRIMARY KEY,
            customer_id INT NOT NULL,
            first_name VARCHAR(100) NOT NULL,
            last_name VARCHAR(100) NOT NULL,
            email VARCHAR(255),
            phone VARCHAR(50),
            position VARCHAR(100),
            is_primary BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
        );

        CREATE TABLE notes (
            id INT AUTO_INCREMENT PRIMARY KEY,
            model_type VARCHAR(50) NOT NULL, -- e.g., 'Lead', 'Customer'
            model_id INT NOT NULL,
            user_id INT NOT NULL,
            content TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );

        CREATE TABLE follow_ups (
            id INT AUTO_INCREMENT PRIMARY KEY,
            lead_id INT,
            customer_id INT,
            user_id INT NOT NULL,
            type ENUM('call', 'email', 'meeting') DEFAULT 'call',
            status ENUM('pending', 'completed', 'cancelled') DEFAULT 'pending',
            scheduled_at DATETIME NOT NULL,
            notes TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );

        CREATE TABLE quotations (
            id INT AUTO_INCREMENT PRIMARY KEY,
            quote_number VARCHAR(100) NOT NULL UNIQUE,
            customer_id INT,
            lead_id INT,
            subtotal DECIMAL(15,4) DEFAULT 0.0000,
            grand_total DECIMAL(15,4) DEFAULT 0.0000,
            status ENUM('draft', 'sent', 'accepted', 'rejected') DEFAULT 'draft',
            valid_until DATE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        );
        ";
        $db->exec($sql);
    }
    public function down($db) {
        $db->exec("DROP TABLE IF EXISTS quotations, follow_ups, notes, contacts;");
    }
}
'@
Set-Content -Path $migrationPath -Value $migrationContent -Encoding UTF8

# 2. Models
$contactPath = Join-Path $basePath "modules\CRM\Models\Contact.php"
Set-Content -Path $contactPath -Value "<?php namespace Modules\CRM\Models; use App\Core\BaseModel; class Contact extends BaseModel { protected string `$table = 'contacts'; }" -Encoding UTF8

$leadPath = Join-Path $basePath "modules\CRM\Models\Lead.php"
Set-Content -Path $leadPath -Value "<?php namespace Modules\CRM\Models; use App\Core\BaseModel; class Lead extends BaseModel { protected string `$table = 'leads'; }" -Encoding UTF8

# 3. Repositories
$leadRepoPath = Join-Path $basePath "modules\CRM\Repositories\LeadRepository.php"
$leadRepoContent = @'
<?php
namespace Modules\CRM\Repositories;
use Modules\CRM\Models\Lead;
use PDO;

class LeadRepository {
    private Lead $model;
    public function __construct(Lead $model) { $this->model = $model; }

    public function getLeadsByStage(): array {
        $stmt = $this->model->getDb()->query("SELECT * FROM leads ORDER BY created_at DESC");
        $leads = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        $grouped = ['new' => [], 'contacted' => [], 'qualified' => [], 'won' => [], 'lost' => []];
        foreach ($leads as $lead) {
            $grouped[$lead['status']][] = $lead;
        }
        return $grouped;
    }

    public function updateStage(int $id, string $status): bool {
        $stmt = $this->model->getDb()->prepare("UPDATE leads SET status = ? WHERE id = ?");
        return $stmt->execute([$status, $id]);
    }
}
'@
Set-Content -Path $leadRepoPath -Value $leadRepoContent -Encoding UTF8

# 4. Services
$leadServicePath = Join-Path $basePath "modules\CRM\Services\LeadService.php"
$leadServiceContent = @'
<?php
namespace Modules\CRM\Services;
use Modules\CRM\Repositories\LeadRepository;

class LeadService {
    private LeadRepository $repo;
    public function __construct(LeadRepository $repo) { $this->repo = $repo; }

    public function getPipeline(): array {
        return $this->repo->getLeadsByStage();
    }
    
    public function updateLeadStage(int $id, string $newStage): bool {
        // Here we could add logic to create a Customer if stage == 'won'
        return $this->repo->updateStage($id, $newStage);
    }
}
'@
Set-Content -Path $leadServicePath -Value $leadServiceContent -Encoding UTF8

# 5. Controllers
$leadControllerPath = Join-Path $basePath "modules\CRM\Controllers\LeadController.php"
$leadControllerContent = @'
<?php
namespace Modules\CRM\Controllers;
use App\Core\BaseController;
use Modules\CRM\Services\LeadService;

class LeadController extends BaseController {
    private LeadService $service;
    public function __construct(LeadService $service) { $this->service = $service; }

    public function kanban() {
        $pipeline = $this->service->getPipeline();
        return $this->view('leads/kanban', ['pipeline' => $pipeline], 'CRM');
    }
}
'@
Set-Content -Path $leadControllerPath -Value $leadControllerContent -Encoding UTF8

$apiControllerPath = Join-Path $basePath "modules\CRM\Controllers\ApiCrmController.php"
$apiControllerContent = @'
<?php
namespace Modules\CRM\Controllers;
use App\Core\BaseController;
use Modules\CRM\Services\LeadService;

class ApiCrmController extends BaseController {
    private LeadService $service;
    public function __construct(LeadService $service) { $this->service = $service; }

    public function updateLeadStage() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $data = json_decode(file_get_contents('php://input'), true);
            $success = $this->service->updateLeadStage((int)$data['id'], $data['status']);
            return $this->jsonResponse(['success' => $success]);
        }
        return $this->jsonResponse(['error' => 'Invalid method'], 405);
    }
}
'@
Set-Content -Path $apiControllerPath -Value $apiControllerContent -Encoding UTF8

# 6. Routes
$webRoutesPath = Join-Path $basePath "modules\CRM\Routes\web.php"
Set-Content -Path $webRoutesPath -Value "<?php return [ 'GET /crm/leads' => [Modules\CRM\Controllers\LeadController::class, 'kanban'] ];" -Encoding UTF8

$apiRoutesPath = Join-Path $basePath "modules\CRM\Routes\api.php"
Set-Content -Path $apiRoutesPath -Value "<?php return [ 'POST /api/crm/leads/stage' => [Modules\CRM\Controllers\ApiCrmController::class, 'updateLeadStage'] ];" -Encoding UTF8

# 7. Views
$kanbanViewPath = Join-Path $basePath "modules\CRM\Views\leads\kanban.php"
$kanbanViewContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sales Pipeline - CRM</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .kanban-board { display: flex; gap: 1rem; overflow-x: auto; padding-bottom: 1rem; }
        .kanban-col { background: #f8f9fa; min-width: 300px; border-radius: 5px; padding: 10px; }
        .lead-card { background: white; padding: 15px; margin-bottom: 10px; border-radius: 5px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); cursor: grab; }
    </style>
</head>
<body class="bg-light">
    <div class="container-fluid p-4">
        <h2>Sales Pipeline (Kanban)</h2>
        <div class="kanban-board mt-4">
            <?php foreach($pipeline as $stage => $leads): ?>
            <div class="kanban-col" data-stage="<?= htmlspecialchars($stage) ?>">
                <h5><?= ucfirst($stage) ?> (<?= count($leads) ?>)</h5>
                <div class="lead-list" style="min-height: 200px;">
                    <?php foreach($leads as $lead): ?>
                    <div class="lead-card" data-id="<?= $lead['id'] ?>">
                        <strong><?= htmlspecialchars($lead['title']) ?></strong><br>
                        <small>$<?= number_format($lead['value'], 2) ?></small>
                    </div>
                    <?php endforeach; ?>
                </div>
            </div>
            <?php endforeach; ?>
        </div>
    </div>
    <!-- Add drag & drop JS logic here -->
</body>
</html>
'@
Set-Content -Path $kanbanViewPath -Value $kanbanViewContent -Encoding UTF8

Write-Host "CRM module Phase 1 & 2 built successfully."
