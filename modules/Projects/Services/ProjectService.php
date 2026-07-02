<?php
namespace Modules\Projects\Services;

use App\Core\BaseService;
use Modules\Projects\Repositories\ProjectRepository;

class ProjectService extends BaseService {
    private ProjectRepository $repo;
    
    public function __construct(ProjectRepository $repo) {
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
