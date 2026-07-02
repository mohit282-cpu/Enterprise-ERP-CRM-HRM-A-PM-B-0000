<?php
namespace Modules\Billing\Controllers;
use App\Core\BaseController;
use Modules\Billing\Services\InvoiceService;

class InvoiceController extends BaseController {
    private InvoiceService $service;
    public function __construct(InvoiceService $service) { $this->service = $service; }

    public function index() {
        return $this->view('invoices/index', [], 'Billing');
    }

    public function create() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $id = $this->service->generateInvoice($_POST);
            return $this->redirect("/billing/invoices/$id");
        }
        return $this->view('invoices/create', [], 'Billing');
    }
}
