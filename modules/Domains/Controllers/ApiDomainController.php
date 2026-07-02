<?php
namespace Modules\Domains\Controllers;
use App\Core\BaseController;
use Modules\Domains\Services\DomainService;

class ApiDomainController extends BaseController {
    private DomainService $service;
    public function __construct(DomainService $service) { $this->service = $service; }

    public function sanitize() {
        $data = json_decode(file_get_contents('php://input'), true);
        if(isset($data['domain'])) {
            $clean = $this->service->sanitizeDomainName($data['domain']);
            return $this->jsonResponse(['clean_domain' => $clean]);
        }
        return $this->jsonResponse(['error' => 'Missing domain parameter'], 400);
    }
}
