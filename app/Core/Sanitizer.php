<?php
namespace App\Core;

class Sanitizer {
    /**
     * Prevent XSS by aggressively escaping HTML entities
     */
    public static function escape(string $input): string {
        return htmlspecialchars(trim($input), ENT_QUOTES | ENT_HTML5, 'UTF-8');
    }

    /**
     * Sanitize array (e.g. $_POST)
     */
    public static function escapeArray(array $inputs): array {
        $clean = [];
        foreach ($inputs as $key => $value) {
            if (is_array($value)) {
                $clean[$key] = self::escapeArray($value);
            } else {
                $clean[$key] = self::escape((string)$value);
            }
        }
        return $clean;
    }
}
