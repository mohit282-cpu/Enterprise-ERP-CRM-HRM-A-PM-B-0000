$basePath = "Z:\xampp\htdocs\Enterprise-ERP-CRM-HRM-A-PM-B-0000"
$files = Get-ChildItem -Path $basePath -Filter *.php -Recurse

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
}
Write-Host "BOM removed from all PHP files."
