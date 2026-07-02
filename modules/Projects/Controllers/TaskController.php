<?php
namespace Modules\Projects\Controllers;
use App\Core\BaseController;
use Modules\Projects\Services\TaskService;

class TaskController extends BaseController {
    private TaskService $service;
    public function __construct(TaskService $service) { $this->service = $service; }

    public function kanban(int $projectId) {
        $pipeline = $this->service->getProjectKanban($projectId);
        return $this->view('tasks/kanban', ['pipeline' => $pipeline, 'project_id' => $projectId], 'Projects');
    }
}
