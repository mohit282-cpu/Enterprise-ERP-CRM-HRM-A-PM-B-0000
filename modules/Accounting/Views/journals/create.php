<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-body p-0">
                <div class="container mt-4">
        <h2>Create Journal Entry</h2>
        <?php if(isset($error)): ?>
            <div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
        <?php endif; ?>
        <form method="POST">
            <!-- Dynamic JS line items go here for debit/credit -->
            <button type="submit" class="btn btn-primary">Post Entry</button>
        </form>
    </div>
            </div>
        </div>
    </div>
</div>