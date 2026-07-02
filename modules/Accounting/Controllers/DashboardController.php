<?php
namespace Modules\Accounting\Controllers;

use App\Core\BaseController;
use Modules\Accounting\Services\AccountService;

class DashboardController extends BaseController {
    private AccountService $service;
    
    public function __construct(AccountService $service) {
        $this->service = $service;
    }
    
    public function index() {
        $data = $this->service->getAllRecords();
        return $this->view('dashboard/index', ['accounts' => $data], 'Accounting');
    }
}
