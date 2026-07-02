<?php
namespace Modules\HRM\Services;
use Modules\HRM\Repositories\AttendanceRepository;
use Exception;

class TimeTrackingService {
    private AttendanceRepository $repo;
    public function __construct(AttendanceRepository $repo) { $this->repo = $repo; }

    public function clockIn(int $employeeId, string $ip): bool {
        return $this->repo->recordClockIn($employeeId, $ip);
    }
    
    public function clockOut(int $employeeId): bool {
        return $this->repo->recordClockOut($employeeId);
    }
}
