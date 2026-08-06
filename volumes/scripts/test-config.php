<?php

/**
 * Shared configuration for OJS Riara test suite.
 */

$defaultBaseUrl = (file_exists('/.dockerenv') || getenv('OJS_IN_CONTAINER'))
    ? 'http://localhost'
    : 'http://127.0.0.1:8888';

return [
    'baseUrl' => getenv('OJS_BASE_URL') ?: $defaultBaseUrl,
    'journalPath' => getenv('OJS_JOURNAL_PATH') ?: 'riara',
    'themePath' => 'riarauniversity',
    'db' => [
        'host' => getenv('DB_HOST') ?: 'db',
        'name' => getenv('DB_NAME') ?: 'pkp',
        'user' => getenv('DB_USER') ?: 'pkp',
        'pass' => getenv('DB_PASS') ?: getenv('MYSQL_PASSWORD') ?: getenv('PKP_DB_PASSWORD') ?: '',
    ],
    'users' => [
        'admin' => ['username' => 'root', 'password' => 'root'],
        'author' => ['username' => 'author', 'password' => 'test123'],
        'reviewer' => ['username' => 'reviewer', 'password' => 'test123'],
    ],
];
