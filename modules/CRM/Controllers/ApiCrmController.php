<?php
namespace Modules\CRM\Controllers;
use App\Core\BaseController;
use Modules\CRM\Services\LeadService;

class ApiCrmController extends BaseController {
    private LeadService $service;
    public function __construct(LeadService $service) { $this->service = $service; }

    public function updateLeadStage() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $data = json_decode(file_get_contents('php://input'), true);
            $success = $this->service->updateLeadStage((int)$data['id'], $data['status']);
            return $this->jsonResponse(['success' => $success]);
        }
        return $this->jsonResponse(['error' => 'Invalid method'], 405);
    }
}
