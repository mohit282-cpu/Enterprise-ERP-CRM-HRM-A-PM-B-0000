<?php
namespace Modules\Reports\Controllers;
use App\Core\BaseController;
use Modules\Reports\Services\AnalyticsService;

class ApiAnalyticsController extends BaseController {
    private AnalyticsService $service;
    public function __construct(AnalyticsService $service) { $this->service = $service; }

    public function getFinanceChart() {
        $year = $_GET['year'] ?? date('Y');
        $data = $this->service->getFinanceChartData($year);
        return $this->jsonResponse($data);
    }
}
