$basePath = "z:\xampp\htdocs\Enterprise-ERP-CRM-HRM-A-PM-B-0000"

# Directories
$dirs = @(
    "database\migrations",
    "modules\Domains\Models",
    "modules\Domains\Repositories",
    "modules\Domains\Services",
    "modules\Domains\Controllers",
    "modules\Domains\Routes",
    "modules\Domains\Views\domains",
    "modules\Domains\Views\expiry"
)

foreach ($dir in $dirs) {
    $fullPath = Join-Path $basePath $dir
    if (-not (Test-Path $fullPath)) { New-Item -ItemType Directory -Force -Path $fullPath | Out-Null }
}

# 1. Database Migration
$migrationPath = Join-Path $basePath "database\migrations\2026_01_13_000000_create_domains_tables.php"
$migrationContent = @'
<?php
class CreateDomainsTables {
    public function up($db) {
        $sql = "
        CREATE TABLE registrars (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(150) NOT NULL,
            api_key VARCHAR(255),
            api_secret VARCHAR(255),
            support_url VARCHAR(255),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE domains (
            id INT AUTO_INCREMENT PRIMARY KEY,
            contact_id INT NOT NULL,
            registrar_id INT,
            domain_name VARCHAR(255) NOT NULL UNIQUE,
            registration_date DATE,
            expiry_date DATE NOT NULL,
            auto_renew BOOLEAN DEFAULT FALSE,
            status ENUM('active', 'expired', 'pending_transfer', 'client_hold') DEFAULT 'active',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE RESTRICT,
            FOREIGN KEY (registrar_id) REFERENCES registrars(id) ON DELETE SET NULL
        );

        CREATE TABLE dns_records (
            id INT AUTO_INCREMENT PRIMARY KEY,
            domain_id INT NOT NULL,
            type ENUM('A', 'AAAA', 'CNAME', 'MX', 'TXT', 'NS', 'SRV') NOT NULL,
            name VARCHAR(255) NOT NULL,
            content TEXT NOT NULL,
            ttl INT DEFAULT 3600,
            priority INT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (domain_id) REFERENCES domains(id) ON DELETE CASCADE
        );

        CREATE TABLE ssl_certificates (
            id INT AUTO_INCREMENT PRIMARY KEY,
            domain_id INT NOT NULL,
            provider VARCHAR(100),
            issue_date DATE,
            expiry_date DATE NOT NULL,
            is_wildcard BOOLEAN DEFAULT FALSE,
            status ENUM('active', 'expired', 'revoked') DEFAULT 'active',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (domain_id) REFERENCES domains(id) ON DELETE CASCADE
        );
        ";
        $db->exec($sql);
    }
    public function down($db) {
        $db->exec("DROP TABLE IF EXISTS ssl_certificates, dns_records, domains, registrars;");
    }
}
'@
Set-Content -Path $migrationPath -Value $migrationContent -Encoding UTF8

# 2. Models
$registrarModelPath = Join-Path $basePath "modules\Domains\Models\Registrar.php"
Set-Content -Path $registrarModelPath -Value "<?php namespace Modules\Domains\Models; use App\Core\BaseModel; class Registrar extends BaseModel { protected string `$table = 'registrars'; }" -Encoding UTF8

$domainModelPath = Join-Path $basePath "modules\Domains\Models\Domain.php"
Set-Content -Path $domainModelPath -Value "<?php namespace Modules\Domains\Models; use App\Core\BaseModel; class Domain extends BaseModel { protected string `$table = 'domains'; }" -Encoding UTF8

$dnsModelPath = Join-Path $basePath "modules\Domains\Models\DnsRecord.php"
Set-Content -Path $dnsModelPath -Value "<?php namespace Modules\Domains\Models; use App\Core\BaseModel; class DnsRecord extends BaseModel { protected string `$table = 'dns_records'; }" -Encoding UTF8

$sslModelPath = Join-Path $basePath "modules\Domains\Models\SslCertificate.php"
Set-Content -Path $sslModelPath -Value "<?php namespace Modules\Domains\Models; use App\Core\BaseModel; class SslCertificate extends BaseModel { protected string `$table = 'ssl_certificates'; }" -Encoding UTF8


# 3. Repositories
$domainRepoPath = Join-Path $basePath "modules\Domains\Repositories\DomainRepository.php"
$domainRepoContent = @'
<?php
namespace Modules\Domains\Repositories;
use Modules\Domains\Models\Domain;
use PDO;

class DomainRepository {
    private Domain $model;
    public function __construct(Domain $model) { $this->model = $model; }

