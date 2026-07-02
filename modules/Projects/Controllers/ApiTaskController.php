<?php
namespace Modules\Projects\Controllers;
use App\Core\BaseController;
use Modules\Projects\Services\TaskService;

class ApiTaskController extends BaseController {
    private TaskService $service;
    public function __construct(TaskService $service) { $this->service = $service; }

    public function moveTask() {
        $data = json_decode(file_get_contents('php://input'), true);
        if(isset($data['task_id']) && isset($data['status'])) {
            $success = $this->service->moveTask((int)$data['task_id'], $data['status']);
            return $this->jsonResponse(['success' => $success]);
        }
        return $this->jsonResponse(['error' => 'Invalid data'], 400);
    }
}
