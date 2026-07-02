# 📊 Dashboard & Analytics Module

## 1. Business Overview
The Dashboard module acts as the nerve center for Sovryx OS. It provides real-time, aggregated data visualization across all enterprise departments. It allows executives and managers to make instant, data-driven decisions regarding cash flow, project health, and employee productivity without having to dig through dense reports.

## 2. User Story
- **As a CEO**, I want to see a high-level overview of revenue, expenses, and pending invoices on a single screen using beautiful charts.
- **As a Project Manager**, I want a localized dashboard showing my active projects, looming deadlines, and team task completion rates.

## 3. Database Design
The dashboard primarily reads from existing tables (Invoices, Projects, HR). However, for extreme performance, a caching table is used for expensive aggregations.
**Tables:**
- `dashboard_widgets`: `id`, `user_id`, `widget_type`, `position_order`, `settings_json` (Stores user customization).
- `analytics_cache`: `id`, `metric_key` (e.g., `monthly_revenue_oct`), `metric_value`, `expires_at`.

## 4. Folder Structure
```text
modules/Dashboard/
├── Controllers/
│   └── DashboardController.php
├── Services/
│   ├── FinanceAnalyticsService.php
│   └── ProjectAnalyticsService.php
├── Repositories/
│   └── WidgetRepository.php
├── Routes/
│   └── web.php
└── Views/
    ├── widgets/
    │   ├── revenue_chart.php
    │   └── active_projects.php
    └── index.php
```

## 5. Controllers
- `DashboardController`: Determines the user's role and fetches the appropriate aggregate data. Returns the assembled View.

## 6. Models
- `DashboardWidget`: Represents user-specific widget layouts.

## 7. Services
- `FinanceAnalyticsService`: Executes complex grouping queries (e.g., `SUM(total) GROUP BY month`) to calculate Cash Flow and Profit margins.
- Handles caching logic to prevent overloading the database on every page load.

## 8. Repository
- `WidgetRepository`: Fetches and saves the customized layout preferences of the active user.

## 9. Routes
**Web (`routes/web.php`):**
- `GET /dashboard`
- `POST /dashboard/widgets/reorder` (AJAX route to save drag-and-drop state)

## 10. Views
- `index.php`: The main grid layout utilizing Bootstrap 5 CSS Grid or Flexbox.
- `widgets/*.php`: Individual reusable HTML partials containing ApexCharts instances or summary cards.

## 11. API Endpoints
- `GET /api/v1/dashboard/metrics` - Returns JSON payloads for mobile app dashboards.

## 12. Validation
- Reordering widgets requires validating an array of widget IDs (`widget_ids.* : integer|exists:dashboard_widgets,id`).

## 13. Permissions
- `view_finance_dashboard`: Restricted to Admins and Accountants.
- `view_project_dashboard`: Restricted to Project Managers.

## 14. Workflow
1. User hits `/dashboard`.
2. `DashboardController` checks active Role.
3. Controller delegates to `AnalyticsServices` to fetch data.
4. Service checks Redis/File cache. If miss, queries database and caches result for 15 minutes.
5. Controller renders `index.php`, passing data to Javascript for ApexCharts initialization.

## 15. UI Components
- **ApexCharts:** Dynamic SVG charts for Revenue Area Graphs, Expense Donut Charts.
- **Stat Cards:** Bootstrap Cards with FontAwesome icons (e.g., Green arrow up for profit increase).
- **Draggable Grid:** (Using SortableJS) allowing users to drag and customize widget positions.

## 16. Security
- Strict RBAC enforcement ensures an Employee cannot manipulate the DOM/API to view the CEO Finance Dashboard.
- Output escaping ensures widget names/settings cannot trigger XSS.

## 17. Testing
- **Unit Tests:** Mock the database and ensure `FinanceAnalyticsService` accurately calculates P&L based on known dummy inputs.
- **Integration Tests:** Ensure `/dashboard` returns HTTP 403 if an unauthorized user attempts to access restricted widget routes.

## 18. Future Improvements
- Implement WebSocket broadcasting so the dashboard charts update in absolute real-time (e.g., an invoice is paid, and the revenue chart ticks up instantly without refreshing).
- Custom Widget Builder allowing users to write basic SQL (safely abstracted) to create custom metrics.
