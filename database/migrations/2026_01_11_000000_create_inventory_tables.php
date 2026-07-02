<?php
class CreateInventoryTables {
    public function up($db) {
        $sql = "
        -- Drop basic operational tables if they exist to replace with Enterprise logic
        DROP TABLE IF EXISTS inventory_transactions, products, product_categories;

        CREATE TABLE warehouses (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            location VARCHAR(255),
            is_active BOOLEAN DEFAULT TRUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE suppliers (
            id INT AUTO_INCREMENT PRIMARY KEY,
            company_name VARCHAR(150) NOT NULL,
            contact_name VARCHAR(100),
            email VARCHAR(100),
            phone VARCHAR(50),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE product_categories (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            parent_id INT NULL,
            FOREIGN KEY (parent_id) REFERENCES product_categories(id) ON DELETE SET NULL
        );

        CREATE TABLE products (
            id INT AUTO_INCREMENT PRIMARY KEY,
            category_id INT NULL,
            supplier_id INT NULL,
            name VARCHAR(255) NOT NULL,
            sku VARCHAR(100) NOT NULL UNIQUE,
            barcode VARCHAR(100) UNIQUE,
            qr_code VARCHAR(255),
            cost_price DECIMAL(15,4) NOT NULL DEFAULT 0.0000,
            selling_price DECIMAL(15,4) NOT NULL DEFAULT 0.0000,
            is_active BOOLEAN DEFAULT TRUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (category_id) REFERENCES product_categories(id) ON DELETE SET NULL,
            FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE SET NULL
        );

        CREATE TABLE inventory_stock (
            id INT AUTO_INCREMENT PRIMARY KEY,
            product_id INT NOT NULL,
            warehouse_id INT NOT NULL,
            quantity DECIMAL(15,4) NOT NULL DEFAULT 0.0000,
            last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
            FOREIGN KEY (warehouse_id) REFERENCES warehouses(id) ON DELETE CASCADE,
            UNIQUE KEY product_warehouse (product_id, warehouse_id)
        );

        CREATE TABLE stock_movements (
            id INT AUTO_INCREMENT PRIMARY KEY,
            product_id INT NOT NULL,
            warehouse_id INT NOT NULL,
            user_id INT NOT NULL,
            type ENUM('in', 'out', 'transfer') NOT NULL,
            quantity DECIMAL(15,4) NOT NULL,
            reference_type VARCHAR(50), -- e.g., 'purchase_order', 'manual_adjustment'
            reference_id INT,
            notes TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT,
            FOREIGN KEY (warehouse_id) REFERENCES warehouses(id) ON DELETE RESTRICT,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT
        );
        ";
        $db->exec($sql);
    }
    public function down($db) {
        $db->exec("DROP TABLE IF EXISTS stock_movements, inventory_stock, products, product_categories, suppliers, warehouses;");
    }
}
