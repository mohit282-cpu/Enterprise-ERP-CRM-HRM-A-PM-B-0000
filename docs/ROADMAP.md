# Project Roadmap

This document outlines the strategic vision and feature release schedule for **Sovryx OS**. Our roadmap is divided into major version milestones to ensure stable, incremental, and highly tested delivery of enterprise features.

---

## 🚀 Version 1.0 (MVP & Core Foundation)
*Status: Completed & Stable*

The initial release focuses on establishing the core architecture and essential business modules required to operate an IT company or agency.

- [x] **Authentication & RBAC:** Secure login, password hashing, and granular role permissions.
- [x] **Executive Dashboard:** High-level metrics, revenue charts, and quick actions.
- [x] **CRM (Basic):** Lead capture, client management, and contact logs.
- [x] **Billing Engine:** Quotations, dynamic invoice generation, and PDF export (Dompdf).
- [x] **Accounting (Core):** Basic revenue and expense tracking, Profit & Loss overview.
- [x] **Project Management:** Project creation, milestones, and task assignments.
- [x] **Client Portal:** Secure area for clients to view invoices and project statuses.
- [x] **Notifications:** In-app alerts and email integrations via PHPMailer.
- [x] **REST API (v1):** Core endpoints for authentication and client management.

---

## ⚡ Version 1.5 (Operations & HR Expansion)
*Status: In Development*

Version 1.5 expands the system into a true ERP by introducing internal operations management and advanced client communication channels.

- [ ] **HRM Module:** Employee profiles, department mapping, and organizational charts.
- [ ] **Attendance & Payroll:** Daily clock-in/out, leave requests, and automated payslip generation.
- [ ] **Hosting & Domain Management:** Specialized trackers for IT agencies to monitor client server renewals.
- [ ] **Omnichannel Notifications:** WhatsApp Business API integration for instant client billing alerts.
- [ ] **Support Desk:** Ticket system for clients to report issues directly into the CRM.
- [ ] **Document Management:** Centralized secure file storage for client contracts and NDAs.
- [ ] **Advanced Accounting:** Full double-entry ledger, Chart of Accounts, and Cash Flow statements.

---

## 🧠 Version 2.0 (The AI Upgrade & Automation)
*Status: Planned*

This version integrates artificial intelligence directly into the business workflows to drastically reduce manual data entry and administrative overhead.

- [ ] **AI Assistant Integration:** Native integration with OpenAI for smart text generation.
- [ ] **AI Proposal Generator:** Generate full scopes of work from brief text prompts.
- [ ] **AI Email Writer:** Context-aware email drafting directly inside the CRM.
- [ ] **Workflow Automations:** Zapier-like internal triggers (e.g., "If Invoice is Paid, change Project Status to In Progress").
- [ ] **Inventory Management:** Track physical IT assets (laptops, servers) assigned to employees.
- [ ] **Vendor Procurement:** Purchase orders and vendor bill management.
- [ ] **Knowledge Base:** Internal wikis and client-facing help articles.

---

## 🌍 Version 3.0 (Enterprise Scaling & Marketplace)
*Status: Future Vision*

Version 3.0 prepares Sovryx OS for massive scale, supporting conglomerates, multi-branch setups, and third-party extensions.

- [ ] **Multi-Company / Multi-Branch:** Manage multiple distinct legal entities from one super-admin dashboard.
- [ ] **Multi-Currency & Multi-Language:** Full internationalization (i18n) support.
- [ ] **Plugin & Module Marketplace:** An ecosystem allowing developers to build and sell add-ons for Sovryx OS.
- [ ] **Training Institute Module:** specialized tools for scheduling classes, managing students, and issuing certificates.
- [ ] **SaaS Management:** Tracking API usage, subscription tiers, and tenant billing for software products.
- [ ] **GraphQL API:** Implement a GraphQL layer alongside the standard REST API for flexible data querying.

---

## 📱 Version 5.0 (The Ecosystem)
*Status: Long-term Vision*

The ultimate form of Sovryx OS extending beyond the web browser.

- [ ] **Native Mobile Application:** iOS and Android apps built with React Native or Flutter, communicating via the REST API.
- [ ] **Desktop Application:** Electron-based offline-capable desktop client for heavy power users.
- [ ] **Voice Assistant Integration:** "Hey Sovryx, what is the MRR for this month?"
- [ ] **OCR Invoice Scanner:** AI-powered scanning of physical receipts and vendor invoices straight into the accounting ledger.
- [ ] **Advanced Business Intelligence (BI):** Deep machine learning analytics predicting cash flow shortages and client churn.
