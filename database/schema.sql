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