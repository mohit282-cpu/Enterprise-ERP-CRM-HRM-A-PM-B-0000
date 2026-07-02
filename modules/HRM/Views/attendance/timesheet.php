<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-body p-0">
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
            </div>
        </div>
    </div>
</div>