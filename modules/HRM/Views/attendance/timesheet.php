<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Timesheet - HRM</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container mt-4">
        <h2>My Timesheet</h2>
        <div class="mb-4">
            <button class="btn btn-success" onclick="clockIn()">Clock In</button>
            <button class="btn btn-danger" onclick="clockOut()">Clock Out</button>
        </div>
        <!-- Timesheet Table goes here -->
    </div>
    <script>
        function clockIn() {
            fetch('/api/hrm/clock-in', {method:'POST'}).then(r=>r.json()).then(console.log);
        }
        function clockOut() {
            fetch('/api/hrm/clock-out', {method:'POST'}).then(r=>r.json()).then(console.log);
        }
    </script>
</body>
</html>
