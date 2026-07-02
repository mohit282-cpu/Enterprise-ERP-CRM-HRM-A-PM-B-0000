# Frequently Asked Questions (FAQ)

Find answers to common questions about **Sovryx OS** below. If your question isn't answered here, please refer to the [Troubleshooting Guide](TROUBLESHOOTING.md) or open a support ticket.

---

## 🏢 General

### 1. What is Sovryx OS?
Sovryx OS is an all-in-one Enterprise Business Operating System. It combines CRM, ERP, Accounting, HR, Project Management, and IT Operations into a single, unified platform to run your entire company.

### 2. Who is this software for?
While it can be used by any SME, it is specifically optimized for **IT Companies, Web Agencies, and Hosting Providers**. Modules like Domain Tracking, Server Asset Management, and SaaS management are tailor-made for the tech industry.

### 3. Is Sovryx OS open-source?
The core framework is available under the MIT License, meaning you can self-host and modify it. However, certain advanced enterprise modules and the official SaaS cloud offering are proprietary. Please check the [LICENSE](LICENSE) file for exact details.

---

## 💻 Technical & Hosting

### 4. Can I host Sovryx OS on shared hosting (cPanel)?
Yes. Sovryx OS is built on modern PHP 8.3 and MySQL, meaning it can run on most standard cPanel shared hosting environments. However, for enterprise scale (100+ employees), we highly recommend a VPS (Ubuntu/Nginx) for better performance and control over cron jobs.

### 5. Does Sovryx OS support multi-tenancy?
The standard version is a single-tenant architecture designed for one company. Version 3.0 (on the [Roadmap](ROADMAP.md)) will introduce full SaaS multi-tenancy capabilities.

### 6. Are my API Keys (OpenAI, WhatsApp) secure?
Yes. API keys are stored exclusively in the `.env` file on your server. They are never exposed to the frontend, never stored in the database, and never sent to our servers.

---

## ⚙️ Usage & Features

### 7. How do I enable Dark Mode?
Click your profile avatar in the top right corner of the dashboard and toggle the **Dark Mode** switch. This setting is saved in your browser's local storage.

### 8. The AI features are not working. Why?
You must obtain an API Key from OpenAI and save it in your `.env` file under `OPENAI_API_KEY`. Ensure your OpenAI account has billing enabled, as their API is not free.

### 9. Can clients pay invoices directly through the portal?
Yes, if you configure a payment gateway (e.g., Stripe, PayPal, Razorpay) in the Admin Settings. Once configured, a "Pay Now" button will appear on client invoices.

### 10. Can I translate the system into my local language?
Yes. Sovryx OS supports i18n. You can duplicate the `resources/lang/en` folder, rename it (e.g., `es` for Spanish), translate the JSON strings, and change the default language in the Global Settings.
