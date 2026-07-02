<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-body p-0">
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
            </div>
        </div>
    </div>
</div>