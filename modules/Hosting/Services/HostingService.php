<?php
namespace Modules\Hosting\Services;

use App\Core\BaseService;
use Modules\Hosting\Repositories\HostingRepository;

class HostingService extends BaseService {
    private HostingRepository $repo;
    
    public function __construct(HostingRepository $repo) {
        $this->repo = $repo;
    }
    
    public function getAllRecords() {
        return $this->repo->getAll();
    }

    public function createRecord(array $data) {
        return $this->repo->create($data);
    }

    public function updateRecord(int $id, array $data) {
        return $this->repo->update($id, $data);
    }
    
    public function deleteRecord(int $id) {
        return $this->repo->delete($id);
    }
}
