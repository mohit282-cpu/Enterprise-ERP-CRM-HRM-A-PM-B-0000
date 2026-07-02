$basePath = "z:\xampp\htdocs\Enterprise-ERP-CRM-HRM-A-PM-B-0000"

# Directories
$dirs = @(
    "database\migrations",
    "modules\Hosting\Models",
    "modules\Hosting\Repositories",
    "modules\Hosting\Services",
    "modules\Hosting\Controllers",
    "modules\Hosting\Routes",
    "modules\Hosting\Views\accounts",
    "modules\Hosting\Views\renewals"
)

foreach ($dir in $dirs) {
    $fullPath = Join-Path $basePath $dir
    if (-not (Test-Path $fullPath)) { New-Item -ItemType Directory -Force -Path $fullPath | Out-Null }
}

# 1. Database Migration
$migrationPath = Join-Path $basePath "database\migrations\2026_01_12_000000_create_hosting_tables.php"
$migrationContent = @'
<?php
class CreateHostingTables {
    public function up($db) {
        $sql = "
        CREATE TABLE servers (
            id INT AUTO_INCREMENT PRIMARY KEY,
            hostname VARCHAR(255) NOT NULL UNIQUE,
            ip_address VARCHAR(45) NOT NULL,
            datacenter VARCHAR(100),
            control_panel ENUM('cpanel', 'plesk', 'directadmin', 'custom') DEFAULT 'cpanel',
            api_token VARCHAR(255),
            status ENUM('active', 'maintenance', 'offline') DEFAULT 'active',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE hosting_plans (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(150) NOT NULL,
            disk_space_mb INT NOT NULL,
            bandwidth_mb INT NOT NULL,
            annual_price DECIMAL(15,4) NOT NULL,
            is_active BOOLEAN DEFAULT TRUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE hosting_accounts (
            id INT AUTO_INCREMENT PRIMARY KEY,
            contact_id INT NOT NULL,
            server_id INT NOT NULL,
            hosting_plan_id INT NOT NULL,
            domain_name VARCHAR(255) NOT NULL UNIQUE,
            username VARCHAR(50) NOT NULL,
            password_hash VARCHAR(255),
            next_renewal_date DATE NOT NULL,
            status ENUM('active', 'suspended', 'terminated', 'pending_setup') DEFAULT 'pending_setup',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE RESTRICT,
            FOREIGN KEY (server_id) REFERENCES servers(id) ON DELETE RESTRICT,
            FOREIGN KEY (hosting_plan_id) REFERENCES hosting_plans(id) ON DELETE RESTRICT
        );

        CREATE TABLE hosting_usage (
            id INT AUTO_INCREMENT PRIMARY KEY,
            hosting_account_id INT NOT NULL,
            month_year VARCHAR(7) NOT NULL, -- Format YYYY-MM
            disk_used_mb INT DEFAULT 0,
            bandwidth_used_mb INT DEFAULT 0,
            recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (hosting_account_id) REFERENCES hosting_accounts(id) ON DELETE CASCADE,
            UNIQUE KEY account_month (hosting_account_id, month_year)
        );

        CREATE TABLE hosting_backups (
            id INT AUTO_INCREMENT PRIMARY KEY,
            hosting_account_id INT NOT NULL,
            status ENUM('success', 'failed', 'in_progress') NOT NULL,
            file_size_mb INT,
            completed_at TIMESTAMP,
            FOREIGN KEY (hosting_account_id) REFERENCES hosting_accounts(id) ON DELETE CASCADE
        );
        ";
        $db->exec($sql);
    }
    public function down($db) {
        $db->exec("DROP TABLE IF EXISTS hosting_backups, hosting_usage, hosting_accounts, hosting_plans, servers;");
    }
}
'@
Set-Content -Path $migrationPath -Value $migrationContent -Encoding UTF8

# 2. Models
$serverModelPath = Join-Path $basePath "modules\Hosting\Models\Server.php"
Set-Content -Path $serverModelPath -Value "<?php namespace Modules\Hosting\Models; use App\Core\BaseModel; class Server extends BaseModel { protected string `$table = 'servers'; }" -Encoding UTF8

$planModelPath = Join-Path $basePath "modules\Hosting\Models\HostingPlan.php"
Set-Content -Path $planModelPath -Value "<?php namespace Modules\Hosting\Models; use App\Core\BaseModel; class HostingPlan extends BaseModel { protected string `$table = 'hosting_plans'; }" -Encoding UTF8

$accountModelPath = Join-Path $basePath "modules\Hosting\Models\HostingAccount.php"
Set-Content -Path $accountModelPath -Value "<?php namespace Modules\Hosting\Models; use App\Core\BaseModel; class HostingAccount extends BaseModel { protected string `$table = 'hosting_accounts'; }" -Encoding UTF8

# 3. Repositories
$accountRepoPath = Join-Path $basePath "modules\Hosting\Repositories\HostingAccountRepository.php"
$accountRepoContent = @'
<?php
namespace Modules\Hosting\Repositories;
use Modules\Hosting\Models\HostingAccount;
use PDO;

class HostingAccountRepository {
    private HostingAccount $model;
    public function __construct(HostingAccount $model) { $this->model = $model; }

    public function getAccountsPendingRenewal(): array {
        // Fetch accounts where renewal is within the next 30 days or overdue
        $sql = "
            SELECT a.*, c.first_name, c.last_name, c.email, p.name as plan_name, p.annual_price 
            FROM hosting_accounts a
            JOIN contacts c ON a.contact_id = c.id
            JOIN hosting_plans p ON a.hosting_plan_id = p.id
            WHERE a.next_renewal_date <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)
            AND a.status = 'active'
            ORDER BY a.next_renewal_date ASC
        ";
        $stmt = $this->model->getDb()->query($sql);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function createAccount(array $data): int {
        $stmt = $this->model->getDb()->prepare("
            INSERT INTO hosting_accounts (contact_id, server_id, hosting_plan_id, domain_name, username, next_renewal_date, status)
            VALUES (?, ?, ?, ?, ?, ?, 'active')
        ");
        $stmt->execute([
            $data['contact_id'], $data['server_id'], $data['hosting_plan_id'],
            $data['domain_name'], $data['username'], $data['next_renewal_date']
        ]);
        return (int)$this->model->getDb()->lastInsertId();
    }
}
'@
Set-Content -Path $accountRepoPath -Value $accountRepoContent -Encoding UTF8

# 4. Services
$provisioningServicePath = Join-Path $basePath "modules\Hosting\Services\ProvisioningService.php"
$provisioningServiceContent = @'
<?php
namespace Modules\Hosting\Services;
use Modules\Hosting\Repositories\HostingAccountRepository;
use Exception;

class ProvisioningService {
    private HostingAccountRepository $repo;
    public function __construct(HostingAccountRepository $repo) { $this->repo = $repo; }

    public function provisionAccount(array $data): int {
        // 1. Calculate exactly 1 year from today for renewal
        $data['next_renewal_date'] = date('Y-m-d', strtotime('+1 year'));
        
        // 2. Format username if not provided
        if (empty($data['username'])) {
            $data['username'] = substr(preg_replace('/[^a-zA-Z0-9]/', '', $data['domain_name']), 0, 8);
        }

        // 3. Stub for Phase 2: Call WHM/cPanel API to actually create the physical account on the server here

        // 4. Save to database
        return $this->repo->createAccount($data);
    }
}
'@
Set-Content -Path $provisioningServicePath -Value $provisioningServiceContent -Encoding UTF8

# 5. Controllers
$accountControllerPath = Join-Path $basePath "modules\Hosting\Controllers\AccountController.php"
$accountControllerContent = @'
<?php
namespace Modules\Hosting\Controllers;
use App\Core\BaseController;
use Modules\Hosting\Services\ProvisioningService;
use Exception;

class AccountController extends BaseController {
    private ProvisioningService $service;
    public function __construct(ProvisioningService $service) { $this->service = $service; }

    public function create() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            try {
                // Dummy logic for testing routing
                $id = $this->service->provisionAccount($_POST);
                return $this->redirect("/hosting/accounts/$id");
            } catch (Exception $e) {
                return $this->view('accounts/create', ['error' => $e->getMessage()], 'Hosting');
            }
        }
        return $this->view('accounts/create', [], 'Hosting');
    }
}
'@
Set-Content -Path $accountControllerPath -Value $accountControllerContent -Encoding UTF8

$renewalControllerPath = Join-Path $basePath "modules\Hosting\Controllers\RenewalController.php"
$renewalControllerContent = @'
<?php
namespace Modules\Hosting\Controllers;
use App\Core\BaseController;
use Modules\Hosting\Repositories\HostingAccountRepository;

class RenewalController extends BaseController {
    private HostingAccountRepository $repo;
    public function __construct(HostingAccountRepository $repo) { $this->repo = $repo; }

