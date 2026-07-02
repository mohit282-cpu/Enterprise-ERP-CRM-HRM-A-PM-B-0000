<?php
class CreateApiTables {
    public function up($db) {
        $sql = "
        CREATE TABLE api_keys (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            name VARCHAR(100) NOT NULL,
            api_key VARCHAR(128) NOT NULL UNIQUE,
            last_used_at TIMESTAMP NULL,
            expires_at TIMESTAMP NULL,
            is_active BOOLEAN DEFAULT TRUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
        ";
        $db->exec($sql);
    }
    public function down($db) {
        $db->exec("DROP TABLE IF EXISTS api_keys;");
    }
}
