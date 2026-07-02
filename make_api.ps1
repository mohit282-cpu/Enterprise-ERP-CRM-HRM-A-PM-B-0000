$basePath = "z:\xampp\htdocs\Enterprise-ERP-CRM-HRM-A-PM-B-0000"

# Directories
$dirs = @(
    "database\migrations",
    "app\Core",
    "modules\API\Models",
    "modules\API\Controllers",
    "modules\API\Routes",
    "modules\API\Docs",
    "modules\API\Views\swagger",
    "modules\API\Views\keys"
)

foreach ($dir in $dirs) {
    $fullPath = Join-Path $basePath $dir
    if (-not (Test-Path $fullPath)) { New-Item -ItemType Directory -Force -Path $fullPath | Out-Null }
}

# 1. Database Migration
$migrationPath = Join-Path $basePath "database\migrations\2026_01_15_000000_create_api_tables.php"
$migrationContent = @'
<?php
class CreateApiTables {
    public function up($db) {
        $sql = "
        CREATE TABLE api_keys (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            name VARCHAR(100) NOT NULL,
            api_key VARCHAR(128) NOT NULL UNIQUE,
            last_used_at TIMESTAMP NULL,
            expires_at TIMESTAMP NULL,
            is_active BOOLEAN DEFAULT TRUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
        ";
        $db->exec($sql);
    }
    public function down($db) {
        $db->exec("DROP TABLE IF EXISTS api_keys;");
    }
}
'@
Set-Content -Path $migrationPath -Value $migrationContent -Encoding UTF8

# 2. Core API Base Controller & Middleware
$apiControllerPath = Join-Path $basePath "app\Core\ApiController.php"
$apiControllerContent = @'
<?php
namespace App\Core;

abstract class ApiController {
    
    /**
     * Send standard JSON success response
     */
    protected function sendSuccess($data = null, string $message = 'Success', int $statusCode = 200) {
        http_response_code($statusCode);
        header('Content-Type: application/json');
        echo json_encode([
            'success' => true,
            'message' => $message,
            'data' => $data
        ]);
        exit;
    }

    /**
     * Send standard JSON error response
     */
    protected function sendError(string $message, int $statusCode = 400, $errors = null) {
        http_response_code($statusCode);
        header('Content-Type: application/json');
        echo json_encode([
            'success' => false,
            'message' => $message,
            'errors' => $errors
        ]);
        exit;
    }
}
'@
Set-Content -Path $apiControllerPath -Value $apiControllerContent -Encoding UTF8

$apiMiddlewarePath = Join-Path $basePath "app\Core\ApiMiddleware.php"
$apiMiddlewareContent = @'
<?php
namespace App\Core;
use PDO;

class ApiMiddleware {
    /**
     * Validates Authorization: Bearer <token>
     */
    public static function authenticate() {
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? '';

        if (!preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
            self::abort(401, 'Unauthorized: Missing or Invalid Bearer Token');
        }

        $token = $matches[1];
        
        // Dummy check against db for Phase 1
        $db = Database::getInstance()->getConnection();
        $stmt = $db->prepare("SELECT id, user_id FROM api_keys WHERE api_key = ? AND is_active = 1");
        $stmt->execute([hash('sha256', $token)]);
        $keyRecord = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$keyRecord) {
            self::abort(401, 'Unauthorized: Invalid API Key');
        }

        // Token is valid. Update last used timestamp.
        $db->prepare("UPDATE api_keys SET last_used_at = NOW() WHERE id = ?")->execute([$keyRecord['id']]);

        // Inject user context globally
        $_SERVER['API_USER_ID'] = $keyRecord['user_id'];
    }

    private static function abort(int $code, string $message) {
        http_response_code($code);
        header('Content-Type: application/json');
        echo json_encode(['success' => false, 'message' => $message]);
        exit;
    }
}
'@
Set-Content -Path $apiMiddlewarePath -Value $apiMiddlewareContent -Encoding UTF8


# 3. Models
$apiKeyModelPath = Join-Path $basePath "modules\API\Models\ApiKey.php"
Set-Content -Path $apiKeyModelPath -Value "<?php namespace Modules\API\Models; use App\Core\BaseModel; class ApiKey extends BaseModel { protected string `$table = 'api_keys'; }" -Encoding UTF8

# 4. Controllers
$swaggerControllerPath = Join-Path $basePath "modules\API\Controllers\SwaggerController.php"
$swaggerControllerContent = @'
<?php
namespace Modules\API\Controllers;
use App\Core\BaseController;

class SwaggerController extends BaseController {
    public function index() {
        return $this->view('swagger/index', [], 'API');
    }

    public function json() {
        header('Content-Type: application/json');
        readfile(__DIR__ . '/../Docs/swagger.json');
        exit;
    }
}
'@
Set-Content -Path $swaggerControllerPath -Value $swaggerControllerContent -Encoding UTF8

# 5. Swagger JSON
$swaggerJsonPath = Join-Path $basePath "modules\API\Docs\swagger.json"
$swaggerJsonContent = @'
{
  "openapi": "3.0.0",
  "info": {
    "title": "Sovryx OS Global API",
    "description": "Comprehensive REST API spanning CRM, Accounting, HRM, Projects, Inventory, and Hosting.",
    "version": "1.0.0"
  },
  "servers": [
    {
      "url": "/api/v1",
      "description": "Main Production Server"
    }
  ],
  "components": {
    "securitySchemes": {
      "bearerAuth": {
        "type": "http",
        "scheme": "bearer"
      }
    }
  },
  "security": [
    {
      "bearerAuth": []
    }
  ],
  "paths": {
    "/auth/me": {
      "get": {
        "summary": "Get authenticated user profile",
        "tags": ["Authentication"],
        "responses": {
          "200": { "description": "Success" },
          "401": { "description": "Unauthorized" }
        }
      }
    },
    "/crm/leads": {
      "get": {
        "summary": "List all CRM leads",
        "tags": ["CRM"],
        "responses": {
          "200": { "description": "Success" }
        }
      }
    }
  }
}
'@
Set-Content -Path $swaggerJsonPath -Value $swaggerJsonContent -Encoding UTF8

# 6. Routes
$webRoutesPath = Join-Path $basePath "modules\API\Routes\web.php"
Set-Content -Path $webRoutesPath -Value "<?php return [ 'GET /api/docs' => [Modules\API\Controllers\SwaggerController::class, 'index'], 'GET /api/docs/swagger.json' => [Modules\API\Controllers\SwaggerController::class, 'json'] ];" -Encoding UTF8

# 7. Views
$swaggerViewPath = Join-Path $basePath "modules\API\Views\swagger\index.php"
$swaggerViewContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sovryx OS - API Documentation</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/4.15.5/swagger-ui.css" />
</head>
<body>
    <div id="swagger-ui"></div>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/4.15.5/swagger-ui-bundle.js"></script>
    <script>
        window.onload = () => {
            window.ui = SwaggerUIBundle({
                url: '/api/docs/swagger.json',
                dom_id: '#swagger-ui',
                deepLinking: true,
                presets: [
                    SwaggerUIBundle.presets.apis,
                    SwaggerUIBundle.SwaggerUIStandalonePreset
                ],
                layout: "BaseLayout"
            });
        };
    </script>
</body>
</html>
'@
Set-Content -Path $swaggerViewPath -Value $swaggerViewContent -Encoding UTF8

Write-Host "API module Phase 1 built successfully."
