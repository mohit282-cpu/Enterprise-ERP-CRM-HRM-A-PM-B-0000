$basePath = "z:\xampp\htdocs\Enterprise-ERP-CRM-HRM-A-PM-B-0000"

# Create Directories
$dirs = @(
    "database\migrations",
    "modules\Dashboard\Models",
    "modules\Dashboard\Repositories",
    "modules\Dashboard\Services",
    "modules\Dashboard\Controllers",
    "modules\Dashboard\Routes",
    "modules\Dashboard\Views\widgets",
    "modules\Dashboard\Assets\js",
    "modules\Dashboard\Assets\css"
)

foreach ($dir in $dirs) {
    $fullPath = Join-Path $basePath $dir
    if (-not (Test-Path $fullPath)) { New-Item -ItemType Directory -Force -Path $fullPath | Out-Null }
}

# 1. Database Migration
$migrationPath = Join-Path $basePath "database\migrations\2026_01_05_000000_create_dashboard_tables.php"
$migrationContent = @'
<?php
class CreateDashboardTables {
    public function up($db) {
        $sql = "
        CREATE TABLE user_dashboard_preferences (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            widget_config JSON NOT NULL,
            theme VARCHAR(50) DEFAULT 'light',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
        ";
        $db->exec($sql);
    }
    public function down($db) {
        $db->exec("DROP TABLE IF EXISTS user_dashboard_preferences;");
    }
}
'@
Set-Content -Path $migrationPath -Value $migrationContent -Encoding UTF8

# 2. Model
$modelPath = Join-Path $basePath "modules\Dashboard\Models\DashboardPreference.php"
$modelContent = @'
<?php
namespace Modules\Dashboard\Models;
use App\Core\BaseModel;

class DashboardPreference extends BaseModel {
    protected string $table = 'user_dashboard_preferences';
}
'@
Set-Content -Path $modelPath -Value $modelContent -Encoding UTF8

# 3. Repository
$repoPath = Join-Path $basePath "modules\Dashboard\Repositories\DashboardPreferenceRepository.php"
$repoContent = @'
<?php
namespace Modules\Dashboard\Repositories;

use Modules\Dashboard\Models\DashboardPreference;
use PDO;

class DashboardPreferenceRepository {
    private DashboardPreference $model;
    public function __construct(DashboardPreference $model) {
        $this->model = $model;
    }
    
