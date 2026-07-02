<?php
namespace Modules\Projects\Repositories;
use Modules\Projects\Models\Task;
use PDO;

class TaskRepository {
    private Task $model;
    public function __construct(Task $model) { $this->model = $model; }

    public function getTasksByProjectAndStage(int $projectId): array {
        $stmt = $this->model->getDb()->prepare("SELECT * FROM tasks WHERE project_id = ? AND parent_id IS NULL ORDER BY created_at DESC");
        $stmt->execute([$projectId]);
        $tasks = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        $grouped = ['todo' => [], 'in_progress' => [], 'review' => [], 'done' => []];
        foreach ($tasks as $task) {
            $grouped[$task['status']][] = $task;
        }
        return $grouped;
    }

    public function updateStage(int $id, string $status): bool {
        $stmt = $this->model->getDb()->prepare("UPDATE tasks SET status = ? WHERE id = ?");
        return $stmt->execute([$status, $id]);
    }
}
