<?php
namespace Modules\Domains\Controllers;
use App\Core\BaseController;
use Modules\Domains\Services\DomainService;

class DomainController extends BaseController {
    private DomainService $service;
    public function __construct(DomainService $service) { $this->service = $service; }

    public function index() {
        return $this->view('domains/index', [], 'Domains');
    }
}
