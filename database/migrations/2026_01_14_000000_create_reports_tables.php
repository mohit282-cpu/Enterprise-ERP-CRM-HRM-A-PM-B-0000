<?php
class CreateReportsTables {
    public function up($db) {
        $sql = "
        CREATE TABLE saved_reports (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            report_name VARCHAR(150) NOT NULL,
            module VARCHAR(50) NOT NULL,
            filter_json JSON,
            is_public BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
        ";
        $db->exec($sql);
    }
    public function down($db) {
        $db->exec("DROP TABLE IF EXISTS saved_reports;");
    }
}
