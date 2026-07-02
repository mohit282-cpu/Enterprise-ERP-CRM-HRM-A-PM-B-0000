<?php
namespace Modules\Inventory\Services;

use App\Core\BaseService;
use Modules\Inventory\Repositories\ProductRepository;

class ProductService extends BaseService {
    private ProductRepository $repo;
    
    public function __construct(ProductRepository $repo) {
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
