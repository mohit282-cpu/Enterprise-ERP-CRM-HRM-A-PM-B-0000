<?php
namespace Modules\Dashboard\Controllers;

use App\Core\BaseController;
use Modules\Dashboard\Services\DashboardService;

class ApiDashboardController extends BaseController {
    private DashboardService $dashboardService;

    public function __construct(DashboardService $dashboardService) {
        $this->dashboardService = $dashboardService;
    }

    public function getChartData() {
        $data = $this->dashboardService->getRevenueChartData();
        return $this->jsonResponse($data);
    }
}
