<?php

require __DIR__ . '/script-db.php';
require __DIR__ . '/riara-ojs-lib.php';

$config = require __DIR__ . '/test-config.php';
$pdo = riara_script_pdo();
$journalId = riara_journal_id_from_path($pdo, $config['journalPath']);

$authorGroup = riara_user_group_id($pdo, $journalId, 65536);
$reviewerGroup = riara_user_group_id($pdo, $journalId, 4096);

$users = [
    [
        'username' => 'author',
        'password' => 'test123',
        'email' => 'author.test@riarauniversity.ac.ke',
        'given' => 'Jane',
        'family' => 'Author',
        'group' => $authorGroup,
    ],
    [
        'username' => 'reviewer',
        'password' => 'test123',
        'email' => 'reviewer.test@riarauniversity.ac.ke',
        'given' => 'John',
        'family' => 'Reviewer',
        'group' => $reviewerGroup,
    ],
];

foreach ($users as $u) {
    $stmt = $pdo->prepare('SELECT user_id FROM users WHERE username = ? OR email = ?');
    $stmt->execute([$u['username'], $u['email']]);
    $existing = $stmt->fetchColumn();

    if ($existing) {
        $userId = (int) $existing;
        $hash = password_hash($u['password'], PASSWORD_BCRYPT);
        $pdo->prepare('UPDATE users SET password = ?, email = ?, disabled = 0 WHERE user_id = ?')
            ->execute([$hash, $u['email'], $userId]);
        echo "Updated {$u['username']} (id $userId)\n";
    } else {
        $hash = password_hash($u['password'], PASSWORD_BCRYPT);
        $pdo->prepare(
            'INSERT INTO users (username, password, email, locales, date_registered, disabled)
             VALUES (?, ?, ?, ?, NOW(), 0)'
        )->execute([$u['username'], $hash, $u['email'], '["en"]']);
        $userId = (int) $pdo->lastInsertId();
        echo "Created {$u['username']} (id $userId)\n";
    }

    foreach (['givenName' => $u['given'], 'familyName' => $u['family']] as $name => $value) {
        $pdo->prepare(
            'INSERT INTO user_settings (user_id, locale, setting_name, setting_value)
             VALUES (?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)'
        )->execute([$userId, 'en', $name, $value]);
    }

    $pdo->prepare('DELETE FROM user_user_groups WHERE user_id = ? AND user_group_id = ?')
        ->execute([$userId, $u['group']]);
    $pdo->prepare('INSERT INTO user_user_groups (user_id, user_group_id) VALUES (?, ?)')
        ->execute([$userId, $u['group']]);
}

echo "Test users ready: author/test123, reviewer/test123\n";
