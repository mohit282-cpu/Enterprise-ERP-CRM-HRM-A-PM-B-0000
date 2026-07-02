<?php
namespace Modules\HRM\Controllers;

use App\Core\BaseController;
use Modules\HRM\Services\EmployeeService;

class EmployeeController extends BaseController {
    private EmployeeService $service;
    
    public function __construct(EmployeeService $service) {
        $this->service = $service;
    }
    
    public function index() {
        $data = $this->service->getAllRecords();
        return $this->view('employees/index', ['employees' => $data], 'HRM');
    }
}
