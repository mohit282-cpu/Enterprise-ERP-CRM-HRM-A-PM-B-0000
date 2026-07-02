<?php
namespace Modules\Domains\Controllers;
use App\Core\BaseController;
use Modules\Domains\Repositories\DomainRepository;

class ExpiryController extends BaseController {
    private DomainRepository $repo;
    public function __construct(DomainRepository $repo) { $this->repo = $repo; }

    public function index() {
        $expiring = $this->repo->getExpiringAssets(45); // Check 45 days out
        return $this->view('expiry/index', ['expiring' => $expiring], 'Domains');
    }
}
