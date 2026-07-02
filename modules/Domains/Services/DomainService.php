<?php
namespace Modules\Domains\Services;

use App\Core\BaseService;
use Modules\Domains\Repositories\DomainRepository;

class DomainService extends BaseService {
    private DomainRepository $repo;
    
    public function __construct(DomainRepository $repo) {
        $this->repo = $repo;
    }
    
    public function getAllRecords() {
        return $this->repo->getAll();
    }

    public function createRecord(array $data) {
        return $this->repo->create($data);
    }
}