    public function index() {
        $renewals = $this->repo->getAccountsPendingRenewal();
        return $this->view('renewals/index', ['renewals' => $renewals], 'Hosting');
    }
}
'@
Set-Content -Path $renewalControllerPath -Value $renewalControllerContent -Encoding UTF8

# 6. Routes
$webRoutesPath = Join-Path $basePath "modules\Hosting\Routes\web.php"
Set-Content -Path $webRoutesPath -Value "<?php return [ 'GET /hosting/accounts/create' => [Modules\Hosting\Controllers\AccountController::class, 'create'], 'POST /hosting/accounts/create' => [Modules\Hosting\Controllers\AccountController::class, 'create'], 'GET /hosting/renewals' => [Modules\Hosting\Controllers\RenewalController::class, 'index'] ];" -Encoding UTF8


# 7. Views
$renewalsViewPath = Join-Path $basePath "modules\Hosting\Views\renewals\index.php"
$renewalsViewContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Hosting Renewals</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container mt-4">
        <h2>Upcoming Hosting Renewals (30 Days)</h2>
        <div class="card shadow-sm mt-4 p-4">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Client</th>
                        <th>Domain</th>
                        <th>Plan</th>
                        <th>Renewal Date</th>
                        <th>Annual Price</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if(empty($renewals)): ?>
                        <tr><td colspan="6" class="text-center">No upcoming renewals found.</td></tr>
                    <?php else: ?>
                        <?php foreach($renewals as $r): ?>
                        <tr class="<?= (strtotime($r['next_renewal_date']) < time()) ? 'table-danger' : '' ?>">
                            <td><?= htmlspecialchars($r['first_name'] . ' ' . $r['last_name']) ?></td>
                            <td><strong><?= htmlspecialchars($r['domain_name']) ?></strong></td>
                            <td><?= htmlspecialchars($r['plan_name']) ?></td>
                            <td><?= htmlspecialchars($r['next_renewal_date']) ?></td>
                            <td>$<?= htmlspecialchars($r['annual_price']) ?></td>
                            <td><button class="btn btn-sm btn-primary">Generate Invoice</button></td>
                        </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
'@
Set-Content -Path $renewalsViewPath -Value $renewalsViewContent -Encoding UTF8

$createAccountViewPath = Join-Path $basePath "modules\Hosting\Views\accounts\create.php"
$createAccountViewContent = @'
<!-- Basic scaffolding view for creating an account -->
<h2>Provision New Hosting Account</h2>
<form method="POST">
    <!-- Fields will go here -->
    <button type="submit">Provision</button>
</form>
'@
Set-Content -Path $createAccountViewPath -Value $createAccountViewContent -Encoding UTF8

Write-Host "Hosting Management module Phase 1 built successfully."
