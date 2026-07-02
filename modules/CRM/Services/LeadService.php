<?php
namespace Modules\CRM\Services;

use App\Core\BaseService;
use Modules\CRM\Repositories\LeadRepository;

class LeadService extends BaseService {
    private LeadRepository $repo;
    
    public function __construct(LeadRepository $repo) {
        $this->repo = $repo;
    }
    
    public function getAllRecords() {
        return $this->repo->getAll();
    }

    public function createRecord(array $data) {
        return $this->repo->create($data);
    }
}
