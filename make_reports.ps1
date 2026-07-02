$basePath = "z:\xampp\htdocs\Enterprise-ERP-CRM-HRM-A-PM-B-0000"

# Directories
$dirs = @(
    "database\migrations",
    "modules\Reports\Models",
    "modules\Reports\Repositories",
    "modules\Reports\Services",
    "modules\Reports\Controllers",
    "modules\Reports\Routes",
    "modules\Reports\Views\dashboard",
    "modules\Reports\Views\charts"
)

foreach ($dir in $dirs) {
    $fullPath = Join-Path $basePath $dir
    if (-not (Test-Path $fullPath)) { New-Item -ItemType Directory -Force -Path $fullPath | Out-Null }
}

# 1. Database Migration
$migrationPath = Join-Path $basePath "database\migrations\2026_01_14_000000_create_reports_tables.php"
$migrationContent = @'
<?php
class CreateReportsTables {
    public function up($db) {
        $sql = "
        CREATE TABLE saved_reports (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            report_name VARCHAR(150) NOT NULL,
            module VARCHAR(50) NOT NULL,
            filter_json JSON,
            is_public BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
        ";
        $db->exec($sql);
    }
    public function down($db) {
        $db->exec("DROP TABLE IF EXISTS saved_reports;");
    }
}
'@
Set-Content -Path $migrationPath -Value $migrationContent -Encoding UTF8

# 2. Models
$reportModelPath = Join-Path $basePath "modules\Reports\Models\SavedReport.php"
Set-Content -Path $reportModelPath -Value "<?php namespace Modules\Reports\Models; use App\Core\BaseModel; class SavedReport extends BaseModel { protected string `$table = 'saved_reports'; }" -Encoding UTF8

# 3. Repositories
$analyticsRepoPath = Join-Path $basePath "modules\Reports\Repositories\AnalyticsRepository.php"
$analyticsRepoContent = @'
<?php
namespace Modules\Reports\Repositories;
use App\Core\Database;
use PDO;

class AnalyticsRepository {
    private PDO $db;
    public function __construct() { $this->db = Database::getInstance()->getConnection(); }

