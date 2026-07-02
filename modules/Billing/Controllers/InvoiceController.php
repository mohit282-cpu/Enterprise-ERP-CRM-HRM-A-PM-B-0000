<?php
namespace Modules\Billing\Controllers;

use App\Core\BaseController;
use Modules\Billing\Services\InvoiceService;

class InvoiceController extends BaseController {
    private InvoiceService $service;
    
    public function __construct(InvoiceService $service) {
        $this->service = $service;
    }
    
    public function index() {
        $data = $this->service->getAllRecords();
        return $this->view('invoices/index', ['invoices' => $data], 'Billing');
    }

    public function store() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $data = $_POST;
            $this->service->createRecord($data);
            header('Location: /billing/invoices');
            exit;
        }
    }

    public function update() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $id = $_POST['id'];
            unset($_POST['id']);
            $this->service->updateRecord((int)$id, $_POST);
            header('Location: /billing/invoices');
            exit;
        }
    }
    
    public function destroy() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $id = $_POST['id'];
            $this->service->deleteRecord((int)$id);
            header('Location: /billing/invoices');
            exit;
        }
    }
}
