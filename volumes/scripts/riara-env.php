<?php

/**
 * Shared .env loader and validation for OJS Riara scripts.
 */

function riara_load_env_file(string $path): array
{
    $env = [];
    if (!file_exists($path)) {
        return $env;
    }

    foreach (file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        $line = trim($line);
        if ($line === '' || str_starts_with($line, '#')) {
            continue;
        }
        if (!str_contains($line, '=')) {
            continue;
        }
        [$key, $value] = array_map('trim', explode('=', $line, 2));
        $value = trim($value, " \t\"'");
        $env[$key] = $value;
    }

    return $env;
}

/**
 * @return list<string> Human-readable validation errors (empty = OK).
 */
function riara_validate_env(array $env, bool $strict = false): array
{
    $errors = [];
    $isProduction = ($env['OJS_ENV'] ?? '') === 'production';
    $mustValidate = $strict || $isProduction;

    if (!$mustValidate) {
        return $errors;
    }

    $required = [
        'DB_PASS' => 'Database password',
        'OJS_APP_KEY' => 'OJS application key',
        'OJS_SALT' => 'OJS password salt',
        'OJS_BASE_URL' => 'Public base URL',
    ];

    $placeholderValues = [
        'changeMePlease',
        'YouMustSetASecretKeyHere!!',
        'base64:REPLACE_ME_GENERATE_A_NEW_KEY',
        'http://127.0.0.1:8888',
    ];

    foreach ($required as $key => $label) {
        $value = $env[$key] ?? '';
        if ($value === '') {
            $errors[] = "Missing required variable: $key ($label)";
            continue;
        }
        if (in_array($value, $placeholderValues, true)) {
            $errors[] = "$key still uses a placeholder value — set a production value in .env";
        }
    }

    if (($env['DB_PASS'] ?? '') !== '' && strlen($env['DB_PASS']) < 12) {
        $errors[] = 'DB_PASS should be at least 12 characters in production';
    }

    if (($env['OJS_BASE_URL'] ?? '') !== '' && !str_starts_with($env['OJS_BASE_URL'], 'https://')) {
        $errors[] = 'OJS_BASE_URL should use https:// in production (set OJS_ENV=production only when ready)';
    }

    return $errors;
}
