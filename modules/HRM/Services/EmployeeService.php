<?php
namespace Modules\HRM\Services;

use App\Core\BaseService;
use Modules\HRM\Repositories\EmployeeRepository;

class EmployeeService extends BaseService {
    private EmployeeRepository $repo;
    
    public function __construct(EmployeeRepository $repo) {
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
