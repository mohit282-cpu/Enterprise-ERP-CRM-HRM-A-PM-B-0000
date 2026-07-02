$basePath = "z:\xampp\htdocs\Enterprise-ERP-CRM-HRM-A-PM-B-0000"

# Directories
$dirs = @(
    "database\migrations",
    "modules\HRM\Models",
    "modules\HRM\Repositories",
    "modules\HRM\Services",
    "modules\HRM\Controllers",
    "modules\HRM\Routes",
    "modules\HRM\Views\employees",
    "modules\HRM\Views\attendance"
)

foreach ($dir in $dirs) {
    $fullPath = Join-Path $basePath $dir
    if (-not (Test-Path $fullPath)) { New-Item -ItemType Directory -Force -Path $fullPath | Out-Null }
}

# 1. Database Migration
$migrationPath = Join-Path $basePath "database\migrations\2026_01_09_000000_create_hrm_tables.php"
$migrationContent = @'
<?php
class CreateHrmTables {
    public function up($db) {
        $sql = "
        CREATE TABLE IF NOT EXISTS branches (
            id INT AUTO_INCREMENT PRIMARY KEY,
            company_id INT NOT NULL,
            name VARCHAR(255) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
        );

        CREATE TABLE IF NOT EXISTS departments (
            id INT AUTO_INCREMENT PRIMARY KEY,
            branch_id INT,
            name VARCHAR(255) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE
        );

        CREATE TABLE IF NOT EXISTS designations (
            id INT AUTO_INCREMENT PRIMARY KEY,
            department_id INT,
            title VARCHAR(255) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE
        );

        CREATE TABLE employees (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL UNIQUE,
            department_id INT,
            designation_id INT,
            employee_code VARCHAR(50) NOT NULL UNIQUE,
            hire_date DATE,
            base_salary DECIMAL(15,4) DEFAULT 0.0000,
            bank_account VARCHAR(255),
            emergency_contact VARCHAR(255),
            status ENUM('active', 'terminated', 'on_leave') DEFAULT 'active',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL,
            FOREIGN KEY (designation_id) REFERENCES designations(id) ON DELETE SET NULL
        );

        CREATE TABLE attendances (
            id INT AUTO_INCREMENT PRIMARY KEY,
            employee_id INT NOT NULL,
            date DATE NOT NULL,
            clock_in DATETIME,
            clock_out DATETIME,
            total_hours DECIMAL(5,2) DEFAULT 0.00,
            location_ip VARCHAR(50),
            status ENUM('present', 'absent', 'half_day') DEFAULT 'present',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
            UNIQUE KEY employee_date (employee_id, date)
        );

        CREATE TABLE leaves (
            id INT AUTO_INCREMENT PRIMARY KEY,
            employee_id INT NOT NULL,
            start_date DATE NOT NULL,
            end_date DATE NOT NULL,
            type ENUM('sick', 'vacation', 'unpaid', 'maternity') NOT NULL,
            status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
            reason TEXT,
            approved_by INT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
            FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL
        );
        ";
        $db->exec($sql);
    }
    public function down($db) {
        $db->exec("DROP TABLE IF EXISTS leaves, attendances, employees, designations, departments, branches;");
    }
}
'@
Set-Content -Path $migrationPath -Value $migrationContent -Encoding UTF8

# 2. Models
$employeeModelPath = Join-Path $basePath "modules\HRM\Models\Employee.php"
Set-Content -Path $employeeModelPath -Value "<?php namespace Modules\HRM\Models; use App\Core\BaseModel; class Employee extends BaseModel { protected string `$table = 'employees'; }" -Encoding UTF8

$attendanceModelPath = Join-Path $basePath "modules\HRM\Models\Attendance.php"
Set-Content -Path $attendanceModelPath -Value "<?php namespace Modules\HRM\Models; use App\Core\BaseModel; class Attendance extends BaseModel { protected string `$table = 'attendances'; }" -Encoding UTF8

$leaveModelPath = Join-Path $basePath "modules\HRM\Models\Leave.php"
Set-Content -Path $leaveModelPath -Value "<?php namespace Modules\HRM\Models; use App\Core\BaseModel; class Leave extends BaseModel { protected string `$table = 'leaves'; }" -Encoding UTF8

# 3. Repositories
$attendanceRepoPath = Join-Path $basePath "modules\HRM\Repositories\AttendanceRepository.php"
$attendanceRepoContent = @'
<?php
namespace Modules\HRM\Repositories;
use Modules\HRM\Models\Attendance;
use PDO;

class AttendanceRepository {
    private Attendance $model;
    public function __construct(Attendance $model) { $this->model = $model; }

