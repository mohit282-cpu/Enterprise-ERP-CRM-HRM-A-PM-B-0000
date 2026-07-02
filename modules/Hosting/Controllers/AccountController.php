<?php
namespace Modules\Hosting\Controllers;
use App\Core\BaseController;
use Modules\Hosting\Services\ProvisioningService;
use Exception;

class AccountController extends BaseController {
    private ProvisioningService $service;
    public function __construct(ProvisioningService $service) { $this->service = $service; }

    public function create() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            try {
                // Dummy logic for testing routing
                $id = $this->service->provisionAccount($_POST);
                return $this->redirect("/hosting/accounts/$id");
            } catch (Exception $e) {
                return $this->view('accounts/create', ['error' => $e->getMessage()], 'Hosting');
            }
        }
        return $this->view('accounts/create', [], 'Hosting');
    }
}
