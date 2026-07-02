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

    public function store() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $data = $_POST;
            $this->service->createRecord($data);
            header('Location: /hrm/employees');
            exit;
        }
    }

    public function update() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $id = $_POST['id'];
            unset($_POST['id']);
            $this->service->updateRecord((int)$id, $_POST);
            header('Location: /hrm/employees');
            exit;
        }
    }
    
    public function destroy() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $id = $_POST['id'];
            $this->service->deleteRecord((int)$id);
            header('Location: /hrm/employees');
            exit;
        }
    }
}
