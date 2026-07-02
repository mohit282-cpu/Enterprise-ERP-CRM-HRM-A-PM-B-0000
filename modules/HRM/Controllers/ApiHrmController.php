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
