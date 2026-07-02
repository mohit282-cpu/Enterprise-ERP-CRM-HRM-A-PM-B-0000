<?php
namespace Modules\Billing\Services;

use App\Core\BaseService;
use Modules\Billing\Repositories\InvoiceRepository;

class InvoiceService extends BaseService {
    private InvoiceRepository $repo;
    
    public function __construct(InvoiceRepository $repo) {
        $this->repo = $repo;
    }
    
    public function getAllRecords() {
        return $this->repo->getAll();
    }
}
