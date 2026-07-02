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
}
