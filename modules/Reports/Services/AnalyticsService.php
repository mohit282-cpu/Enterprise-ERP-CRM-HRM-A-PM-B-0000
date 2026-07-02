<?php
namespace Modules\Reports\Services;
use Modules\Reports\Repositories\AnalyticsRepository;

class AnalyticsService {
    private AnalyticsRepository $repo;
    public function __construct(AnalyticsRepository $repo) { $this->repo = $repo; }

    public function getFinanceChartData(string $year): array {
        $data = $this->repo->getMonthlyRevenueVsExpenses($year);
        $labels = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        $revenue = array_fill(0, 12, 0);
        $expenses = array_fill(0, 12, 0);

        foreach ($data as $row) {
            $index = (int)$row['month'] - 1;
            $revenue[$index] = (float)$row['revenue'];
            $expenses[$index] = (float)$row['expense'];
        }

        return [
            'labels' => $labels,
            'datasets' => [
                ['name' => 'Revenue', 'data' => $revenue],
                ['name' => 'Expenses', 'data' => $expenses]
            ]
        ];
    }
}
