<div class="row">
    <div class="col-xl-3 col-md-6 mb-4">
        <div class="card border-left-primary shadow-sm h-100 py-2">
            <div class="card-body">
                <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">Total Revenue</div>
                <div class="h5 mb-0 font-weight-bold text-gray-800">$<?= number_format($kpi['total_revenue'], 2) ?></div>
            </div>
        </div>
    </div>
    <div class="col-xl-3 col-md-6 mb-4">
        <div class="card border-left-success shadow-sm h-100 py-2">
            <div class="card-body">
                <div class="text-xs font-weight-bold text-success text-uppercase mb-1">Active Users</div>
                <div class="h5 mb-0 font-weight-bold text-gray-800"><?= $kpi['active_users'] ?></div>
            </div>
        </div>
    </div>
    <div class="col-xl-3 col-md-6 mb-4">
        <div class="card border-left-warning shadow-sm h-100 py-2">
            <div class="card-body">
                <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">Open Leads</div>
                <div class="h5 mb-0 font-weight-bold text-gray-800"><?= $kpi['open_leads'] ?></div>
            </div>
        </div>
    </div>
    <div class="col-xl-3 col-md-6 mb-4">
        <div class="card border-left-danger shadow-sm h-100 py-2">
            <div class="card-body">
                <div class="text-xs font-weight-bold text-danger text-uppercase mb-1">Pending Tasks</div>
                <div class="h5 mb-0 font-weight-bold text-gray-800"><?= $kpi['pending_tasks'] ?></div>
            </div>
        </div>
    </div>
</div>
