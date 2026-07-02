-- Core SaaS Tables
CREATE TABLE IF NOT EXISTS tenants (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(255) NOT NULL,
    subdomain VARCHAR(100) UNIQUE NOT NULL,
    plan VARCHAR(50) DEFAULT 'free',
    status VARCHAR(20) DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tenant_id INTEGER NULL, -- NULL if Super Admin
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'user',
    two_factor_secret VARCHAR(255) NULL,
    status VARCHAR(20) DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS user_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    expires_at DATETIME NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Insert Demo Data
INSERT OR IGNORE INTO tenants (id, name, subdomain, plan) VALUES (1, 'Acme Corp', 'acme', 'pro');
INSERT OR IGNORE INTO tenants (id, name, subdomain, plan) VALUES (2, 'Stark Industries', 'stark', 'enterprise');

-- Password is 'password123' (bcrypt hash)
INSERT OR IGNORE INTO users (id, tenant_id, first_name, last_name, email, password_hash, role) 
VALUES (1, 1, 'John', 'Doe', 'john@acme.com', '$2y$10$ADr2TWFDfWmdDmWEeC85BeQBOqaY7Suf7WOqNZ2AI7Slq3kS8Qceu', 'admin');

INSERT OR IGNORE INTO users (id, tenant_id, first_name, last_name, email, password_hash, role) 
VALUES (2, 2, 'Tony', 'Stark', 'tony@stark.com', '$2y$10$ADr2TWFDfWmdDmWEeC85BeQBOqaY7Suf7WOqNZ2AI7Slq3kS8Qceu', 'admin');
-- CRM Module
CREATE TABLE IF NOT EXISTS crm_leads (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tenant_id INTEGER NOT NULL,
    name VARCHAR(255) NOT NULL,
    company VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    source VARCHAR(50) DEFAULT 'Organic',
    expected_revenue DECIMAL(15,2) DEFAULT 0.00,
    stage VARCHAR(50) DEFAULT 'New',
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

-- Projects Module
CREATE TABLE IF NOT EXISTS projects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tenant_id INTEGER NOT NULL,
    name VARCHAR(255) NOT NULL,
    status VARCHAR(50) DEFAULT 'active',
    progress INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

-- HRM Module
CREATE TABLE IF NOT EXISTS employees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tenant_id INTEGER NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    department VARCHAR(100),
    role VARCHAR(100),
    status VARCHAR(50) DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

-- Accounting Module
CREATE TABLE IF NOT EXISTS accounts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tenant_id INTEGER NOT NULL,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL,
    balance DECIMAL(15,2) DEFAULT 0.00,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

-- Billing Module
CREATE TABLE IF NOT EXISTS invoices (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tenant_id INTEGER NOT NULL,
    client_name VARCHAR(255) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'unpaid',
    due_date DATE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

-- Inventory Module
CREATE TABLE IF NOT EXISTS products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tenant_id INTEGER NOT NULL,
    name VARCHAR(255) NOT NULL,
    sku VARCHAR(100),
    price DECIMAL(15,2) NOT NULL,
    stock INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

-- Hosting Module
CREATE TABLE IF NOT EXISTS hosting_accounts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tenant_id INTEGER NOT NULL,
    domain VARCHAR(255) NOT NULL,
    plan VARCHAR(100) NOT NULL,
    status VARCHAR(50) DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

-- Domains Module
CREATE TABLE IF NOT EXISTS domain_names (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tenant_id INTEGER NOT NULL,
    name VARCHAR(255) NOT NULL,
    registrar VARCHAR(100),
    expiry_date DATE,
    status VARCHAR(50) DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

-- DUMMY DATA FOR TENANT 1 (Acme Corp)
INSERT OR IGNORE INTO crm_leads (id, tenant_id, name, company, email, stage) VALUES 
(1, 1, 'Sarah Connor', 'Cyberdyne', 'sarah@cyberdyne.com', 'new'),
(2, 1, 'Bruce Wayne', 'Wayne Ent.', 'bruce@wayne.com', 'qualified');

INSERT OR IGNORE INTO projects (id, tenant_id, name, status, progress) VALUES 
(1, 1, 'Website Redesign', 'active', 45),
(2, 1, 'Mobile App Dev', 'active', 10);

INSERT OR IGNORE INTO employees (id, tenant_id, first_name, last_name, department, role) VALUES 
(1, 1, 'Alice', 'Smith', 'Engineering', 'Developer'),
(2, 1, 'Bob', 'Jones', 'Sales', 'Manager');

INSERT OR IGNORE INTO accounts (id, tenant_id, name, type, balance) VALUES 
(1, 1, 'Cash', 'asset', 50000.00),
(2, 1, 'Accounts Receivable', 'asset', 15000.00);

INSERT OR IGNORE INTO invoices (id, tenant_id, client_name, amount, status, due_date) VALUES 
(1, 1, 'Wayne Ent.', 5000.00, 'unpaid', '2026-08-01'),
(2, 1, 'Stark Ind.', 12000.00, 'paid', '2026-07-01');

INSERT OR IGNORE INTO products (id, tenant_id, name, sku, price, stock) VALUES 
(1, 1, 'Enterprise Server', 'SRV-001', 1500.00, 10),
(2, 1, 'Cloud Storage 1TB', 'CLD-1TB', 50.00, 999);

INSERT OR IGNORE INTO hosting_accounts (id, tenant_id, domain, plan, status) VALUES 
(1, 1, 'acme-corp.com', 'Business Pro', 'active');

INSERT OR IGNORE INTO domain_names (id, tenant_id, name, registrar, expiry_date, status) VALUES 
(1, 1, 'acme-corp.com', 'Namecheap', '2027-01-15', 'active');
