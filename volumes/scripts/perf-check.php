<?php

require __DIR__ . '/script-db.php';



$config = require __DIR__ . '/test-config.php';

$pdo = riara_script_pdo();



echo "=== OPcache ===\n";

if (function_exists('opcache_get_status')) {

    $s = opcache_get_status(false);

    echo 'enabled: ' . ($s['opcache_enabled'] ? 'yes' : 'no') . "\n";

    echo 'hit_rate: ' . round($s['opcache_statistics']['opcache_hit_rate'] ?? 0, 1) . "%\n";

    echo 'mem_used_mb: ' . round(($s['memory_usage']['used_memory'] ?? 0) / 1024 / 1024, 1) . "\n";

    echo 'scripts_cached: ' . ($s['opcache_statistics']['num_cached_scripts'] ?? 0) . "\n";

}



echo "\n=== PHP ===\n";

echo 'memory_limit: ' . ini_get('memory_limit') . "\n";

echo 'realpath_cache_size: ' . ini_get('realpath_cache_size') . "\n";



echo "\n=== OJS config ===\n";

require '/var/www/html/lib/pkp/includes/bootstrap.php';

echo 'web_cache: ' . (PKP\config\Config::getVar('cache', 'web_cache') ? 'On' : 'Off') . "\n";

echo 'enable_minified: ' . (PKP\config\Config::getVar('general', 'enable_minified') ? 'On' : 'Off') . "\n";

echo 'restful_urls: ' . (PKP\config\Config::getVar('general', 'restful_urls') ? 'On' : 'Off') . "\n";



$db = $config['db'];

$pdo = new PDO(

    "mysql:host={$db['host']};dbname={$db['name']};charset=utf8mb4",

    $db['user'],

    $db['pass'],

    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]

);

$start = microtime(true);

$pdo->query('SELECT COUNT(*) FROM submissions')->fetchColumn();

echo 'db_ping_ms: ' . round((microtime(true) - $start) * 1000, 2) . "\n";



$start = microtime(true);

$pdo->query('SELECT s.submission_id, ps.setting_value FROM submissions s JOIN publication_settings ps ON ps.publication_id = s.current_publication_id AND ps.setting_name = "title" LIMIT 50')->fetchAll();

echo 'db_join_query_ms: ' . round((microtime(true) - $start) * 1000, 2) . "\n";