    public function getExpiringAssets(int $days = 30): array {
        $sql = "
            SELECT 'Domain' as type, d.domain_name as name, d.expiry_date, c.first_name, c.last_name
            FROM domains d
            JOIN contacts c ON d.contact_id = c.id
            WHERE d.expiry_date <= DATE_ADD(CURDATE(), INTERVAL ? DAY) AND d.status = 'active'
            
            UNION ALL
            
            SELECT 'SSL' as type, CONCAT(d.domain_name, ' (', s.provider, ')') as name, s.expiry_date, c.first_name, c.last_name
            FROM ssl_certificates s
            JOIN domains d ON s.domain_id = d.id
            JOIN contacts c ON d.contact_id = c.id
            WHERE s.expiry_date <= DATE_ADD(CURDATE(), INTERVAL ? DAY) AND s.status = 'active'
            
            ORDER BY expiry_date ASC
        ";
        $stmt = $this->model->getDb()->prepare($sql);
        $stmt->execute([$days, $days]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
'@
Set-Content -Path $domainRepoPath -Value $domainRepoContent -Encoding UTF8

# 4. Services
$domainServicePath = Join-Path $basePath "modules\Domains\Services\DomainService.php"
$domainServiceContent = @'
<?php
namespace Modules\Domains\Services;

class DomainService {
    
    /**
     * Aggressively strip protocols, paths, and www to get the bare domain.
     */
    public function sanitizeDomainName(string $input): string {
        $input = trim($input);
        // Remove http/https
        $input = preg_replace('#^https?://#', '', $input);
        // Remove www
        $input = preg_replace('#^www\.#', '', $input);
        // Remove paths
        $parts = explode('/', $input);
        $input = $parts[0];
        return strtolower($input);
    }
}
'@
Set-Content -Path $domainServicePath -Value $domainServiceContent -Encoding UTF8

# 5. Controllers
$domainControllerPath = Join-Path $basePath "modules\Domains\Controllers\DomainController.php"
$domainControllerContent = @'
<?php
namespace Modules\Domains\Controllers;
use App\Core\BaseController;
use Modules\Domains\Services\DomainService;

class DomainController extends BaseController {
    private DomainService $service;
    public function __construct(DomainService $service) { $this->service = $service; }

    public function index() {
        return $this->view('domains/index', [], 'Domains');
    }
}
'@
Set-Content -Path $domainControllerPath -Value $domainControllerContent -Encoding UTF8

$expiryControllerPath = Join-Path $basePath "modules\Domains\Controllers\ExpiryController.php"
$expiryControllerContent = @'
<?php
namespace Modules\Domains\Controllers;
use App\Core\BaseController;
use Modules\Domains\Repositories\DomainRepository;

class ExpiryController extends BaseController {
    private DomainRepository $repo;
    public function __construct(DomainRepository $repo) { $this->repo = $repo; }

    public function index() {
        $expiring = $this->repo->getExpiringAssets(45); // Check 45 days out
        return $this->view('expiry/index', ['expiring' => $expiring], 'Domains');
    }
}
'@
Set-Content -Path $expiryControllerPath -Value $expiryControllerContent -Encoding UTF8

$apiDomainControllerPath = Join-Path $basePath "modules\Domains\Controllers\ApiDomainController.php"
$apiDomainControllerContent = @'
<?php
namespace Modules\Domains\Controllers;
use App\Core\BaseController;
use Modules\Domains\Services\DomainService;

class ApiDomainController extends BaseController {
    private DomainService $service;
    public function __construct(DomainService $service) { $this->service = $service; }

    public function sanitize() {
        $data = json_decode(file_get_contents('php://input'), true);
        if(isset($data['domain'])) {
            $clean = $this->service->sanitizeDomainName($data['domain']);
            return $this->jsonResponse(['clean_domain' => $clean]);
        }
        return $this->jsonResponse(['error' => 'Missing domain parameter'], 400);
    }
}
'@
Set-Content -Path $apiDomainControllerPath -Value $apiDomainControllerContent -Encoding UTF8


# 6. Routes
$webRoutesPath = Join-Path $basePath "modules\Domains\Routes\web.php"
Set-Content -Path $webRoutesPath -Value "<?php return [ 'GET /domains' => [Modules\Domains\Controllers\DomainController::class, 'index'], 'GET /domains/expiry' => [Modules\Domains\Controllers\ExpiryController::class, 'index'] ];" -Encoding UTF8

$apiRoutesPath = Join-Path $basePath "modules\Domains\Routes\api.php"
Set-Content -Path $apiRoutesPath -Value "<?php return [ 'POST /api/domains/sanitize' => [Modules\Domains\Controllers\ApiDomainController::class, 'sanitize'] ];" -Encoding UTF8


# 7. Views
$expiryViewPath = Join-Path $basePath "modules\Domains\Views\expiry\index.php"
$expiryViewContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Domain & SSL Expiry</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container mt-4">
        <h2>Expiring Assets (45 Days)</h2>
        <div class="card shadow-sm mt-4 p-4">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Type</th>
                        <th>Name</th>
                        <th>Client</th>
                        <th>Expiry Date</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if(empty($expiring)): ?>
                        <tr><td colspan="5" class="text-center">No upcoming expirations found.</td></tr>
                    <?php else: ?>
                        <?php foreach($expiring as $e): ?>
                        <tr class="<?= (strtotime($e['expiry_date']) < time()) ? 'table-danger' : 'table-warning' ?>">
                            <td><span class="badge bg-secondary"><?= htmlspecialchars($e['type']) ?></span></td>
                            <td><strong><?= htmlspecialchars($e['name']) ?></strong></td>
                            <td><?= htmlspecialchars($e['first_name'] . ' ' . $e['last_name']) ?></td>
                            <td><?= htmlspecialchars($e['expiry_date']) ?></td>
                            <td>
                                <?= (strtotime($e['expiry_date']) < time()) ? 'OVERDUE' : 'Expiring Soon' ?>
                            </td>
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
Set-Content -Path $expiryViewPath -Value $expiryViewContent -Encoding UTF8

Write-Host "Domain Management module Phase 1 built successfully."
