<?php

/**
 * Render volumes/config/pkp.config.inc.php from .env and pkp.config.inc.php.example.
 *
 * Usage:
 *   php volumes/scripts/render-config.php [--force] [--strict] [--dry-run]
 *
 * --strict  Fail if required secrets are missing or still placeholders.
 *            Also enabled automatically when OJS_ENV=production in .env.
 * --dry-run Validate and print planned output path without writing.
 */

require __DIR__ . '/riara-env.php';

$root = dirname(__DIR__, 2);
$envFile = $root . '/.env';
$template = dirname(__DIR__) . '/config/pkp.config.inc.php.example';
$output = dirname(__DIR__) . '/config/pkp.config.inc.php';

$argv = $argv ?? [];
$force = in_array('--force', $argv, true);
$strict = in_array('--strict', $argv, true);
$dryRun = in_array('--dry-run', $argv, true);

if (!$force && !$dryRun && file_exists($output)) {
    echo "Config already exists: $output (use --force to overwrite)\n";
    exit(0);
}

if (!file_exists($template)) {
    fwrite(STDERR, "Missing template: $template\n");
    exit(1);
}

$env = riara_load_env_file($envFile);
$validationErrors = riara_validate_env($env, $strict);

if ($validationErrors !== []) {
    fwrite(STDERR, "Environment validation failed:\n");
    foreach ($validationErrors as $error) {
        fwrite(STDERR, "  - $error\n");
    }
    fwrite(STDERR, "\nFix .env or omit --strict / OJS_ENV=production for local development.\n");
    exit(1);
}

if (!file_exists($envFile)) {
    fwrite(STDERR, "Warning: no .env file at $envFile — using script defaults (dev only).\n");
}

$dbPass = $env['DB_PASS'] ?? $env['MYSQL_PASSWORD'] ?? $env['PKP_DB_PASSWORD'] ?? 'changeMePlease';
$httpPort = $env['HTTP_PORT'] ?? '8888';
$baseUrl = $env['OJS_BASE_URL'] ?? "http://127.0.0.1:{$httpPort}";
$appKey = $env['OJS_APP_KEY'] ?? 'base64:REPLACE_ME_GENERATE_A_NEW_KEY';
$salt = $env['OJS_SALT'] ?? 'YouMustSetASecretKeyHere!!';

function riara_render_email_transport(array $env): string
{
    $server = $env['OJS_SMTP_SERVER'] ?? '';
    if ($server === '') {
        return "default = sendmail\n\nsendmail_path = \"/usr/sbin/sendmail -bs\"";
    }

    $port = $env['OJS_SMTP_PORT'] ?? '587';
    $auth = $env['OJS_SMTP_AUTH'] ?? 'tls';
    $user = $env['OJS_SMTP_USERNAME'] ?? '';
    $pass = $env['OJS_SMTP_PASSWORD'] ?? '';
    $envelope = $env['OJS_SMTP_ENVELOPE'] ?? '';

    $lines = [
        'default = smtp',
        '',
        'smtp = On',
        "smtp_server = {$server}",
        "smtp_port = {$port}",
    ];

    if ($auth !== '' && strtolower($auth) !== 'none') {
        $lines[] = "smtp_auth = {$auth}";
    }
    if ($user !== '') {
        $lines[] = "smtp_username = {$user}";
        $lines[] = "smtp_password = {$pass}";
    }
    if ($envelope !== '') {
        $lines[] = 'allow_envelope_sender = On';
        $lines[] = "default_envelope_sender = {$envelope}";
    }

    return implode("\n", $lines);
}

$contents = file_get_contents($template);
$contents = str_replace(
    ['__DB_PASSWORD__', '__APP_KEY__', '__BASE_URL__', '__SALT__', '__OJS_EMAIL_TRANSPORT__'],
    [$dbPass, $appKey, $baseUrl, $salt, riara_render_email_transport($env)],
    $contents
);

if ($dryRun) {
    echo "Dry run OK — would render $output\n";
    echo "  base_url: $baseUrl\n";
    if (!empty($env['OJS_SMTP_SERVER'])) {
        echo "  SMTP: {$env['OJS_SMTP_SERVER']}\n";
    }
    exit(0);
}

file_put_contents($output, $contents);
echo "Rendered $output\n";
if (!empty($env['OJS_SMTP_SERVER'])) {
    echo "  (SMTP transport: {$env['OJS_SMTP_SERVER']})\n";
}
