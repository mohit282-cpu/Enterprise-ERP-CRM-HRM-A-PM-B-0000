<?php
namespace Modules\CRM\Controllers;
use App\Core\BaseController;
use Modules\CRM\Services\LeadService;

class LeadController extends BaseController {
    private LeadService $service;
    public function __construct(LeadService $service) { $this->service = $service; }

    public function kanban() {
        $pipeline = $this->service->getPipeline();
        return $this->view('leads/kanban', ['pipeline' => $pipeline], 'CRM');
    }
}