    public function getMonthlyRevenueVsExpenses(string $year): array {
        $sql = "
            SELECT 
                MONTH(je.entry_date) as month,
                SUM(IF(a.type = 'revenue', jel.credit - jel.debit, 0)) as revenue,
                SUM(IF(a.type = 'expense', jel.debit - jel.credit, 0)) as expense
            FROM journal_entries je
            JOIN journal_entry_lines jel ON je.id = jel.journal_entry_id
            JOIN chart_of_accounts a ON jel.account_id = a.id
            WHERE YEAR(je.entry_date) = ? AND je.status = 'posted'
            GROUP BY MONTH(je.entry_date)
            ORDER BY MONTH(je.entry_date)
        ";
        $stmt = $this->db->prepare($sql);
        $stmt->execute([$year]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getSalesPipelineMetrics(): array {
        $sql = "SELECT status, COUNT(*) as total, SUM(estimated_value) as value FROM leads GROUP BY status";
        $stmt = $this->db->query($sql);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getInventoryValuation(): array {
        $sql = "
            SELECT w.name as warehouse, SUM(s.quantity * p.cost_price) as total_value
            FROM inventory_stock s
            JOIN products p ON s.product_id = p.id
            JOIN warehouses w ON s.warehouse_id = w.id
            GROUP BY w.id
        ";
        $stmt = $this->db->query($sql);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
'@
Set-Content -Path $analyticsRepoPath -Value $analyticsRepoContent -Encoding UTF8

# 4. Services
$analyticsServicePath = Join-Path $basePath "modules\Reports\Services\AnalyticsService.php"
$analyticsServiceContent = @'
<?php
namespace Modules\Reports\Services;
use Modules\Reports\Repositories\AnalyticsRepository;

class AnalyticsService {
    private AnalyticsRepository $repo;
    public function __construct(AnalyticsRepository $repo) { $this->repo = $repo; }

    public function getFinanceChartData(string $year): array {
        $data = $this->repo->getMonthlyRevenueVsExpenses($year);
        $labels = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        $revenue = array_fill(0, 12, 0);
        $expenses = array_fill(0, 12, 0);

        foreach ($data as $row) {
            $index = (int)$row['month'] - 1;
            $revenue[$index] = (float)$row['revenue'];
            $expenses[$index] = (float)$row['expense'];
        }

        return [
            'labels' => $labels,
            'datasets' => [
                ['name' => 'Revenue', 'data' => $revenue],
                ['name' => 'Expenses', 'data' => $expenses]
            ]
        ];
    }
}
'@
Set-Content -Path $analyticsServicePath -Value $analyticsServiceContent -Encoding UTF8

$exportServicePath = Join-Path $basePath "modules\Reports\Services\ExportService.php"
$exportServiceContent = @'
<?php
namespace Modules\Reports\Services;

class ExportService {
    /**
     * Stub for Phase 2: Will integrate DomPDF to convert HTML reports to PDF downloads
     */
    public function generatePdf(string $htmlContent, string $filename): string {
        return "PDF generation coming in Phase 2 for $filename";
    }

    /**
     * Stub for Phase 2: Will integrate PhpSpreadsheet to convert arrays to .xlsx downloads
     */
    public function generateExcel(array $data, string $filename): string {
        return "Excel generation coming in Phase 2 for $filename";
    }
}
'@
Set-Content -Path $exportServicePath -Value $exportServiceContent -Encoding UTF8


# 5. Controllers
$dashboardControllerPath = Join-Path $basePath "modules\Reports\Controllers\ReportDashboardController.php"
$dashboardControllerContent = @'
<?php
namespace Modules\Reports\Controllers;
use App\Core\BaseController;

class ReportDashboardController extends BaseController {
    public function index() {
        return $this->view('dashboard/index', [], 'Reports');
    }
}
'@
Set-Content -Path $dashboardControllerPath -Value $dashboardControllerContent -Encoding UTF8

$apiAnalyticsControllerPath = Join-Path $basePath "modules\Reports\Controllers\ApiAnalyticsController.php"
$apiAnalyticsControllerContent = @'
<?php
namespace Modules\Reports\Controllers;
use App\Core\BaseController;
use Modules\Reports\Services\AnalyticsService;

class ApiAnalyticsController extends BaseController {
    private AnalyticsService $service;
    public function __construct(AnalyticsService $service) { $this->service = $service; }

    public function getFinanceChart() {
        $year = $_GET['year'] ?? date('Y');
        $data = $this->service->getFinanceChartData($year);
        return $this->jsonResponse($data);
    }
}
'@
Set-Content -Path $apiAnalyticsControllerPath -Value $apiAnalyticsControllerContent -Encoding UTF8

# 6. Routes
$webRoutesPath = Join-Path $basePath "modules\Reports\Routes\web.php"
Set-Content -Path $webRoutesPath -Value "<?php return [ 'GET /reports' => [Modules\Reports\Controllers\ReportDashboardController::class, 'index'] ];" -Encoding UTF8

$apiRoutesPath = Join-Path $basePath "modules\Reports\Routes\api.php"
Set-Content -Path $apiRoutesPath -Value "<?php return [ 'GET /api/reports/finance' => [Modules\Reports\Controllers\ApiAnalyticsController::class, 'getFinanceChart'] ];" -Encoding UTF8

# 7. Views
$dashboardViewPath = Join-Path $basePath "modules\Reports\Views\dashboard\index.php"
$dashboardViewContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Master Reports Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>
</head>
<body class="bg-light">
    <div class="container-fluid mt-4 px-4">
        <h2>Enterprise Reports Hub</h2>
        
        <div class="row mt-4">
            <div class="col-md-8">
                <div class="card shadow-sm p-4">
                    <h5>Revenue vs Expenses (Live Ledger Sync)</h5>
                    <div id="financeChart"></div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card shadow-sm p-4">
                    <h5>Export Options (Phase 2)</h5>
                    <button class="btn btn-outline-danger w-100 mb-2">Export to PDF</button>
                    <button class="btn btn-outline-success w-100">Export to Excel</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener("DOMContentLoaded", function() {
            fetch('/api/reports/finance?year=' + new Date().getFullYear())
                .then(r => r.json())
                .then(data => {
                    var options = {
                        series: data.datasets,
                        chart: { type: 'area', height: 350 },
                        xaxis: { categories: data.labels },
                        colors: ['#28a745', '#dc3545']
                    };
                    var chart = new ApexCharts(document.querySelector("#financeChart"), options);
                    chart.render();
                });
        });
    </script>
</body>
</html>
'@
Set-Content -Path $dashboardViewPath -Value $dashboardViewContent -Encoding UTF8

Write-Host "Reports module Phase 1 built successfully."
