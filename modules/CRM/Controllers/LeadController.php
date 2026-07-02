<?php
namespace Modules\CRM\Controllers;

use App\Core\BaseController;
use Modules\CRM\Services\LeadService;

class LeadController extends BaseController {
    private LeadService $service;
    
    public function __construct(LeadService $service) {
        $this->service = $service;
    }
    
    public function index() {
        $data = $this->service->getAllRecords();
        return $this->view('leads/index', ['leads' => $data], 'CRM');
    }

    public function store() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $data = $_POST;
            $this->service->createRecord($data);
            header('Location: /crm/leads');
            exit;
        }
    }
}
