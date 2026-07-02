<?php
namespace Modules\Hosting\Services;
use Modules\Hosting\Repositories\HostingAccountRepository;
use Exception;

class ProvisioningService {
    private HostingAccountRepository $repo;
    public function __construct(HostingAccountRepository $repo) { $this->repo = $repo; }

    public function provisionAccount(array $data): int {
        // 1. Calculate exactly 1 year from today for renewal
        $data['next_renewal_date'] = date('Y-m-d', strtotime('+1 year'));
        
        // 2. Format username if not provided
        if (empty($data['username'])) {
            $data['username'] = substr(preg_replace('/[^a-zA-Z0-9]/', '', $data['domain_name']), 0, 8);
        }

        // 3. Stub for Phase 2: Call WHM/cPanel API to actually create the physical account on the server here

        // 4. Save to database
        return $this->repo->createAccount($data);
    }
}
