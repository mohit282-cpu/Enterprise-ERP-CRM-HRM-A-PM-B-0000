<?php
namespace Modules\Projects\Services;
use Modules\Projects\Repositories\TaskRepository;

class TaskService {
    private TaskRepository $repo;
    public function __construct(TaskRepository $repo) { $this->repo = $repo; }

    public function getProjectKanban(int $projectId): array {
        return $this->repo->getTasksByProjectAndStage($projectId);
    }
    
    public function moveTask(int $taskId, string $newStage): bool {
        return $this->repo->updateStage($taskId, $newStage);
    }
}
