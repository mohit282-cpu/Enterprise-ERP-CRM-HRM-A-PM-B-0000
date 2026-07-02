<?php
namespace Tests\Unit;

use Tests\TestCase;
use Modules\Domains\Services\DomainService;

class DomainServiceTest extends TestCase {
    
    public function test_it_strips_protocols_and_paths() {
        $service = new DomainService();
        
        $this->assertEquals("example.com", $service->sanitizeDomainName("https://www.example.com/page"));
        $this->assertEquals("test.org", $service->sanitizeDomainName("http://test.org/"));
        $this->assertEquals("sub.domain.net", $service->sanitizeDomainName("sub.domain.net/login?user=1"));
    }
}
