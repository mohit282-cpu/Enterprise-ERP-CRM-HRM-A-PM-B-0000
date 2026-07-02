<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Register - Sovryx OS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex align-items-center py-4">
    <main class="form-signin w-100 m-auto" style="max-width: 400px;">
        <form method="POST" action="/register">
            <h1 class="h3 mb-3 fw-normal text-center">Register Account</h1>
            
            <input type="hidden" name="csrf_token" value="<?= $_SESSION['csrf_token'] ?? '' ?>">
            
            <div class="form-floating mb-2">
                <input type="text" name="first_name" class="form-control" required>
                <label>First Name</label>
            </div>
            <div class="form-floating mb-2">
                <input type="text" name="last_name" class="form-control" required>
                <label>Last Name</label>
            </div>
            <div class="form-floating mb-2">
                <input type="email" name="email" class="form-control" required>
                <label>Email address</label>
            </div>
            <div class="form-floating mb-2">
                <input type="password" name="password" class="form-control" required>
                <label>Password</label>
            </div>
            <div class="form-floating mb-3">
                <input type="password" name="password_confirm" class="form-control" required>
                <label>Confirm Password</label>
            </div>

            <button class="w-100 btn btn-lg btn-success" type="submit">Register</button>
        </form>
    </main>
</body>
</html>
