<?php
namespace Modules\CRM\Repositories;
use Modules\CRM\Models\Lead;
use PDO;

class LeadRepository {
    private Lead $model;
    public function __construct(Lead $model) { $this->model = $model; }

    public function getLeadsByStage(): array {
        $stmt = $this->model->getDb()->query("SELECT * FROM leads ORDER BY created_at DESC");
        $leads = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        $grouped = ['new' => [], 'contacted' => [], 'qualified' => [], 'won' => [], 'lost' => []];
        foreach ($leads as $lead) {
            $grouped[$lead['status']][] = $lead;
        }
        return $grouped;
    }

    public function updateStage(int $id, string $status): bool {
        $stmt = $this->model->getDb()->prepare("UPDATE leads SET status = ? WHERE id = ?");
        return $stmt->execute([$status, $id]);
    }
}
