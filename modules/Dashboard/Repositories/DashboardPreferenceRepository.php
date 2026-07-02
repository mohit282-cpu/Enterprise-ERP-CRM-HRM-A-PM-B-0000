<?php
namespace Modules\Dashboard\Repositories;

use Modules\Dashboard\Models\DashboardPreference;
use PDO;

class DashboardPreferenceRepository {
    private DashboardPreference $model;
    public function __construct(DashboardPreference $model) {
        $this->model = $model;
    }
    
    public function getUserPreferences(int $userId): ?array {
        $stmt = $this->model->getDb()->prepare("SELECT * FROM {$this->model->getTable()} WHERE user_id = ? LIMIT 1");
        $stmt->execute([$userId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }
    
    public function savePreferences(int $userId, string $configJson, string $theme = 'light'): void {
        $stmt = $this->model->getDb()->prepare("
            INSERT INTO {$this->model->getTable()} (user_id, widget_config, theme) 
            VALUES (?, ?, ?) 
            ON DUPLICATE KEY UPDATE widget_config = VALUES(widget_config), theme = VALUES(theme)
        ");
        $stmt->execute([$userId, $configJson, $theme]);
    }
}
