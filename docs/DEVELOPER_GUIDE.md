# Developer Guide: Building a New Module

To build a new module (e.g., `Marketing`), follow this exact sequence:

1. **Database Schema:** Create a migration file in `database/migrations/`.
2. **Directory Structure:** Create `modules/Marketing/` with folders for `Models`, `Repositories`, `Services`, `Controllers`, `Views`, and `Routes`.
3. **Model:** Create basic classes extending `App\Core\BaseModel`.
4. **Repository:** Write methods for any `INSERT`, `UPDATE`, or complex `SELECT` queries.
5. **Service:** Write the business logic. Pass the Repository into the Service via dependency injection.
6. **Controller:** Pass the Service into the Controller. Use `$this->view('campaigns/index', [], 'Marketing')` to render the view inside the global Master Layout.
7. **Routes:** Define the endpoints in `modules/Marketing/Routes/web.php`.
8. **UI Registration:** Add the module to the Sidebar array inside `app/Views/layouts/master.php`.
