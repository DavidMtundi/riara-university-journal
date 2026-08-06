<?php

/**
 * Shared PDO connection for OJS Riara maintenance scripts.
 */

require_once __DIR__ . '/test-lib.php';

function riara_script_pdo(): PDO
{
    $config = require __DIR__ . '/test-config.php';
    return riara_pdo($config);
}
