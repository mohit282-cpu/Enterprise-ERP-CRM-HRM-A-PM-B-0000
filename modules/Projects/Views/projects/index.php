<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-body p-0">
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
            </div>
        </div>
    </div>
</div>