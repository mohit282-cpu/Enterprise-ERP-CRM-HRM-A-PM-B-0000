<?php
namespace Modules\Projects\Repositories;
use Modules\Projects\Models\Project;
use PDO;

class ProjectRepository {
    private Project $model;
    public function __construct(Project $model) { $this->model = $model; }

    public function getAllProjects(): array {
        $stmt = $this->model->getDb()->query("SELECT p.*, (SELECT COUNT(*) FROM tasks t WHERE t.project_id = p.id) as total_tasks, (SELECT COUNT(*) FROM tasks t WHERE t.project_id = p.id AND t.status = 'done') as completed_tasks FROM projects p");
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
