<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sales Pipeline - CRM</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .kanban-board { display: flex; gap: 1rem; overflow-x: auto; padding-bottom: 1rem; }
        .kanban-col { background: #f8f9fa; min-width: 300px; border-radius: 5px; padding: 10px; }
        .lead-card { background: white; padding: 15px; margin-bottom: 10px; border-radius: 5px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); cursor: grab; }
    </style>
</head>
<body class="bg-light">
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
                        <small>$<?= number_format($lead['value'], 2) ?></small>
                    </div>
                    <?php endforeach; ?>
                </div>
            </div>
            <?php endforeach; ?>
        </div>
    </div>
    <!-- Add drag & drop JS logic here -->
</body>
</html>
