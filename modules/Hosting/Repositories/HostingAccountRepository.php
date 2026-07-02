<?php
namespace Modules\Hosting\Repositories;
use Modules\Hosting\Models\HostingAccount;
use PDO;

class HostingAccountRepository {
    private HostingAccount $model;
    public function __construct(HostingAccount $model) { $this->model = $model; }

    public function getAccountsPendingRenewal(): array {
        // Fetch accounts where renewal is within the next 30 days or overdue
        $sql = "
            SELECT a.*, c.first_name, c.last_name, c.email, p.name as plan_name, p.annual_price 
            FROM hosting_accounts a
            JOIN contacts c ON a.contact_id = c.id
            JOIN hosting_plans p ON a.hosting_plan_id = p.id
            WHERE a.next_renewal_date <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)
            AND a.status = 'active'
            ORDER BY a.next_renewal_date ASC
        ";
        $stmt = $this->model->getDb()->query($sql);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function createAccount(array $data): int {
        $stmt = $this->model->getDb()->prepare("
            INSERT INTO hosting_accounts (contact_id, server_id, hosting_plan_id, domain_name, username, next_renewal_date, status)
            VALUES (?, ?, ?, ?, ?, ?, 'active')
        ");
        $stmt->execute([
            $data['contact_id'], $data['server_id'], $data['hosting_plan_id'],
            $data['domain_name'], $data['username'], $data['next_renewal_date']
        ]);
        return (int)$this->model->getDb()->lastInsertId();
    }
}
