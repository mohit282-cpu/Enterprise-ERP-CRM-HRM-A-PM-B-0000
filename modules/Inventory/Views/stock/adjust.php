<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-body p-0">
                <div class="container mt-4">
        <h2>Manual Stock Adjustment</h2>
        <div class="card shadow-sm mt-4 p-4">
            <?php if(isset($_GET['success'])): ?>
                <div class="alert alert-success">Stock updated successfully via Immutable Ledger.</div>
            <?php endif; ?>
            <?php if(isset($error)): ?>
                <div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
            <?php endif; ?>
            
            <form method="POST">
                <div class="mb-3">
                    <label>Product ID / Barcode Scan</label>
                    <input type="number" name="product_id" class="form-control" required autofocus>
                </div>
                <div class="mb-3">
                    <label>Warehouse ID</label>
                    <input type="number" name="warehouse_id" class="form-control" required>
                </div>
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label>Movement Type</label>
                        <select name="type" class="form-select">
                            <option value="in">Add (Stock In)</option>
                            <option value="out">Deduct (Stock Out)</option>
                        </select>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label>Quantity</label>
                        <input type="number" step="0.01" name="quantity" class="form-control" required>
                    </div>
                </div>
                <button type="submit" class="btn btn-primary">Commit Adjustment</button>
            </form>
        </div>
    </div>
            </div>
        </div>
    </div>
</div>