<?php
namespace Modules\Accounting\Controllers;

use App\Core\BaseController;
use Modules\Accounting\Services\AccountService;

class DashboardController extends BaseController {
    private AccountService $service;
    
    public function __construct(AccountService $service) {
        $this->service = $service;
    }
    
    public function index() {
        $data = $this->service->getAllRecords();
        return $this->view('dashboard/index', ['accounts' => $data], 'Accounting');
    }

    public function store() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $data = $_POST;
            $this->service->createRecord($data);
            header('Location: /accounting');
            exit;
        }
    }

    public function update() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $id = $_POST['id'];
            unset($_POST['id']);
            $this->service->updateRecord((int)$id, $_POST);
            header('Location: /accounting');
            exit;
        }
    }
    
    public function destroy() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $id = $_POST['id'];
            $this->service->deleteRecord((int)$id);
            header('Location: /accounting');
            exit;
        }
    }
}
