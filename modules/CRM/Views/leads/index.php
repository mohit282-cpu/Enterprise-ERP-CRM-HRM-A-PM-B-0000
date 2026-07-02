<div class="row mb-4">
    <div class="col-12 d-flex justify-content-between align-items-center">
        <h4 class="fw-bold tracking-tight mb-0">CRM Leads</h4>
        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addModal"><i class="fas fa-plus me-2"></i> Add New</button>
    </div>
</div>

<div class="card shadow-sm border-0">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="bg-light">
                    <tr>
                        <th class="ps-4">ID</th>
                        <th>Lead Name</th>
<th>Company</th>
<th>Email</th>
<th>Stage</th>

                        <th class="text-end pe-4">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if(!empty($leads)): foreach($leads as $row): ?>
                    <tr>
                        <td class="ps-4">#<?= htmlspecialchars($row['id'] ?? '') ?></td>
                        <td><?= htmlspecialchars($row['name'] ?? '') ?></td>
<td><?= htmlspecialchars($row['company'] ?? '') ?></td>
<td><?= htmlspecialchars($row['email'] ?? '') ?></td>
<td><?= htmlspecialchars($row['stage'] ?? '') ?></td>

                        <td class="text-end pe-4">
                            <button class="btn btn-sm btn-light text-primary me-1"><i class="fas fa-edit"></i></button>
                            <button class="btn btn-sm btn-light text-danger"><i class=\"fas fa-trash\"></i></button>
                        </td>
                    </tr>
                    <?php endforeach; else: ?>
                    <tr>
                        <td colspan="10" class="text-center py-5 text-muted">
                            <i class="fas fa-inbox fa-3x mb-3 opacity-25"></i>
                            <p class="mb-0">No records found.</p>
                        </td>
                    </tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>
<div class="modal fade" id="addModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <form method="POST" action="/crm/leads">
            <div class="modal-content border-0 shadow-lg">
                <div class="modal-header bg-light border-0">
                    <h5 class="modal-title fw-bold">Add CRM Leads</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    
                    <div class="mb-3">
                        <label class="form-label fw-bold">Name</label>
                        <input type="text" name="name" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Company</label>
                        <input type="text" name="company" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Email</label>
                        <input type="email" name="email" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Stage</label>
                        <input type="text" name="stage" class="form-control" required>
                    </div>
                </div>
                <div class="modal-footer border-0 bg-light">
                    <button type="button" class="btn btn-link text-muted text-decoration-none" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary px-4">Save</button>
                </div>
            </div>
        </form>
    </div>
</div>