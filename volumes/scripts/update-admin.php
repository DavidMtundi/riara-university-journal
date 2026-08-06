<?php

/**
 * Reset site admin credentials (local dev / disaster recovery only).
 *
 * Usage:
 *   OJS_ADMIN_USER=root OJS_ADMIN_PASS='new-password' OJS_ADMIN_EMAIL=you@example.com \
 *     docker exec pkp_app_ojs-riara php /tmp/update-admin.php
 */

require __DIR__ . '/script-db.php';

$username = getenv('OJS_ADMIN_USER') ?: 'root';
$password = getenv('OJS_ADMIN_PASS') ?: '';
$email = getenv('OJS_ADMIN_EMAIL') ?: 'admin@example.com';

if ($password === '') {
    fwrite(STDERR, "ERROR: Set OJS_ADMIN_PASS before running update-admin.php\n");
    exit(1);
}

$pdo = riara_script_pdo();
$hash = password_hash($password, PASSWORD_BCRYPT);
$stmt = $pdo->prepare('UPDATE users SET username=?, password=?, email=? WHERE user_id=1');
$stmt->execute([$username, $hash, $email]);
echo "Updated user_id=1: username={$username}\n";