    public function getUserPreferences(int $userId): ?array {
        $stmt = $this->model->getDb()->prepare("SELECT * FROM {$this->model->getTable()} WHERE user_id = ? LIMIT 1");
        $stmt->execute([$userId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }
    
    public function savePreferences(int $userId, string $configJson, string $theme = 'light'): void {
        $stmt = $this->model->getDb()->prepare("
            INSERT INTO {$this->model->getTable()} (user_id, widget_config, theme) 
            VALUES (?, ?, ?) 
            ON DUPLICATE KEY UPDATE widget_config = VALUES(widget_config), theme = VALUES(theme)
        ");
        $stmt->execute([$userId, $configJson, $theme]);
    }
}
'@
Set-Content -Path $repoPath -Value $repoContent -Encoding UTF8

# 4. Service
$servicePath = Join-Path $basePath "modules\Dashboard\Services\DashboardService.php"
$serviceContent = @'
<?php
namespace Modules\Dashboard\Services;

class DashboardService {
    
    public function getKpiStats(): array {
        // Mock data until CRM & Accounting are built
        return [
            'total_revenue' => 145000.50,
            'active_users' => 42,
            'open_leads' => 18,
            'pending_tasks' => 7
        ];
    }
    
    public function getRevenueChartData(): array {
        // Mock series data for ApexCharts
        return [
            'categories' => ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
            'series' => [
                ['name' => 'Revenue', 'data' => [30000, 40000, 35000, 50000, 49000, 60000]],
                ['name' => 'Expenses', 'data' => [23000, 26000, 21000, 30000, 25000, 31000]]
            ]
        ];
    }
    
    public function getRecentActivity(): array {
        // Mock data until activity logs are fully wired
        return [
            ['action' => 'Invoice #INV-0012 Paid', 'time' => '10 mins ago'],
            ['action' => 'New Lead: John Doe', 'time' => '1 hour ago'],
            ['action' => 'Project Alpha Completed', 'time' => '3 hours ago']
        ];
    }
}
'@
Set-Content -Path $servicePath -Value $serviceContent -Encoding UTF8

# 5. Controllers
$webControllerPath = Join-Path $basePath "modules\Dashboard\Controllers\DashboardController.php"
$webControllerContent = @'
<?php
namespace Modules\Dashboard\Controllers;

use App\Core\BaseController;
use Modules\Dashboard\Services\DashboardService;
use Modules\Dashboard\Repositories\DashboardPreferenceRepository;

class DashboardController extends BaseController {
    private DashboardService $dashboardService;
    private DashboardPreferenceRepository $prefRepo;

    public function __construct(DashboardService $dashboardService, DashboardPreferenceRepository $prefRepo) {
        $this->dashboardService = $dashboardService;
        $this->prefRepo = $prefRepo;
    }

    public function index() {
        $kpiStats = $this->dashboardService->getKpiStats();
        $recentActivity = $this->dashboardService->getRecentActivity();
        
        return $this->view('index', [
            'kpi' => $kpiStats,
            'activity' => $recentActivity
        ], 'Dashboard'); // Assumes view loader handles pathing within the module
    }
}
'@
Set-Content -Path $webControllerPath -Value $webControllerContent -Encoding UTF8

$apiControllerPath = Join-Path $basePath "modules\Dashboard\Controllers\ApiDashboardController.php"
$apiControllerContent = @'
<?php
namespace Modules\Dashboard\Controllers;

use App\Core\BaseController;
use Modules\Dashboard\Services\DashboardService;

class ApiDashboardController extends BaseController {
    private DashboardService $dashboardService;

    public function __construct(DashboardService $dashboardService) {
        $this->dashboardService = $dashboardService;
    }

    public function getChartData() {
        $data = $this->dashboardService->getRevenueChartData();
        return $this->jsonResponse($data);
    }
}
'@
Set-Content -Path $apiControllerPath -Value $apiControllerContent -Encoding UTF8

# 6. Routes
$webRoutesPath = Join-Path $basePath "modules\Dashboard\Routes\web.php"
$webRoutesContent = @'
<?php
use Modules\Dashboard\Controllers\DashboardController;

return [
    'GET /dashboard' => [DashboardController::class, 'index']
];
'@
Set-Content -Path $webRoutesPath -Value $webRoutesContent -Encoding UTF8

$apiRoutesPath = Join-Path $basePath "modules\Dashboard\Routes\api.php"
$apiRoutesContent = @'
<?php
use Modules\Dashboard\Controllers\ApiDashboardController;

return [
    'GET /api/dashboard/charts/revenue' => [ApiDashboardController::class, 'getChartData']
];
'@
Set-Content -Path $apiRoutesPath -Value $apiRoutesContent -Encoding UTF8

# 7. Views
$mainViewPath = Join-Path $basePath "modules\Dashboard\Views\index.php"
$mainViewContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Dashboard - Sovryx OS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/assets/css/dashboard.css">
</head>
<body class="bg-light">
    
    <!-- Top Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4">
        <div class="container-fluid">
            <a class="navbar-brand" href="/dashboard">Sovryx OS</a>
            <div class="d-flex">
                <a href="/logout" class="btn btn-outline-light btn-sm">Logout</a>
            </div>
        </div>
    </nav>

    <div class="container-fluid px-4">
        <h2 class="mb-4">Overview Dashboard</h2>
        
        <!-- KPI Cards Widget -->
        <?php include 'widgets/kpi-cards.php'; ?>

        <div class="row mt-4">
            <!-- Main Chart Widget -->
            <div class="col-lg-8">
                <div class="card shadow-sm">
                    <div class="card-header bg-white">
                        <h5 class="mb-0">Revenue vs Expenses</h5>
                    </div>
                    <div class="card-body">
                        <div id="revenueChart"></div>
                    </div>
                </div>
            </div>
            
            <!-- Recent Activity Widget -->
            <div class="col-lg-4">
                <?php include 'widgets/recent-activity.php'; ?>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>
    <script src="/assets/js/dashboard.js"></script>
</body>
</html>
'@
Set-Content -Path $mainViewPath -Value $mainViewContent -Encoding UTF8

$kpiViewPath = Join-Path $basePath "modules\Dashboard\Views\widgets\kpi-cards.php"
$kpiViewContent = @'
<div class="row">
    <div class="col-xl-3 col-md-6 mb-4">
        <div class="card border-left-primary shadow-sm h-100 py-2">
            <div class="card-body">
                <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">Total Revenue</div>
                <div class="h5 mb-0 font-weight-bold text-gray-800">$<?= number_format($kpi['total_revenue'], 2) ?></div>
            </div>
        </div>
    </div>
    <div class="col-xl-3 col-md-6 mb-4">
        <div class="card border-left-success shadow-sm h-100 py-2">
            <div class="card-body">
                <div class="text-xs font-weight-bold text-success text-uppercase mb-1">Active Users</div>
                <div class="h5 mb-0 font-weight-bold text-gray-800"><?= $kpi['active_users'] ?></div>
            </div>
        </div>
    </div>
    <div class="col-xl-3 col-md-6 mb-4">
        <div class="card border-left-warning shadow-sm h-100 py-2">
            <div class="card-body">
                <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">Open Leads</div>
                <div class="h5 mb-0 font-weight-bold text-gray-800"><?= $kpi['open_leads'] ?></div>
            </div>
        </div>
    </div>
    <div class="col-xl-3 col-md-6 mb-4">
        <div class="card border-left-danger shadow-sm h-100 py-2">
            <div class="card-body">
                <div class="text-xs font-weight-bold text-danger text-uppercase mb-1">Pending Tasks</div>
                <div class="h5 mb-0 font-weight-bold text-gray-800"><?= $kpi['pending_tasks'] ?></div>
            </div>
        </div>
    </div>
</div>
'@
Set-Content -Path $kpiViewPath -Value $kpiViewContent -Encoding UTF8

$activityViewPath = Join-Path $basePath "modules\Dashboard\Views\widgets\recent-activity.php"
$activityViewContent = @'
<div class="card shadow-sm h-100">
    <div class="card-header bg-white">
        <h5 class="mb-0">Recent Activity</h5>
    </div>
    <div class="card-body">
        <ul class="list-group list-group-flush">
            <?php foreach($activity as $log): ?>
                <li class="list-group-item d-flex justify-content-between align-items-center">
                    <?= htmlspecialchars($log['action']) ?>
                    <span class="badge bg-secondary rounded-pill"><?= htmlspecialchars($log['time']) ?></span>
                </li>
            <?php endforeach; ?>
        </ul>
    </div>
</div>
'@
Set-Content -Path $activityViewPath -Value $activityViewContent -Encoding UTF8

# 8. Assets (JS)
$jsPath = Join-Path $basePath "modules\Dashboard\Assets\js\dashboard.js"
$jsContent = @'
document.addEventListener('DOMContentLoaded', function() {
    // Fetch chart data via API
    fetch('/api/dashboard/charts/revenue')
        .then(response => response.json())
        .then(data => {
            var options = {
                series: data.series,
                chart: {
                    type: 'area',
                    height: 350,
                    toolbar: { show: false }
                },
                colors: ['#0d6efd', '#dc3545'],
                dataLabels: { enabled: false },
                stroke: { curve: 'smooth' },
                xaxis: {
                    categories: data.categories
                },
                tooltip: {
                    x: { format: 'dd/MM/yy HH:mm' }
                }
            };

            var chart = new ApexCharts(document.querySelector("#revenueChart"), options);
            chart.render();
        })
        .catch(error => console.error('Error loading chart data:', error));
});
'@
Set-Content -Path $jsPath -Value $jsContent -Encoding UTF8

Write-Host "Dashboard module built successfully."
