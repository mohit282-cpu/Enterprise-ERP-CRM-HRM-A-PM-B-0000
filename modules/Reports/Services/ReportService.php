<?php
namespace Modules\Reports\Services;

use App\Core\BaseService;
use Modules\Reports\Repositories\ReportRepository;

class ReportService extends BaseService {
    private ReportRepository $repo;
    
    public function __construct(ReportRepository $repo) {
        $this->repo = $repo;
    }
    
    public function getAllRecords() {
        return $this->repo->getAll();
    }
}