    public function recordClockIn(int $employeeId, string $ip): bool {
        $date = date('Y-m-d');
        $time = date('Y-m-d H:i:s');
        
        $stmt = $this->model->getDb()->prepare("
            INSERT INTO attendances (employee_id, date, clock_in, location_ip) 
            VALUES (?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE clock_in = IF(clock_in IS NULL, VALUES(clock_in), clock_in)
        ");
        return $stmt->execute([$employeeId, $date, $time, $ip]);
    }

    public function recordClockOut(int $employeeId): bool {
        $date = date('Y-m-d');
        $time = date('Y-m-d H:i:s');
        
        // Complex update calculating total hours in SQL
        $stmt = $this->model->getDb()->prepare("
            UPDATE attendances 
            SET clock_out = ?, total_hours = TIMESTAMPDIFF(MINUTE, clock_in, ?) / 60 
            WHERE employee_id = ? AND date = ? AND clock_out IS NULL
        ");
        return $stmt->execute([$time, $time, $employeeId, $date]);
    }
}
'@
Set-Content -Path $attendanceRepoPath -Value $attendanceRepoContent -Encoding UTF8

# 4. Services
$timeTrackingServicePath = Join-Path $basePath "modules\HRM\Services\TimeTrackingService.php"
$timeTrackingServiceContent = @'
<?php
namespace Modules\HRM\Services;
use Modules\HRM\Repositories\AttendanceRepository;
use Exception;

class TimeTrackingService {
    private AttendanceRepository $repo;
    public function __construct(AttendanceRepository $repo) { $this->repo = $repo; }

    public function clockIn(int $employeeId, string $ip): bool {
        return $this->repo->recordClockIn($employeeId, $ip);
    }
    
    public function clockOut(int $employeeId): bool {
        return $this->repo->recordClockOut($employeeId);
    }
}
'@
Set-Content -Path $timeTrackingServicePath -Value $timeTrackingServiceContent -Encoding UTF8

# 5. Controllers
$attendanceControllerPath = Join-Path $basePath "modules\HRM\Controllers\AttendanceController.php"
$attendanceControllerContent = @'
<?php
namespace Modules\HRM\Controllers;
use App\Core\BaseController;

class AttendanceController extends BaseController {
    public function index() {
        return $this->view('attendance/timesheet', [], 'HRM');
    }
}
'@
Set-Content -Path $attendanceControllerPath -Value $attendanceControllerContent -Encoding UTF8

$apiHrmControllerPath = Join-Path $basePath "modules\HRM\Controllers\ApiHrmController.php"
$apiHrmControllerContent = @'
<?php
namespace Modules\HRM\Controllers;
use App\Core\BaseController;
use Modules\HRM\Services\TimeTrackingService;

class ApiHrmController extends BaseController {
    private TimeTrackingService $service;
    public function __construct(TimeTrackingService $service) { $this->service = $service; }

    public function clockIn() {
        // Mock employee ID for now
        $employeeId = $_SESSION['employee_id'] ?? 1;
        $ip = $_SERVER['REMOTE_ADDR'];
        $success = $this->service->clockIn($employeeId, $ip);
        return $this->jsonResponse(['success' => $success]);
    }

    public function clockOut() {
        $employeeId = $_SESSION['employee_id'] ?? 1;
        $success = $this->service->clockOut($employeeId);
        return $this->jsonResponse(['success' => $success]);
    }
}
'@
Set-Content -Path $apiHrmControllerPath -Value $apiHrmControllerContent -Encoding UTF8

# 6. Routes
$webRoutesPath = Join-Path $basePath "modules\HRM\Routes\web.php"
Set-Content -Path $webRoutesPath -Value "<?php return [ 'GET /hrm/timesheet' => [Modules\HRM\Controllers\AttendanceController::class, 'index'] ];" -Encoding UTF8

$apiRoutesPath = Join-Path $basePath "modules\HRM\Routes\api.php"
Set-Content -Path $apiRoutesPath -Value "<?php return [ 'POST /api/hrm/clock-in' => [Modules\HRM\Controllers\ApiHrmController::class, 'clockIn'], 'POST /api/hrm/clock-out' => [Modules\HRM\Controllers\ApiHrmController::class, 'clockOut'] ];" -Encoding UTF8

# 7. Views
$timesheetView = Join-Path $basePath "modules\HRM\Views\attendance\timesheet.php"
$timesheetViewContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Timesheet - HRM</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container mt-4">
        <h2>My Timesheet</h2>
        <div class="mb-4">
            <button class="btn btn-success" onclick="clockIn()">Clock In</button>
            <button class="btn btn-danger" onclick="clockOut()">Clock Out</button>
        </div>
        <!-- Timesheet Table goes here -->
    </div>
    <script>
        function clockIn() {
            fetch('/api/hrm/clock-in', {method:'POST'}).then(r=>r.json()).then(console.log);
        }
        function clockOut() {
            fetch('/api/hrm/clock-out', {method:'POST'}).then(r=>r.json()).then(console.log);
        }
    </script>
</body>
</html>
'@
Set-Content -Path $timesheetView -Value $timesheetViewContent -Encoding UTF8

Write-Host "HRM module Phase 1 built successfully."
