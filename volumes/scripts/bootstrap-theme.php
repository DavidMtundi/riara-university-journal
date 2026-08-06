<?php



require __DIR__ . '/script-db.php';

require __DIR__ . '/riara-ojs-lib.php';



$config = require __DIR__ . '/test-config.php';

$pdo = riara_script_pdo();

$primaryJournalId = riara_journal_id_from_path($pdo, $config['journalPath']);



$stmt = $pdo->query("SELECT version_id FROM versions WHERE product_type='plugins.themes' AND product='riarauniversity'");

if (!$stmt->fetch()) {

    $pdo->exec("INSERT INTO versions (major, minor, revision, build, date_installed, current, product_type, product, product_class_name, lazy_load, sitewide)

        VALUES (1, 0, 0, 0, NOW(), 1, 'plugins.themes', 'riarauniversity', 'RiaraUniversityThemePlugin', 1, 0)");

}



$enablePlugin = $pdo->prepare(

    "INSERT INTO plugin_settings (plugin_name, context_id, setting_name, setting_value, setting_type)

     VALUES (?, ?, 'enabled', '1', 'bool')

     ON DUPLICATE KEY UPDATE setting_value='1'"

);

$setJournalTheme = $pdo->prepare(

    "INSERT INTO journal_settings (journal_id, locale, setting_name, setting_value)

     VALUES (?, '', 'themePluginPath', 'riarauniversity')

     ON DUPLICATE KEY UPDATE setting_value='riarauniversity'"

);



$pdo->exec("UPDATE site_settings SET setting_value='riarauniversity' WHERE setting_name='themePluginPath'");

$enablePlugin->execute(['defaultthemeplugin', null]);

$enablePlugin->execute(['riarauniversitythemeplugin', null]);



$journalIds = $pdo->query('SELECT journal_id FROM journals')->fetchAll(PDO::FETCH_COLUMN);

foreach ($journalIds as $id) {

    $journalId = (int) $id;

    $enablePlugin->execute(['defaultthemeplugin', $journalId]);

    $enablePlugin->execute(['riarauniversitythemeplugin', $journalId]);

    $setJournalTheme->execute([$journalId]);

}

echo 'Theme enabled for ' . count($journalIds) . " journal(s)\n";



$pdo->prepare("INSERT INTO journal_settings (journal_id, locale, setting_name, setting_value)

    VALUES (?, '', 'enableAnnouncements', '1')

    ON DUPLICATE KEY UPDATE setting_value='1'")->execute([$primaryJournalId]);

$pdo->prepare("INSERT INTO journal_settings (journal_id, locale, setting_name, setting_value)

    VALUES (?, '', 'numAnnouncementsHomepage', '3')

    ON DUPLICATE KEY UPDATE setting_value='3'")->execute([$primaryJournalId]);



$stmt = $pdo->prepare('SELECT COUNT(*) FROM announcements WHERE assoc_id=?');

$stmt->execute([$primaryJournalId]);

$announcementCount = (int) $stmt->fetchColumn();



if ($announcementCount === 0) {

    $pdo->prepare("INSERT INTO announcements (assoc_type, assoc_id, type_id, date_expire, date_posted)

        VALUES (256, ?, NULL, NULL, NOW())")->execute([$primaryJournalId]);

    $announcementId = (int) $pdo->lastInsertId();

    $stmt = $pdo->prepare('INSERT INTO announcement_settings (announcement_id, locale, setting_name, setting_value) VALUES (?, ?, ?, ?)');

    foreach ([

        ['en', 'title', 'Welcome to Riara University Journal'],

        ['en', 'descriptionShort', 'Our scholarly publishing platform is now live.'],

        ['en', 'description', '<p>Riara University Journal publishes peer-reviewed research from our academic community. Explore current issues, author guidelines, and submission pathways on this site.</p>'],

    ] as [$locale, $name, $value]) {

        $stmt->execute([$announcementId, $locale, $name, $value]);

    }

    echo "Sample announcement created (id $announcementId)\n";

}



$stmt = $pdo->prepare('SELECT issue_id FROM issues WHERE journal_id=? AND published=1 ORDER BY date_published DESC, issue_id DESC LIMIT 1');

$stmt->execute([$primaryJournalId]);

$currentIssueId = $stmt->fetchColumn();

if ($currentIssueId) {

    $pdo->prepare("INSERT INTO journal_settings (journal_id, locale, setting_name, setting_value)

        VALUES (?, '', 'currentIssueId', ?)

        ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)")->execute([$primaryJournalId, (string) $currentIssueId]);

    echo "Current issue set to $currentIssueId\n";

}



echo "Theme bootstrap complete (primary journal $primaryJournalId)\n";

