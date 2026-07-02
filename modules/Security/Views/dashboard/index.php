<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Security Center</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container mt-4">
        <h2>Enterprise Security Center</h2>
        <div class="row mt-4">
            <div class="col-md-4">
                <div class="card text-white bg-danger mb-3">
                    <div class="card-header">Failed Logins (24h)</div>
                    <div class="card-body">
                        <h4 class="card-title">12</h4>
                        <p class="card-text">From 3 unique IP addresses.</p>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card text-white bg-success mb-3">
                    <div class="card-header">System Integrity</div>
                    <div class="card-body">
                        <h4 class="card-title">SECURE</h4>
                        <p class="card-text">CSRF & XSS protections active.</p>
                    </div>
                </div>
            </div>
        </div>
        <a href="/security/audit-logs" class="btn btn-primary">View Global Audit Logs</a>
    </div>
</body>
</html>
