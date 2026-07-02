<?php
namespace Modules\Accounting\Services;

use App\Core\BaseService;
use Modules\Accounting\Repositories\AccountRepository;

class AccountService extends BaseService {
    private AccountRepository $repo;
    
    public function __construct(AccountRepository $repo) {
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
