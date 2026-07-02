<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-body p-0">
                <div class="container-fluid p-4">
        <h2>Sales Pipeline (Kanban)</h2>
        <div class="kanban-board mt-4">
            <?php foreach($pipeline as $stage => $leads): ?>
            <div class="kanban-col" data-stage="<?= htmlspecialchars($stage) ?>">
                <h5><?= ucfirst($stage) ?> (<?= count($leads) ?>)</h5>
                <div class="lead-list" style="min-height: 200px;">
                    <?php foreach($leads as $lead): ?>
                    <div class="lead-card" data-id="<?= $lead['id'] ?>">
                        <strong><?= htmlspecialchars($lead['title']) ?></strong><br>
                        <small>Rs. <?= number_format($lead['value'], 2) ?></small>
                    </div>
                    <?php endforeach; ?>
                </div>
            </div>
            <?php endforeach; ?>
        </div>
    </div>
    <!-- Add drag & drop JS logic here -->
            </div>
        </div>
    </div>
</div>