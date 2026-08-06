<?php

/**
 * Remove Mass Test submissions created by workflow-runner.php.
 */

require __DIR__ . '/test-lib.php';
require __DIR__ . '/riara-ojs-lib.php';

$config = require __DIR__ . '/test-config.php';
$context = riara_bootstrap_ojs($config['journalPath']);
$removed = riara_cleanup_mass_test_submissions($context);

echo "Removed $removed Mass Test submission(s)\n";
