<?php
namespace Modules\Domains\Repositories;
use Modules\Domains\Models\Domain;
use PDO;

class DomainRepository {
    private Domain $model;
    public function __construct(Domain $model) { $this->model = $model; }

    public function getExpiringAssets(int $days = 30): array {
        $sql = "
            SELECT 'Domain' as type, d.domain_name as name, d.expiry_date, c.first_name, c.last_name
            FROM domains d
            JOIN contacts c ON d.contact_id = c.id
            WHERE d.expiry_date <= DATE_ADD(CURDATE(), INTERVAL ? DAY) AND d.status = 'active'
            
            UNION ALL
            
            SELECT 'SSL' as type, CONCAT(d.domain_name, ' (', s.provider, ')') as name, s.expiry_date, c.first_name, c.last_name
            FROM ssl_certificates s
            JOIN domains d ON s.domain_id = d.id
            JOIN contacts c ON d.contact_id = c.id
            WHERE s.expiry_date <= DATE_ADD(CURDATE(), INTERVAL ? DAY) AND s.status = 'active'
            
            ORDER BY expiry_date ASC
        ";
        $stmt = $this->model->getDb()->prepare($sql);
        $stmt->execute([$days, $days]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
