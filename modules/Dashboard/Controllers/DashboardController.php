<?php
namespace Modules\Dashboard\Controllers;

use App\Core\BaseController;
use Modules\Dashboard\Services\DashboardService;
use Modules\Dashboard\Repositories\DashboardPreferenceRepository;

class DashboardController extends BaseController {
    private DashboardService $dashboardService;
    private DashboardPreferenceRepository $prefRepo;

    public function __construct(DashboardService $dashboardService, DashboardPreferenceRepository $prefRepo) {
        $this->dashboardService = $dashboardService;
        $this->prefRepo = $prefRepo;
    }

    public function index() {
        $kpiStats = $this->dashboardService->getKpiStats();
        $recentActivity = $this->dashboardService->getRecentActivity();
        
        return $this->view('index', [
            'kpi' => $kpiStats,
            'activity' => $recentActivity
        ], 'Dashboard'); // Assumes view loader handles pathing within the module
    }
}
