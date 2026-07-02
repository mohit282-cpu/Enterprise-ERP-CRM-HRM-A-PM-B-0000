<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Master Reports Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>
</head>
<body class="bg-light">
    <div class="container-fluid mt-4 px-4">
        <h2>Enterprise Reports Hub</h2>
        
        <div class="row mt-4">
            <div class="col-md-8">
                <div class="card shadow-sm p-4">
                    <h5>Revenue vs Expenses (Live Ledger Sync)</h5>
                    <div id="financeChart"></div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card shadow-sm p-4">
                    <h5>Export Options (Phase 2)</h5>
                    <button class="btn btn-outline-danger w-100 mb-2">Export to PDF</button>
                    <button class="btn btn-outline-success w-100">Export to Excel</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener("DOMContentLoaded", function() {
            fetch('/api/reports/finance?year=' + new Date().getFullYear())
                .then(r => r.json())
                .then(data => {
                    var options = {
                        series: data.datasets,
                        chart: { type: 'area', height: 350 },
                        xaxis: { categories: data.labels },
                        colors: ['#28a745', '#dc3545']
                    };
                    var chart = new ApexCharts(document.querySelector("#financeChart"), options);
                    chart.render();
                });
        });
    </script>
</body>
</html>
