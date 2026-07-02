<?php
namespace Modules\Hosting\Controllers;
use App\Core\BaseController;
use Modules\Hosting\Repositories\HostingAccountRepository;

class RenewalController extends BaseController {
    private HostingAccountRepository $repo;
    public function __construct(HostingAccountRepository $repo) { $this->repo = $repo; }

    public function index() {
        $renewals = $this->repo->getAccountsPendingRenewal();
        return $this->view('renewals/index', ['renewals' => $renewals], 'Hosting');
    }
}
