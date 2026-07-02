<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Dashboard - Sovryx OS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/assets/css/dashboard.css">
</head>
<body class="bg-light">
    
    <!-- Top Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4">
        <div class="container-fluid">
            <a class="navbar-brand" href="/dashboard">Sovryx OS</a>
            <div class="d-flex">
                <a href="/logout" class="btn btn-outline-light btn-sm">Logout</a>
            </div>
        </div>
    </nav>

    <div class="container-fluid px-4">
        <h2 class="mb-4">Overview Dashboard</h2>
        
        <!-- KPI Cards Widget -->
        <?php include 'widgets/kpi-cards.php'; ?>

        <div class="row mt-4">
            <!-- Main Chart Widget -->
            <div class="col-lg-8">
                <div class="card shadow-sm">
                    <div class="card-header bg-white">
                        <h5 class="mb-0">Revenue vs Expenses</h5>
                    </div>
                    <div class="card-body">
                        <div id="revenueChart"></div>
                    </div>
                </div>
            </div>
            
            <!-- Recent Activity Widget -->
            <div class="col-lg-4">
                <?php include 'widgets/recent-activity.php'; ?>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>
    <script src="/assets/js/dashboard.js"></script>
</body>
</html>
