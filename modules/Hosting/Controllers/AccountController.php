<?php
namespace Modules\Hosting\Controllers;

use App\Core\BaseController;
use Modules\Hosting\Services\HostingService;

class AccountController extends BaseController {
    private HostingService $service;
    
    public function __construct(HostingService $service) {
        $this->service = $service;
    }
    
    public function index() {
        $data = $this->service->getAllRecords();
        return $this->view('accounts/index', ['accounts' => $data], 'Hosting');
    }

    public function store() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $data = $_POST;
            $this->service->createRecord($data);
            header('Location: /hosting/accounts');
            exit;
        }
    }

    public function update() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $id = $_POST['id'];
            unset($_POST['id']);
            $this->service->updateRecord((int)$id, $_POST);
            header('Location: /hosting/accounts');
            exit;
        }
    }
    
    public function destroy() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $id = $_POST['id'];
            $this->service->deleteRecord((int)$id);
            header('Location: /hosting/accounts');
            exit;
        }
    }
}
