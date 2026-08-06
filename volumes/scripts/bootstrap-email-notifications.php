<?php

/**
 * OJS Riara — journal email notification defaults and template copy.
 */

require __DIR__ . '/script-db.php';
require __DIR__ . '/riara-ojs-lib.php';

$config = require __DIR__ . '/test-config.php';
$pdo = riara_script_pdo();
$journalId = riara_journal_id_from_path($pdo, $config['journalPath']);

function riara_upsert_journal_setting(PDO $pdo, int $journalId, string $name, string $value, string $locale = ''): void
{
    $pdo->prepare(
        'INSERT INTO journal_settings (journal_id, locale, setting_name, setting_value)
         VALUES (?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)'
    )->execute([$journalId, $locale, $name, $value]);
}

function riara_enable_plugin(PDO $pdo, string $pluginName, ?int $contextId = null): void
{
    $pdo->prepare(
        'INSERT INTO plugin_settings (plugin_name, context_id, setting_name, setting_value, setting_type)
         VALUES (?, ?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value), setting_type = VALUES(setting_type)'
    )->execute([$pluginName, $contextId, 'enabled', '1', 'bool']);
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

// ─── Journal email settings ───────────────────────────────────────────────────

$emailSettings = [
    'submissionAcknowledgement' => 'allAuthors',
    'notifyAllAuthors' => '1',
    'copySubmissionAckPrimaryContact' => '1',
    'notificationSubmissionSubmitted' => '1',
    'emailNotificationSubmissionSubmitted' => '1',
];

foreach ($emailSettings as $name => $value) {
    riara_upsert_journal_setting($pdo, $journalId, $name, $value);
    echo "Email setting: $name = $value\n";
}

// ─── Workflow notifications plugin ────────────────────────────────────────────

riara_register_plugin_version($pdo, 'riaraworkflownotifications', 'RiaraWorkflowNotificationsPlugin');
riara_enable_plugin($pdo, 'riaraworkflownotificationsplugin', $journalId);
echo "Enabled plugin: riaraworkflownotificationsplugin\n";

echo "Email notifications bootstrap complete.\n";
