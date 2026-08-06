<?php

/**
 * OJS Riara — Google OAuth plugin, Student/Staff user groups, and per-journal settings.
 */

require __DIR__ . '/script-db.php';
require __DIR__ . '/riara-ojs-lib.php';

$config = require __DIR__ . '/test-config.php';
$pdo = riara_script_pdo();

function riara_env(string $key, string $default = ''): string
{
    $value = getenv($key);
    return ($value !== false && $value !== '') ? $value : $default;
}

function riara_upsert_plugin_setting(PDO $pdo, string $pluginName, ?int $contextId, string $name, string $value, string $type): void
{
    $pdo->prepare(
        'INSERT INTO plugin_settings (plugin_name, context_id, setting_name, setting_value, setting_type)
         VALUES (?, ?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value), setting_type = VALUES(setting_type)'
    )->execute([$pluginName, $contextId, $name, $value, $type]);
}

function riara_enable_plugin(PDO $pdo, string $pluginName, ?int $contextId = null): void
{
    riara_upsert_plugin_setting($pdo, $pluginName, $contextId, 'enabled', '1', 'bool');
}

function riara_register_plugin_version(PDO $pdo, string $product, string $className): void
{
    $stmt = $pdo->prepare('SELECT version_id FROM versions WHERE product_type = ? AND product = ? AND current = 1');
    $stmt->execute(['plugins.generic', $product]);
    if ((int) $stmt->fetchColumn() > 0) {
        return;
    }

    $pdo->prepare(
        'INSERT INTO versions (major, minor, revision, build, date_installed, current, product_type, product, product_class_name, lazy_load, sitewide)
         VALUES (1, 0, 0, 0, NOW(), 1, ?, ?, ?, 1, 1)'
    )->execute(['plugins.generic', $product, $className]);
}

function riara_find_user_group_by_name(PDO $pdo, int $contextId, string $name): int
{
    $stmt = $pdo->prepare(
        'SELECT ug.user_group_id
         FROM user_groups ug
         JOIN user_group_settings ugs ON ug.user_group_id = ugs.user_group_id
         WHERE ug.context_id = ? AND ugs.setting_name = "name" AND ugs.locale = "en" AND ugs.setting_value = ?'
    );
    $stmt->execute([$contextId, $name]);
    return (int) $stmt->fetchColumn();
}

function riara_create_reader_group(PDO $pdo, int $contextId, string $name, string $abbrev): int
{
    $existing = riara_find_user_group_by_name($pdo, $contextId, $name);
    if ($existing > 0) {
        return $existing;
    }

    $pdo->prepare(
        'INSERT INTO user_groups (context_id, role_id, is_default, show_title, permit_self_registration, permit_metadata_edit, permit_settings, masthead)
         VALUES (?, ?, 0, 1, 0, 0, 0, 0)'
    )->execute([$contextId, 1048576]);

    $groupId = (int) $pdo->lastInsertId();
    $settings = [
        ['', 'nameLocaleKey', ''],
        ['', 'abbrevLocaleKey', ''],
        ['en', 'name', $name],
        ['en', 'abbrev', $abbrev],
    ];

    foreach ($settings as [$locale, $settingName, $value]) {
        if ($value === '' && str_ends_with($settingName, 'LocaleKey')) {
            continue;
        }
        $pdo->prepare(
            'INSERT INTO user_group_settings (user_group_id, locale, setting_name, setting_value)
             VALUES (?, ?, ?, ?)'
        )->execute([$groupId, $locale, $settingName, $value]);
    }

    echo "Created user group: $name (id $groupId)\n";
    return $groupId;
}

function riara_bootstrap_google_oauth_for_journal(PDO $pdo, int $journalId): void
{
    $pluginName = 'googleoauthplugin';
    $studentGroupId = riara_create_reader_group($pdo, $journalId, 'Student', 'Stu');
    $staffGroupId = riara_create_reader_group($pdo, $journalId, 'Staff', 'Staff');

    riara_enable_plugin($pdo, $pluginName, $journalId);
    riara_upsert_plugin_setting($pdo, $pluginName, $journalId, 'studentUserGroupId', (string) $studentGroupId, 'int');
    riara_upsert_plugin_setting($pdo, $pluginName, $journalId, 'staffUserGroupId', (string) $staffGroupId, 'int');
    riara_upsert_plugin_setting($pdo, $pluginName, $journalId, 'restrictSubmissionsToUniversity', '0', 'bool');

    $useTestCredentials = riara_env('OJS_GOOGLE_TEST_CREDENTIALS') === '1';
    $clientId = riara_env('OJS_GOOGLE_CLIENT_ID');
    $clientSecret = riara_env('OJS_GOOGLE_CLIENT_SECRET');

    if ($clientId !== '' && $clientSecret !== '') {
        riara_upsert_plugin_setting($pdo, $pluginName, $journalId, 'clientId', $clientId, 'string');
        riara_upsert_plugin_setting($pdo, $pluginName, $journalId, 'clientSecret', $clientSecret, 'string');
        echo "Google OAuth credentials configured for journal $journalId\n";
    } elseif ($useTestCredentials) {
        riara_upsert_plugin_setting($pdo, $pluginName, $journalId, 'clientId', 'riara-test-client-id', 'string');
        riara_upsert_plugin_setting($pdo, $pluginName, $journalId, 'clientSecret', 'riara-test-client-secret', 'string');
        echo "Google OAuth test credentials configured for journal $journalId\n";
    }

    echo "Google OAuth bootstrap complete for journal $journalId (Student=$studentGroupId, Staff=$staffGroupId)\n";
}

riara_register_plugin_version($pdo, 'googleOAuth', 'GoogleOAuthPlugin');

$journalIds = $pdo->query('SELECT journal_id FROM journals WHERE enabled = 1')->fetchAll(PDO::FETCH_COLUMN);
foreach ($journalIds as $journalId) {
    riara_bootstrap_google_oauth_for_journal($pdo, (int) $journalId);
}

echo "Google OAuth bootstrap finished for " . count($journalIds) . " journal(s).\n";
