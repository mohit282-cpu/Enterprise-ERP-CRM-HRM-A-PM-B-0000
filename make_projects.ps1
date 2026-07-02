$basePath = "z:\xampp\htdocs\Enterprise-ERP-CRM-HRM-A-PM-B-0000"

# Directories
$dirs = @(
    "database\migrations",
    "modules\Projects\Models",
    "modules\Projects\Repositories",
    "modules\Projects\Services",
    "modules\Projects\Controllers",
    "modules\Projects\Routes",
    "modules\Projects\Views\projects",
    "modules\Projects\Views\tasks"
)

foreach ($dir in $dirs) {
    $fullPath = Join-Path $basePath $dir
    if (-not (Test-Path $fullPath)) { New-Item -ItemType Directory -Force -Path $fullPath | Out-Null }
}

# 1. Database Migration
$migrationPath = Join-Path $basePath "database\migrations\2026_01_10_000000_create_pm_tables.php"
$migrationContent = @'
<?php
class CreatePmTables {
    public function up($db) {
        $sql = "
        CREATE TABLE milestones (
            id INT AUTO_INCREMENT PRIMARY KEY,
            project_id INT NOT NULL,
            name VARCHAR(255) NOT NULL,
            description TEXT,
            due_date DATE,
            status ENUM('pending', 'in_progress', 'completed') DEFAULT 'pending',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
        );

        -- Add structural columns to tasks
        ALTER TABLE tasks ADD COLUMN parent_id INT NULL AFTER project_id;
        ALTER TABLE tasks ADD COLUMN milestone_id INT NULL AFTER parent_id;
        ALTER TABLE tasks ADD COLUMN progress TINYINT DEFAULT 0 AFTER status;
        ALTER TABLE tasks ADD COLUMN estimated_hours DECIMAL(5,2) DEFAULT 0.00;
        
        ALTER TABLE tasks ADD CONSTRAINT fk_task_parent FOREIGN KEY (parent_id) REFERENCES tasks(id) ON DELETE CASCADE;
        ALTER TABLE tasks ADD CONSTRAINT fk_task_milestone FOREIGN KEY (milestone_id) REFERENCES milestones(id) ON DELETE SET NULL;

        CREATE TABLE task_comments (
            id INT AUTO_INCREMENT PRIMARY KEY,
            task_id INT NOT NULL,
            user_id INT NOT NULL,
            comment TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );

        CREATE TABLE project_files (
            id INT AUTO_INCREMENT PRIMARY KEY,
            project_id INT NOT NULL,
            task_id INT NULL,
            user_id INT NOT NULL,
            file_name VARCHAR(255) NOT NULL,
            file_path VARCHAR(255) NOT NULL,
            file_size INT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
            FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
        ";
        $db->exec($sql);
    }
    public function down($db) {
        $db->exec("
            DROP TABLE IF EXISTS project_files, task_comments;
            ALTER TABLE tasks DROP FOREIGN KEY fk_task_parent;
            ALTER TABLE tasks DROP FOREIGN KEY fk_task_milestone;
            ALTER TABLE tasks DROP COLUMN parent_id, DROP COLUMN milestone_id, DROP COLUMN progress, DROP COLUMN estimated_hours;
            DROP TABLE IF EXISTS milestones;
        ");
    }
}
'@
Set-Content -Path $migrationPath -Value $migrationContent -Encoding UTF8

# 2. Models
$projectModelPath = Join-Path $basePath "modules\Projects\Models\Project.php"
Set-Content -Path $projectModelPath -Value "<?php namespace Modules\Projects\Models; use App\Core\BaseModel; class Project extends BaseModel { protected string `$table = 'projects'; }" -Encoding UTF8

$taskModelPath = Join-Path $basePath "modules\Projects\Models\Task.php"
Set-Content -Path $taskModelPath -Value "<?php namespace Modules\Projects\Models; use App\Core\BaseModel; class Task extends BaseModel { protected string `$table = 'tasks'; }" -Encoding UTF8

$milestoneModelPath = Join-Path $basePath "modules\Projects\Models\Milestone.php"
Set-Content -Path $milestoneModelPath -Value "<?php namespace Modules\Projects\Models; use App\Core\BaseModel; class Milestone extends BaseModel { protected string `$table = 'milestones'; }" -Encoding UTF8

# 3. Repositories
$taskRepoPath = Join-Path $basePath "modules\Projects\Repositories\TaskRepository.php"
$taskRepoContent = @'
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
'@
Set-Content -Path $taskRepoPath -Value $taskRepoContent -Encoding UTF8

$projectRepoPath = Join-Path $basePath "modules\Projects\Repositories\ProjectRepository.php"
$projectRepoContent = @'
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
'@
Set-Content -Path $projectRepoPath -Value $projectRepoContent -Encoding UTF8


# 4. Services
$taskServicePath = Join-Path $basePath "modules\Projects\Services\TaskService.php"
$taskServiceContent = @'
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
'@
Set-Content -Path $taskServicePath -Value $taskServiceContent -Encoding UTF8

$projectServicePath = Join-Path $basePath "modules\Projects\Services\ProjectService.php"
$projectServiceContent = @'
<?php
namespace Modules\Projects\Services;
use Modules\Projects\Repositories\ProjectRepository;

class ProjectService {
    private ProjectRepository $repo;
    public function __construct(ProjectRepository $repo) { $this->repo = $repo; }

    public function getProjectOverviews(): array {
        $projects = $this->repo->getAllProjects();
        foreach ($projects as &$p) {
            $p['progress_percentage'] = $p['total_tasks'] > 0 ? round(($p['completed_tasks'] / $p['total_tasks']) * 100) : 0;
        }
        return $projects;
    }
}
'@
Set-Content -Path $projectServicePath -Value $projectServiceContent -Encoding UTF8

# 5. Controllers
$projectControllerPath = Join-Path $basePath "modules\Projects\Controllers\ProjectController.php"
$projectControllerContent = @'
<?php
namespace Modules\Projects\Controllers;
use App\Core\BaseController;
use Modules\Projects\Services\ProjectService;

class ProjectController extends BaseController {
    private ProjectService $service;
    public function __construct(ProjectService $service) { $this->service = $service; }

    public function index() {
        $projects = $this->service->getProjectOverviews();
        return $this->view('projects/index', ['projects' => $projects], 'Projects');
    }
}
'@
Set-Content -Path $projectControllerPath -Value $projectControllerContent -Encoding UTF8

$taskControllerPath = Join-Path $basePath "modules\Projects\Controllers\TaskController.php"
$taskControllerContent = @'
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
'@
Set-Content -Path $taskControllerPath -Value $taskControllerContent -Encoding UTF8

$apiTaskControllerPath = Join-Path $basePath "modules\Projects\Controllers\ApiTaskController.php"
$apiTaskControllerContent = @'
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
'@
Set-Content -Path $apiTaskControllerPath -Value $apiTaskControllerContent -Encoding UTF8


# 6. Routes
$webRoutesPath = Join-Path $basePath "modules\Projects\Routes\web.php"
Set-Content -Path $webRoutesPath -Value "<?php return [ 'GET /projects' => [Modules\Projects\Controllers\ProjectController::class, 'index'], 'GET /projects/{id}/kanban' => [Modules\Projects\Controllers\TaskController::class, 'kanban'] ];" -Encoding UTF8

$apiRoutesPath = Join-Path $basePath "modules\Projects\Routes\api.php"
Set-Content -Path $apiRoutesPath -Value "<?php return [ 'POST /api/projects/tasks/move' => [Modules\Projects\Controllers\ApiTaskController::class, 'moveTask'] ];" -Encoding UTF8


# 7. Views
$projectIndexView = Join-Path $basePath "modules\Projects\Views\projects\index.php"
$projectIndexViewContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Projects Overview</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container mt-4">
        <h2>Active Projects</h2>
        <div class="row mt-4">
            <?php foreach($projects as $p): ?>
            <div class="col-md-4 mb-4">
                <div class="card shadow-sm">
                    <div class="card-body">
                        <h5 class="card-title"><?= htmlspecialchars($p['name']) ?></h5>
                        <div class="progress mt-3">
                            <div class="progress-bar bg-success" role="progressbar" style="width: <?= $p['progress_percentage'] ?>%;" aria-valuenow="<?= $p['progress_percentage'] ?>" aria-valuemin="0" aria-valuemax="100"><?= $p['progress_percentage'] ?>%</div>
                        </div>
                        <a href="/projects/<?= $p['id'] ?>/kanban" class="btn btn-sm btn-outline-primary mt-3">View Kanban</a>
                    </div>
                </div>
            </div>
            <?php endforeach; ?>
        </div>
    </div>
</body>
</html>
'@
Set-Content -Path $projectIndexView -Value $projectIndexViewContent -Encoding UTF8

$kanbanViewPath = Join-Path $basePath "modules\Projects\Views\tasks\kanban.php"
$kanbanViewContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Task Kanban</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .kanban-board { display: flex; gap: 1rem; overflow-x: auto; padding-bottom: 1rem; }
        .kanban-col { background: #e9ecef; min-width: 300px; border-radius: 5px; padding: 10px; }
        .task-card { background: white; padding: 15px; margin-bottom: 10px; border-radius: 5px; box-shadow: 0 1px 2px rgba(0,0,0,0.1); cursor: grab; }
    </style>
</head>
<body class="bg-light">
    <div class="container-fluid p-4">
        <h2>Project Kanban</h2>
        <div class="kanban-board mt-4">
            <?php foreach($pipeline as $stage => $tasks): ?>
            <div class="kanban-col" data-stage="<?= htmlspecialchars($stage) ?>">
                <h6 class="text-uppercase text-muted fw-bold"><?= str_replace('_', ' ', $stage) ?> (<?= count($tasks) ?>)</h6>
                <div class="task-list" style="min-height: 200px;">
                    <?php foreach($tasks as $task): ?>
                    <div class="task-card" data-id="<?= $task['id'] ?>">
                        <strong><?= htmlspecialchars($task['title']) ?></strong>
                    </div>
                    <?php endforeach; ?>
                </div>
            </div>
            <?php endforeach; ?>
        </div>
    </div>
</body>
</html>
'@
Set-Content -Path $kanbanViewPath -Value $kanbanViewContent -Encoding UTF8

Write-Host "Project Management module Phase 1 built successfully."
