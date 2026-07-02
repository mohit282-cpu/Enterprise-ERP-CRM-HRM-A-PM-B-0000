<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Global Audit Logs</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container mt-4">
        <h2>Global Audit Logs</h2>
        <div class="card shadow-sm mt-4 p-4">
            <table class="table table-hover table-sm">
                <thead>
                    <tr>
                        <th>Timestamp</th>
                        <th>User</th>
                        <th>Action</th>
                        <th>Table</th>
                        <th>IP Address</th>
                        <th>Details</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if(empty($logs)): ?>
                        <tr><td colspan="6" class="text-center">No logs found.</td></tr>
                    <?php else: ?>
                        <?php foreach($logs as $log): ?>
                        <tr>
                            <td><?= htmlspecialchars($log['created_at']) ?></td>
                            <td><?= htmlspecialchars($log['username'] ?? 'System') ?></td>
                            <td><span class="badge bg-secondary"><?= htmlspecialchars($log['event_type']) ?></span></td>
                            <td><?= htmlspecialchars($log['table_name']) ?> (ID: <?= htmlspecialchars($log['record_id']) ?>)</td>
                            <td><?= htmlspecialchars($log['ip_address']) ?></td>
                            <td>
                                <?php if($log['new_values']): ?>
                                    <button class="btn btn-xs btn-outline-info">View JSON</button>
                                <?php endif; ?>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
