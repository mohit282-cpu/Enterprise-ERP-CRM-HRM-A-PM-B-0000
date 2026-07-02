<?php
namespace Modules\Dashboard\Services;

class DashboardService {
    
    public function getKpiStats(): array {
        // Mock data until CRM & Accounting are built
        return [
            'total_revenue' => 145000.50,
            'active_users' => 42,
            'open_leads' => 18,
            'pending_tasks' => 7
        ];
    }
    
    public function getRevenueChartData(): array {
        // Mock series data for ApexCharts
        return [
            'categories' => ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
            'series' => [
                ['name' => 'Revenue', 'data' => [30000, 40000, 35000, 50000, 49000, 60000]],
                ['name' => 'Expenses', 'data' => [23000, 26000, 21000, 30000, 25000, 31000]]
            ]
        ];
    }
    
    public function getRecentActivity(): array {
        // Mock data until activity logs are fully wired
        return [
            ['action' => 'Invoice #INV-0012 Paid', 'time' => '10 mins ago'],
            ['action' => 'New Lead: John Doe', 'time' => '1 hour ago'],
            ['action' => 'Project Alpha Completed', 'time' => '3 hours ago']
        ];
    }
}
