<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-body p-0">
                <div class="container mt-4">
        <h2>Upcoming Hosting Renewals (30 Days)</h2>
        <div class="card shadow-sm mt-4 p-4">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Client</th>
                        <th>Domain</th>
                        <th>Plan</th>
                        <th>Renewal Date</th>
                        <th>Annual Price</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if(empty($renewals)): ?>
                        <tr><td colspan="6" class="text-center">No upcoming renewals found.</td></tr>
                    <?php else: ?>
                        <?php foreach($renewals as $r): ?>
                        <tr class="<?= (strtotime($r['next_renewal_date']) < time()) ? 'table-danger' : '' ?>">
                            <td><?= htmlspecialchars($r['first_name'] . ' ' . $r['last_name']) ?></td>
                            <td><strong><?= htmlspecialchars($r['domain_name']) ?></strong></td>
                            <td><?= htmlspecialchars($r['plan_name']) ?></td>
                            <td><?= htmlspecialchars($r['next_renewal_date']) ?></td>
                            <td>Rs. <?= htmlspecialchars($r['annual_price']) ?></td>
                            <td><button class="btn btn-sm btn-primary">Generate Invoice</button></td>
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