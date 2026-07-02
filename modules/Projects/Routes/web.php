<?php return [ 'GET /projects' => [Modules\Projects\Controllers\ProjectController::class, 'index'], 'GET /projects/{id}/kanban' => [Modules\Projects\Controllers\TaskController::class, 'kanban'] ];
