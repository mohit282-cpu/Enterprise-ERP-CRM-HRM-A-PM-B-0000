<?php
namespace Modules\HRM\Repositories;
use Modules\HRM\Models\Attendance;
use PDO;

class AttendanceRepository {
    private Attendance $model;
    public function __construct(Attendance $model) { $this->model = $model; }

    public function recordClockIn(int $employeeId, string $ip): bool {
        $date = date('Y-m-d');
        $time = date('Y-m-d H:i:s');
        
        $stmt = $this->model->getDb()->prepare("
            INSERT INTO attendances (employee_id, date, clock_in, location_ip) 
            VALUES (?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE clock_in = IF(clock_in IS NULL, VALUES(clock_in), clock_in)
        ");
        return $stmt->execute([$employeeId, $date, $time, $ip]);
    }

    public function recordClockOut(int $employeeId): bool {
        $date = date('Y-m-d');
        $time = date('Y-m-d H:i:s');
        
        // Complex update calculating total hours in SQL
        $stmt = $this->model->getDb()->prepare("
            UPDATE attendances 
            SET clock_out = ?, total_hours = TIMESTAMPDIFF(MINUTE, clock_in, ?) / 60 
            WHERE employee_id = ? AND date = ? AND clock_out IS NULL
        ");
        return $stmt->execute([$time, $time, $employeeId, $date]);
    }
}
