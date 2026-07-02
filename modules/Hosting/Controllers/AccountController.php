<?php
namespace Modules\Hosting\Controllers;

use App\Core\BaseController;
use Modules\Hosting\Services\HostingService;

class AccountController extends BaseController {
    private HostingService $service;
    
    public function __construct(HostingService $service) {
        $this->service = $service;
    }
    
    public function index() {
        $data = $this->service->getAllRecords();
        return $this->view('accounts/index', ['accounts' => $data], 'Hosting');
    }
}
