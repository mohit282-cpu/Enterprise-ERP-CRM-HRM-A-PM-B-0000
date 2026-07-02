<?php
namespace Modules\Domains\Services;

class DomainService {
    
    /**
     * Aggressively strip protocols, paths, and www to get the bare domain.
     */
    public function sanitizeDomainName(string $input): string {
        $input = trim($input);
        // Remove http/https
        $input = preg_replace('#^https?://#', '', $input);
        // Remove www
        $input = preg_replace('#^www\.#', '', $input);
        // Remove paths
        $parts = explode('/', $input);
        $input = $parts[0];
        return strtolower($input);
    }
}
