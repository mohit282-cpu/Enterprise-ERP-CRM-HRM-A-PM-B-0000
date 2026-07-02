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
