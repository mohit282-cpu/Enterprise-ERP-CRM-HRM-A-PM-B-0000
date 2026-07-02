<?php
namespace Tests\Unit;

use Tests\TestCase;
use App\Core\Sanitizer;

class SanitizerTest extends TestCase {
    
    public function test_it_escapes_xss_payloads() {
        $payload = "<script>alert('xss');</script>";
        $clean = Sanitizer::escape($payload);
        
        $this->assertStringNotContainsString("<script>", $clean);
        $this->assertEquals("&lt;script&gt;alert(&#039;xss&#039;);&lt;/script&gt;", $clean);
    }

    public function test_it_sanitizes_nested_arrays() {
        $payload = [
            'name' => '<b>John</b>',
            'details' => [
                'bio' => '<img src=x onerror=alert(1)>'
            ]
        ];

        $clean = Sanitizer::escapeArray($payload);
        
        $this->assertStringNotContainsString("<b>", $clean['name']);
        $this->assertStringNotContainsString("<img", $clean['details']['bio']);
    }
}
