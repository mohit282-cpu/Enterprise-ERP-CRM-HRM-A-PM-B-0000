<?php

$modules = ['Projects', 'HRM', 'Accounting', 'Billing', 'Inventory', 'Hosting', 'Domains'];

foreach ($modules as $module) {
    $dir = __DIR__ . '/modules/' . $module . '/Views';
    if (!is_dir($dir)) continue;

    $iterator = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($dir));
    foreach ($iterator as $file) {
        if ($file->isFile() && str_ends_with($file->getFilename(), '.php')) {
            $content = file_get_contents($file->getPathname());
            
            // Just inject a basic loop if <tbody> is found and not already hydrated
            if (strpos($content, '<tbody>') !== false && strpos($content, 'foreach') === false) {
                // We'll just assume $data is passed if we use a generic loop
                // Wait, we know what the dataKey is for each module from scaffold_modules.php
                $dataKey = strtolower($module);
                if ($module === 'HRM') $dataKey = 'employees';
                if ($module === 'Accounting') $dataKey = 'accounts';
                if ($module === 'Hosting') $dataKey = 'accounts';
                
                $dynamicRows = "<?php if(!empty(\${$dataKey})): foreach(\${$dataKey} as \$row): ?>\n<tr>\n";
                $dynamicRows .= "    <td colspan=\"10\"><?= json_encode(\$row) ?></td>\n";
                $dynamicRows .= "</tr>\n<?php endforeach; else: ?>\n<tr><td colspan=\"10\" class=\"text-center py-4 text-muted\">No records found.</td></tr>\n<?php endif; ?>";

                $newContent = preg_replace('/<tbody>.*?<\/tbody>/s', "<tbody>\n$dynamicRows\n</tbody>", $content);
                file_put_contents($file->getPathname(), $newContent);
                echo "Hydrated " . $file->getPathname() . "\n";
            }
        }
    }
}
