<?php
namespace Modules\HRM\Controllers;
use App\Core\BaseController;

class AttendanceController extends BaseController {
    public function index() {
        return $this->view('attendance/timesheet', [], 'HRM');
    }
}
