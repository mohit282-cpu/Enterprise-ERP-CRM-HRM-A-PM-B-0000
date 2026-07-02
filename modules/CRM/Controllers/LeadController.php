<?php
namespace Modules\CRM\Controllers;

use App\Core\BaseController;
use Modules\CRM\Services\LeadService;

class LeadController extends BaseController {
    private $service;

    public function __construct() {
        $this->service = new LeadService();
    }

    public function index() {
        $leads = $this->service->getLeads();
        // Calculate pipeline metrics
        $metrics = [
            'total' => count($leads),
            'new' => count(array_filter($leads, fn($l) => strtolower($l['stage']) === 'new')),
            'won' => count(array_filter($leads, fn($l) => strtolower($l['stage']) === 'won')),
            'revenue' => array_sum(array_column($leads, 'expected_revenue'))
        ];
        return $this->view('index', ['leads' => $leads, 'metrics' => $metrics], 'CRM');
    }

    public function store() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            try {
                $this->service->createLead($_POST);
                // Here we would set a flash message
            } catch (\Exception $e) {
                // Here we would log the error and set an error flash message
            }
            header('Location: /crm/leads');
            exit;
        }
    }

    public function update() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            try {
                $id = $_POST['id'];
                unset($_POST['id']);
                $this->service->updateLead((int)$id, $_POST);
            } catch (\Exception $e) {
                // Handle error
            }
            header('Location: /crm/leads');
            exit;
        }
    }

    public function destroy() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->service->deleteLead((int)$_POST['id']);
            header('Location: /crm/leads');
            exit;
        }
    }
}