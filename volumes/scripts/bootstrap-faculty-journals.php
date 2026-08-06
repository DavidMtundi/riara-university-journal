<?php

/**
 * OJS Riara — optional faculty journal shells cloned from the primary journal.
 *
 * Set OJS_FACULTY_JOURNALS to a pipe-separated list of path:Name pairs, e.g.
 *   law:Riara Law Journal|engineering:School of Engineering Journal
 *
 * Skipped when the variable is unset or empty.
 */

require __DIR__ . '/script-db.php';
require __DIR__ . '/riara-ojs-lib.php';

$config = require __DIR__ . '/test-config.php';
$pdo = riara_script_pdo();
$sourceJournalId = riara_journal_id_from_path($pdo, $config['journalPath']);

function riara_env(string $key, string $default = ''): string
{
    $value = getenv($key);
    return ($value !== false && $value !== '') ? $value : $default;
}

function riara_journal_exists(PDO $pdo, string $path): bool
{
    $stmt = $pdo->prepare('SELECT journal_id FROM journals WHERE path = ?');
    $stmt->execute([$path]);
    return (bool) $stmt->fetchColumn();
}

function riara_clone_journal(PDO $pdo, int $sourceJournalId, string $path, string $name): int
{
    if (riara_journal_exists($pdo, $path)) {
        $stmt = $pdo->prepare('SELECT journal_id FROM journals WHERE path = ?');
        $stmt->execute([$path]);
        $id = (int) $stmt->fetchColumn();
        echo "Journal already exists: $path (id $id)\n";
        return $id;
    }

    $seq = (int) $pdo->query('SELECT COALESCE(MAX(seq), 0) + 1 FROM journals')->fetchColumn();
    $pdo->prepare(
        'INSERT INTO journals (path, seq, primary_locale, enabled, current_issue_id)
         SELECT ?, ?, primary_locale, enabled, NULL FROM journals WHERE journal_id = ?'
    )->execute([$path, $seq, $sourceJournalId]);
    $newJournalId = (int) $pdo->lastInsertId();

    $skipSettings = [
        'currentIssueId',
        'name',
        'description',
        'abbrev',
        'publisher',
        'contactName',
        'contactEmail',
        'mailingAddress',
    ];

    $stmt = $pdo->prepare(
        'SELECT locale, setting_name, setting_value
         FROM journal_settings
         WHERE journal_id = ?
           AND setting_name NOT IN (' . implode(',', array_fill(0, count($skipSettings), '?')) . ')'
    );
    $stmt->execute(array_merge([$sourceJournalId], $skipSettings));
    $insertSetting = $pdo->prepare(
        'INSERT INTO journal_settings (journal_id, locale, setting_name, setting_value)
         VALUES (?, ?, ?, ?)'
    );
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $insertSetting->execute([$newJournalId, $row['locale'], $row['setting_name'], $row['setting_value']]);
    }

    foreach (['name' => $name, 'abbrev' => $path] as $setting => $value) {
        $insertSetting->execute([$newJournalId, 'en', $setting, $value]);
    }
    $insertSetting->execute([
        $newJournalId,
        'en',
        'description',
        "Scholarly journal published by {$name}, Riara University.",
    ]);

    $sectionMap = [];
    $sections = $pdo->prepare('SELECT * FROM sections WHERE journal_id = ?');
    $sections->execute([$sourceJournalId]);
    while ($section = $sections->fetch(PDO::FETCH_ASSOC)) {
        $oldSectionId = (int) $section['section_id'];
        unset($section['section_id']);
        $section['journal_id'] = $newJournalId;
        $columns = array_keys($section);
        $placeholders = implode(',', array_fill(0, count($columns), '?'));
        $pdo->prepare(
            'INSERT INTO sections (' . implode(',', $columns) . ') VALUES (' . $placeholders . ')'
        )->execute(array_values($section));
        $newSectionId = (int) $pdo->lastInsertId();
        $sectionMap[$oldSectionId] = $newSectionId;

        $settings = $pdo->prepare('SELECT locale, setting_name, setting_value FROM section_settings WHERE section_id = ?');
        $settings->execute([$oldSectionId]);
        $insertSectionSetting = $pdo->prepare(
            'INSERT INTO section_settings (section_id, locale, setting_name, setting_value) VALUES (?, ?, ?, ?)'
        );
        while ($setting = $settings->fetch(PDO::FETCH_ASSOC)) {
            $insertSectionSetting->execute([$newSectionId, $setting['locale'], $setting['setting_name'], $setting['setting_value']]);
        }
    }

    $groupMap = [];
    $groups = $pdo->prepare('SELECT * FROM user_groups WHERE context_id = ?');
    $groups->execute([$sourceJournalId]);
    while ($group = $groups->fetch(PDO::FETCH_ASSOC)) {
        $oldGroupId = (int) $group['user_group_id'];
        unset($group['user_group_id']);
        $group['context_id'] = $newJournalId;
        $columns = array_keys($group);
        $placeholders = implode(',', array_fill(0, count($columns), '?'));
        $pdo->prepare(
            'INSERT INTO user_groups (' . implode(',', $columns) . ') VALUES (' . $placeholders . ')'
        )->execute(array_values($group));
        $newGroupId = (int) $pdo->lastInsertId();
        $groupMap[$oldGroupId] = $newGroupId;

        $settings = $pdo->prepare('SELECT locale, setting_name, setting_value FROM user_group_settings WHERE user_group_id = ?');
        $settings->execute([$oldGroupId]);
        $insertGroupSetting = $pdo->prepare(
            'INSERT INTO user_group_settings (user_group_id, locale, setting_name, setting_value) VALUES (?, ?, ?, ?)'
        );
        while ($setting = $settings->fetch(PDO::FETCH_ASSOC)) {
            $insertGroupSetting->execute([$newGroupId, $setting['locale'], $setting['setting_name'], $setting['setting_value']]);
        }
    }

    $genres = $pdo->prepare('SELECT * FROM genres WHERE context_id = ?');
    $genres->execute([$sourceJournalId]);
    while ($genre = $genres->fetch(PDO::FETCH_ASSOC)) {
        $oldGenreId = (int) $genre['genre_id'];
        unset($genre['genre_id']);
        $genre['context_id'] = $newJournalId;
        $columns = array_keys($genre);
        $placeholders = implode(',', array_fill(0, count($columns), '?'));
        $pdo->prepare(
            'INSERT INTO genres (' . implode(',', $columns) . ') VALUES (' . $placeholders . ')'
        )->execute(array_values($genre));
        $newGenreId = (int) $pdo->lastInsertId();

        $settings = $pdo->prepare('SELECT locale, setting_name, setting_value, setting_type FROM genre_settings WHERE genre_id = ?');
        $settings->execute([$oldGenreId]);
        $insertGenreSetting = $pdo->prepare(
            'INSERT INTO genre_settings (genre_id, locale, setting_name, setting_value, setting_type) VALUES (?, ?, ?, ?, ?)'
        );
        while ($setting = $settings->fetch(PDO::FETCH_ASSOC)) {
            $insertGenreSetting->execute([
                $newGenreId,
                $setting['locale'],
                $setting['setting_name'],
                $setting['setting_value'],
                $setting['setting_type'],
            ]);
        }
    }

    echo "Created faculty journal: $path (id $newJournalId)\n";
    return $newJournalId;
}

