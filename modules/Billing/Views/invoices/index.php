<div class="row mb-4">
    <div class="col-12 d-flex justify-content-between align-items-center">
        <h4 class="fw-bold tracking-tight mb-0">Invoices</h4>
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
                        <th>Client</th>
<th>Amount</th>
<th>Status</th>
<th>Due Date</th>

                        <th class="text-end pe-4">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if(!empty($invoices)): foreach($invoices as $row): ?>
                    <tr>
                        <td class="ps-4">#<?= htmlspecialchars($row['id'] ?? '') ?></td>
                        <td><?= htmlspecialchars($row['client_name'] ?? '') ?></td>
<td><?= htmlspecialchars($row['amount'] ?? '') ?></td>
<td><?= htmlspecialchars($row['status'] ?? '') ?></td>
<td><?= htmlspecialchars($row['due_date'] ?? '') ?></td>

                        <td class="text-end pe-4">                            <button onclick='openEditModal(<?= json_encode($row) ?>)' class="btn btn-sm btn-light text-primary me-1"><i class="fas fa-edit"></i></button>
                            <form method="POST" action="/billing/invoices/delete" class="d-inline">
                                <input type="hidden" name="id" value="<?= $row['id'] ?>">
                                <button type="submit" class="btn btn-sm btn-light text-danger" onclick="return confirm('Are you sure you want to delete this?')"><i class="fas fa-trash"></i></button>
                            </form></td>
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
        <form method="POST" action="/billing/invoices">
            <div class="modal-content border-0 shadow-lg">
                <div class="modal-header bg-light border-0">
                    <h5 class="modal-title fw-bold">Add Invoices</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    
                    <div class="mb-3">
                        <label class="form-label fw-bold">Client Name</label>
                        <input type="text" name="client_name" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Amount</label>
                        <input type="number" name="amount" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Status</label>
                        <input type="text" name="status" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Due Date</label>
                        <input type="date" name="due_date" class="form-control" required>
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
<div class="modal fade" id="editModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <form method="POST" action="/billing/invoices/update">
            <input type="hidden" name="id" id="edit_id">
            <div class="modal-content border-0 shadow-lg">
                <div class="modal-header bg-light border-0">
                    <h5 class="modal-title fw-bold">Edit Invoices</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    
                    <div class="mb-3">
                        <label class="form-label fw-bold">Client Name</label>
                        <input type="text" name="client_name" id="edit_client_name" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Amount</label>
                        <input type="number" name="amount" id="edit_amount" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Status</label>
                        <input type="text" name="status" id="edit_status" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Due Date</label>
                        <input type="date" name="due_date" id="edit_due_date" class="form-control" required>
                    </div>
                </div>
                <div class="modal-footer border-0 bg-light">
                    <button type="button" class="btn btn-link text-muted text-decoration-none" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary px-4">Update</button>
                </div>
            </div>
        </form>
    </div>
</div>
<script>
    function openEditModal(row) {
        document.getElementById('edit_id').value = row['id'];
        document.getElementById('edit_client_name').value = row['client_name'] || '';
            document.getElementById('edit_amount').value = row['amount'] || '';
            document.getElementById('edit_status').value = row['status'] || '';
            document.getElementById('edit_due_date').value = row['due_date'] || '';
            
        var editModal = new bootstrap.Modal(document.getElementById('editModal'));
        editModal.show();
    }
</script>