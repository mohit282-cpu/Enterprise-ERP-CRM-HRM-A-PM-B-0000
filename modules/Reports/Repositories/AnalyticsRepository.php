<?php
namespace Modules\Reports\Repositories;
use App\Core\Database;
use PDO;

class AnalyticsRepository {
    private PDO $db;
    public function __construct() { $this->db = Database::getInstance()->getConnection(); }

    public function getMonthlyRevenueVsExpenses(string $year): array {
        $sql = "
            SELECT 
                MONTH(je.entry_date) as month,
                SUM(IF(a.type = 'revenue', jel.credit - jel.debit, 0)) as revenue,
                SUM(IF(a.type = 'expense', jel.debit - jel.credit, 0)) as expense
            FROM journal_entries je
            JOIN journal_entry_lines jel ON je.id = jel.journal_entry_id
            JOIN chart_of_accounts a ON jel.account_id = a.id
            WHERE YEAR(je.entry_date) = ? AND je.status = 'posted'
            GROUP BY MONTH(je.entry_date)
            ORDER BY MONTH(je.entry_date)
        ";
        $stmt = $this->db->prepare($sql);
        $stmt->execute([$year]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getSalesPipelineMetrics(): array {
        $sql = "SELECT status, COUNT(*) as total, SUM(estimated_value) as value FROM leads GROUP BY status";
        $stmt = $this->db->query($sql);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getInventoryValuation(): array {
        $sql = "
            SELECT w.name as warehouse, SUM(s.quantity * p.cost_price) as total_value
            FROM inventory_stock s
            JOIN products p ON s.product_id = p.id
            JOIN warehouses w ON s.warehouse_id = w.id
            GROUP BY w.id
        ";
        $stmt = $this->db->query($sql);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