$faculties = riara_env('OJS_FACULTY_JOURNALS');
if ($faculties === '') {
    echo "Skipping faculty journals (OJS_FACULTY_JOURNALS not set).\n";
    exit(0);
}

$processed = 0;
$newCount = 0;
foreach (explode('|', $faculties) as $entry) {
    $entry = trim($entry);
    if ($entry === '' || !str_contains($entry, ':')) {
        continue;
    }
    [$path, $name] = array_map('trim', explode(':', $entry, 2));
    if ($path === '' || $name === '') {
        continue;
    }
    $existed = riara_journal_exists($pdo, $path);
    $journalId = riara_clone_journal($pdo, $sourceJournalId, $path, $name);
    $description = "Scholarly journal published by {$name}, Riara University.";
    $pdo->prepare(
        "INSERT INTO journal_settings (journal_id, locale, setting_name, setting_value)
         VALUES (?, 'en', 'description', ?)
         ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)"
    )->execute([$journalId, $description]);
    if (!$existed) {
        $newCount++;
    }
    $processed++;
}

echo "Faculty journal bootstrap complete ($processed processed, $newCount created).\n";

if ($newCount > 0) {
    echo "Running theme bootstrap for all journals...\n";
    passthru('php ' . escapeshellarg(__DIR__ . '/bootstrap-theme.php'));
    echo "Running Google OAuth bootstrap for all journals...\n";
    passthru('php ' . escapeshellarg(__DIR__ . '/bootstrap-google-oauth.php'));
}
