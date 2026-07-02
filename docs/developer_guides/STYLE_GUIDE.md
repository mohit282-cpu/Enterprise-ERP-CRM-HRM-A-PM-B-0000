# Style Guide

This document outlines the UI/UX conventions, CSS architecture, and component usage for **Sovryx OS**. Consistency in design is vital for an enterprise application to reduce cognitive load on users.

---

## 🎨 1. Design Philosophy

- **Professional & Modern:** Clean lines, ample whitespace, and high contrast.
- **Data-Dense but Readable:** ERP systems display a lot of data. Use tables effectively without overwhelming the user.
- **Accessible:** Ensure sufficient color contrast and keyboard navigability.
- **Responsive:** The UI must function perfectly on desktop, tablet, and mobile.

---

## 🛠 2. Core Frontend Stack

- **Framework:** Bootstrap 5 (Customized)
- **Icons:** FontAwesome 6 (or Bootstrap Icons)
- **Typography:** 'Inter' (Primary UI) and 'Roboto Mono' (for code/numbers).

---

## 🖌 3. Color Palette

Use CSS variables defined in `:root` for all coloring to support Dark Mode seamlessly.

| Variable Name | Hex Code | Usage |
| :--- | :--- | :--- |
| `--sov-primary` | `#0d6efd` | Primary buttons, active links, highlights. |
| `--sov-secondary` | `#6c757d` | Secondary text, inactive states. |
| `--sov-success` | `#198754` | Paid invoices, completed tasks, success alerts. |
| `--sov-danger` | `#dc3545` | Overdue invoices, deletion actions, errors. |
| `--sov-warning` | `#ffc107` | Pending statuses, warning alerts. |
| `--sov-bg-light` | `#f8f9fa` | Default background for the application. |
| `--sov-bg-dark` | `#212529` | Background for dark mode. |

---

## 📦 4. Component Guidelines

### Buttons
- Primary action on a page (e.g., "Create Invoice") uses `.btn-primary`.
- Secondary actions (e.g., "Cancel", "Back") use `.btn-outline-secondary`.
- Destructive actions (e.g., "Delete Client") use `.btn-danger`.

### DataTables
- Use the standard Bootstrap styling for DataTables.
- Always include search and pagination.
- Right-align numerical columns (currency, quantities).
- Center-align status badges and action buttons.

### Badges
Use Bootstrap badges to indicate status clearly.
```html
<span class="badge bg-success">Paid</span>
<span class="badge bg-warning text-dark">Pending</span>
<span class="badge bg-danger">Overdue</span>
```

### Alerts & Notifications
- **Flash Messages:** Use Bootstrap `.alert` for inline page messages.
- **Interactive Alerts:** Use **SweetAlert2** for confirmations (e.g., "Are you sure you want to delete this project?"). Do not use standard javascript `confirm()`.

---

## 📊 5. Charts & Analytics (ApexCharts)

All charts use **ApexCharts.js** for interactive, SVG-based rendering.
- Ensure tooltips are enabled.
- Use the official `--sov-primary` and `--sov-success` colors in the chart series arrays to maintain brand consistency.
- Make charts responsive by setting width to `100%`.

---

## 🌗 6. Dark Mode

Sovryx OS supports a system-wide Dark Mode.
- Do not hardcode HEX colors in CSS classes.
- Always use CSS variables (e.g., `background-color: var(--sov-bg-light)`).
- When the dark mode toggle is activated, JavaScript will append a `data-theme="dark"` attribute to the `<html>` tag, which overrides the CSS variables to their dark variants.
