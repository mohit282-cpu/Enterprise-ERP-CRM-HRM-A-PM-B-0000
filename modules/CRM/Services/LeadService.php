<?php
namespace Modules\CRM\Services;
use Modules\CRM\Repositories\LeadRepository;

class LeadService {
    private LeadRepository $repo;
    public function __construct(LeadRepository $repo) { $this->repo = $repo; }

    public function getPipeline(): array {
        return $this->repo->getLeadsByStage();
    }
    
    public function updateLeadStage(int $id, string $newStage): bool {
        // Here we could add logic to create a Customer if stage == 'won'
        return $this->repo->updateStage($id, $newStage);
    }
}
