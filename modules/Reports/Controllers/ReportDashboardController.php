<?php
namespace Modules\Reports\Controllers;
use App\Core\BaseController;

class ReportDashboardController extends BaseController {
    public function index() {
        return $this->view('dashboard/index', [], 'Reports');
    }
}
