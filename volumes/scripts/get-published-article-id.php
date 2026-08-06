<?php

require __DIR__ . '/test-lib.php';

$config = require __DIR__ . '/test-config.php';
$pdo = riara_pdo($config);
$id = (int) $pdo->query('SELECT submission_id FROM submissions WHERE status=3 ORDER BY submission_id DESC LIMIT 1')->fetchColumn();

if (!$id) {
    fwrite(STDERR, "No published submission found\n");
    exit(1);
}

echo $id;
