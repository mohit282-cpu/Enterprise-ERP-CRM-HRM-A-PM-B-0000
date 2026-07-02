<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-body p-0">
                <div class="container mt-4">
        <h2>Expiring Assets (45 Days)</h2>
        <div class="card shadow-sm mt-4 p-4">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Type</th>
                        <th>Name</th>
                        <th>Client</th>
                        <th>Expiry Date</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if(empty($expiring)): ?>
                        <tr><td colspan="5" class="text-center">No upcoming expirations found.</td></tr>
                    <?php else: ?>
                        <?php foreach($expiring as $e): ?>
                        <tr class="<?= (strtotime($e['expiry_date']) < time()) ? 'table-danger' : 'table-warning' ?>">
                            <td><span class="badge bg-secondary"><?= htmlspecialchars($e['type']) ?></span></td>
                            <td><strong><?= htmlspecialchars($e['name']) ?></strong></td>
                            <td><?= htmlspecialchars($e['first_name'] . ' ' . $e['last_name']) ?></td>
                            <td><?= htmlspecialchars($e['expiry_date']) ?></td>
                            <td>
                                <?= (strtotime($e['expiry_date']) < time()) ? 'OVERDUE' : 'Expiring Soon' ?>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
            </div>
        </div>
    </div>
</div>