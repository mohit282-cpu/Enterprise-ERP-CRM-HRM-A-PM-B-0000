<div class="card shadow-sm h-100">
    <div class="card-header bg-white">
        <h5 class="mb-0">Recent Activity</h5>
    </div>
    <div class="card-body">
        <ul class="list-group list-group-flush">
            <?php foreach($activity as $log): ?>
                <li class="list-group-item d-flex justify-content-between align-items-center">
                    <?= htmlspecialchars($log['action']) ?>
                    <span class="badge bg-secondary rounded-pill"><?= htmlspecialchars($log['time']) ?></span>
                </li>
            <?php endforeach; ?>
        </ul>
    </div>
</div>
