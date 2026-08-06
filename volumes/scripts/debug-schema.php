<?php
require __DIR__ . '/test-lib.php';
$pdo = riara_pdo(require __DIR__ . '/test-config.php');
foreach ($pdo->query('DESCRIBE journals') as $r) {
    echo $r['Field'] . ' ' . $r['Type'] . PHP_EOL;
}
