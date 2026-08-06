<?php
try {
    new PDO('mysql:host=db;dbname=pkp', 'pkp', 'ojsRiara2026!');
    echo "DB_OK\n";
} catch (Exception $e) {
    echo "DB_FAIL: " . $e->getMessage() . "\n";
}

$dirs = ['/var/www/files', '/var/www/html/cache', '/var/www/html/public'];
foreach ($dirs as $dir) {
    echo (is_writable($dir) ? 'WRITABLE' : 'NOT_WRITABLE') . ": $dir\n";
}
