<?php
namespace Modules\Reports\Controllers;

use App\Core\BaseController;
use Modules\Reports\Services\ReportService;

class ReportsController extends BaseController {
    private ReportService $service;
    
    public function __construct(ReportService $service) {
        $this->service = $service;
    }
    
    public function index() {
        $data = $this->service->getAllRecords();
        return $this->view('index', ['reports' => $data], 'Reports');
    }
}
