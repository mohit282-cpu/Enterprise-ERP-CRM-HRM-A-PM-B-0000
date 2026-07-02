<?php
class CreatePmTables {
    public function up($db) {
        $sql = "
        CREATE TABLE milestones (
            id INT AUTO_INCREMENT PRIMARY KEY,
            project_id INT NOT NULL,
            name VARCHAR(255) NOT NULL,
            description TEXT,
            due_date DATE,
            status ENUM('pending', 'in_progress', 'completed') DEFAULT 'pending',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
        );

        -- Add structural columns to tasks
        ALTER TABLE tasks ADD COLUMN parent_id INT NULL AFTER project_id;
        ALTER TABLE tasks ADD COLUMN milestone_id INT NULL AFTER parent_id;
        ALTER TABLE tasks ADD COLUMN progress TINYINT DEFAULT 0 AFTER status;
        ALTER TABLE tasks ADD COLUMN estimated_hours DECIMAL(5,2) DEFAULT 0.00;
        
        ALTER TABLE tasks ADD CONSTRAINT fk_task_parent FOREIGN KEY (parent_id) REFERENCES tasks(id) ON DELETE CASCADE;
        ALTER TABLE tasks ADD CONSTRAINT fk_task_milestone FOREIGN KEY (milestone_id) REFERENCES milestones(id) ON DELETE SET NULL;

        CREATE TABLE task_comments (
            id INT AUTO_INCREMENT PRIMARY KEY,
            task_id INT NOT NULL,
            user_id INT NOT NULL,
            comment TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );

        CREATE TABLE project_files (
            id INT AUTO_INCREMENT PRIMARY KEY,
            project_id INT NOT NULL,
            task_id INT NULL,
            user_id INT NOT NULL,
            file_name VARCHAR(255) NOT NULL,
            file_path VARCHAR(255) NOT NULL,
            file_size INT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
            FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
        ";
        $db->exec($sql);
    }
    public function down($db) {
        $db->exec("
            DROP TABLE IF EXISTS project_files, task_comments;
            ALTER TABLE tasks DROP FOREIGN KEY fk_task_parent;
            ALTER TABLE tasks DROP FOREIGN KEY fk_task_milestone;
            ALTER TABLE tasks DROP COLUMN parent_id, DROP COLUMN milestone_id, DROP COLUMN progress, DROP COLUMN estimated_hours;
            DROP TABLE IF EXISTS milestones;
        ");
    }
}
