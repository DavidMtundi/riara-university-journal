<?php

/**
 * OJS Riara — full automated test suite.
 *
 * Run inside app container:
 *   php /var/www/html/../tmp/run-all-tests.php
 *
 * Or from host:
 *   .\run-tests.ps1
 */

require __DIR__ . '/test-lib.php';

$config = require __DIR__ . '/test-config.php';
$runner = new RiaraTestRunner('OJS Riara');
$workflowSubmissionId = null;

echo "\n=== OJS Riara Test Suite ===\n\n";

// --- Infrastructure ---
echo "[Infrastructure]\n";
$runner->run('Database connection', function () use ($config) {
    riara_pdo($config);
});

$runner->run('Writable directories', function () {
    foreach (['/var/www/files', '/var/www/html/cache', '/var/www/html/public'] as $dir) {
        if (!is_writable($dir)) {
            throw new RuntimeException("Not writable: $dir");
        }
    }
});

$runner->run('OJS installed', function () use ($config) {
    $pdo = riara_pdo($config);
    $count = (int) $pdo->query('SELECT COUNT(*) FROM journals')->fetchColumn();
    if ($count < 1) {
        throw new RuntimeException('No journals found');
    }
});

require_once __DIR__ . '/riara-env.php';

$runner->run('render-config strict mode rejects placeholder secrets', function () {
    $errors = riara_validate_env([
        'OJS_ENV' => 'production',
        'DB_PASS' => 'changeMePlease',
        'OJS_APP_KEY' => 'base64:REPLACE_ME_GENERATE_A_NEW_KEY',
        'OJS_SALT' => 'YouMustSetASecretKeyHere!!',
        'OJS_BASE_URL' => 'http://127.0.0.1:8888',
    ], true);
    if ($errors === []) {
        throw new RuntimeException('Expected validation errors for placeholder production env');
    }
});

$runner->run('render-config allows local dev without strict flag', function () {
    $errors = riara_validate_env([
        'DB_PASS' => 'changeMePlease',
        'OJS_APP_KEY' => 'base64:REPLACE_ME_GENERATE_A_NEW_KEY',
        'OJS_BASE_URL' => 'http://127.0.0.1:8888',
    ], false);
    if ($errors !== []) {
        throw new RuntimeException('Dev env should not require strict validation: ' . implode('; ', $errors));
    }
});

$runner->run('Backup script archives DB and file volumes', function () {
    $script = __DIR__ . '/backup.sh';
    if (!is_readable($script)) {
        throw new RuntimeException('backup.sh not synced to container /tmp');
    }
    $contents = file_get_contents($script);
    foreach (['db.sql.gz', 'private-files.tar.gz', 'public-files.tar.gz'] as $artifact) {
        if (!str_contains($contents, $artifact)) {
            throw new RuntimeException("backup.sh missing artifact: $artifact");
        }
    }
    if (!str_contains($contents, 'BACKUP_REMOTE_DIR')) {
        throw new RuntimeException('backup.sh missing BACKUP_REMOTE_DIR support');
    }
});

// --- Users ---
echo "\n[Users & auth]\n";
$runner->run('Admin user exists', function () use ($config) {
    $pdo = riara_pdo($config);
    $stmt = $pdo->prepare('SELECT user_id FROM users WHERE username = ? AND disabled = 0');
    $stmt->execute([$config['users']['admin']['username']]);
    if (!$stmt->fetchColumn()) {
        throw new RuntimeException('Admin user missing');
    }
});

$runner->run('Test users exist', function () use ($config) {
    $pdo = riara_pdo($config);
    foreach (['author', 'reviewer'] as $role) {
        $stmt = $pdo->prepare('SELECT user_id FROM users WHERE username = ?');
        $stmt->execute([$config['users'][$role]['username']]);
        if (!$stmt->fetchColumn()) {
            throw new RuntimeException("User missing: {$config['users'][$role]['username']}");
        }
    }
});

$runner->run('Admin password valid', function () use ($config) {
    $pdo = riara_pdo($config);
    $stmt = $pdo->prepare('SELECT password FROM users WHERE username = ?');
    $stmt->execute([$config['users']['admin']['username']]);
    $hash = $stmt->fetchColumn();
    if (!password_verify($config['users']['admin']['password'], $hash)) {
        throw new RuntimeException('Admin password hash mismatch');
    }
});

// --- Theme ---
echo "\n[Theme: riarauniversity]\n";
$runner->run('Theme plugin registered', function () use ($config) {
    $pdo = riara_pdo($config);
    $stmt = $pdo->prepare("SELECT version_id FROM versions WHERE product_type='plugins.themes' AND product = ?");
    $stmt->execute([$config['themePath']]);
    if (!$stmt->fetchColumn()) {
        throw new RuntimeException('Theme not in versions table');
    }
});

$runner->run('Theme active in journal settings', function () use ($config) {
    $pdo = riara_pdo($config);
    require_once __DIR__ . '/riara-ojs-lib.php';
    $journalId = riara_journal_id_from_path($pdo, $config['journalPath']);
    $stmt = $pdo->prepare("SELECT setting_value FROM journal_settings WHERE journal_id=? AND setting_name='themePluginPath'");
    $stmt->execute([$journalId]);
    $path = $stmt->fetchColumn();
    if ($path !== $config['themePath']) {
        throw new RuntimeException("Expected theme {$config['themePath']}, got $path");
    }
});

$runner->run('Theme files mounted', function () use ($config) {
    $dir = '/var/www/html/plugins/themes/' . $config['themePath'];
    foreach (['RiaraUniversityThemePlugin.php', 'templates/frontend/components/header.tpl', 'templates/frontend/pages/indexJournal.tpl', 'templates/frontend/pages/indexSite.tpl', 'templates/frontend/pages/article.tpl', 'templates/frontend/pages/about.tpl', 'templates/frontend/pages/submissions.tpl', 'templates/frontend/pages/userLogin.tpl', 'templates/frontend/pages/userLostPassword.tpl', 'templates/frontend/pages/privacy.tpl', 'templates/frontend/pages/contact.tpl', 'templates/frontend/objects/article_summary.tpl', 'templates/frontend/pages/search.tpl', 'templates/frontend/pages/announcements.tpl', 'templates/frontend/pages/editorialHistory.tpl', 'styles/riara.less', 'styles/fonts.less', 'fonts/outfit-latin.woff2', 'locale/en/locale.po'] as $file) {
        if (!file_exists("$dir/$file")) {
            throw new RuntimeException("Missing theme file: $file");
        }
    }
});

// --- HTTP public pages ---
echo "\n[HTTP smoke tests]\n";
$publicPages = [
    'Journal home' => '',
    'Login' => 'login',
    'Register' => 'user/register',
    'About' => 'about',
    'Submissions' => 'about/submissions',
    'Search' => 'search',
    'Current issue' => 'issue/current',
    'Archive' => 'issue/archive',
];

foreach ($publicPages as $label => $path) {
    $runner->run("HTTP 200: $label", function () use ($config, $path, $label, $runner) {
        $url = riara_journal_url($config, $path);
        $runner->assertHttpOk($url, $label);
    });
}

$runner->run('Theme stylesheet compiles', function () use ($config, $runner) {
    $url = riara_journal_url($config) . '/$$$call$$$/page/page/css?name=stylesheet';
    $context = stream_context_create([
        'http' => [
            'timeout' => 20,
            'ignore_errors' => true,
            'header' => "User-Agent: RiaraTestSuite/1.0\r\n",
        ],
    ]);
    $body = @file_get_contents($url, false, $context);
    $status = 0;
    if (isset($http_response_header[0]) && preg_match('/\s(\d{3})\s/', $http_response_header[0], $m)) {
        $status = (int) $m[1];
    }
    if ($status !== 200 || $body === false || strlen($body) < 1000) {
        throw new RuntimeException("Theme stylesheet failed to compile (HTTP $status, " . strlen($body ?: '') . ' bytes)');
    }
    $runner->assertContains('.riara-hero', $body, 'Riara LESS output');
    if (str_contains($body, 'grid-column:-1') && !str_contains($body, 'grid-column:1 / -1')) {
        throw new RuntimeException('Featured announcement grid-column was compiled as division (-1)');
    }
    $runner->assertContains('grid-column:1 / -1', $body, 'Featured announcement spans full grid row');
    $runner->assertContains('.pkp_structure_main{margin-left:0', str_replace(' ', '', $body), 'Main column uses full content width');
});

$runner->run('Journal homepage has riarauniversity hero', function () use ($config, $runner) {
    $html = $runner->assertHttpOk(riara_journal_url($config), 'Journal home HTML');
    $runner->assertContains('riara-hero', $html, 'Custom theme hero');
    $runner->assertContains('riara-bento', $html, 'Bento navigation');
    $runner->assertContains('riara-marquee', $html, 'Editorial marquee');
    $runner->assertContains('riara-impact', $html, 'Impact stats strip');
    $runner->assertContains('riara-pathway', $html, 'Submission pathway');
    $runner->assertContains('riara-footer', $html, 'Custom footer');
    $runner->assertContains('stylesheet', $html, 'Theme stylesheet');
    $runner->assertNotContains('fonts.googleapis.com', $html, 'No Google Fonts CDN');
    $runner->assertNotContains('Open Journal Systems', $html, 'No OJS branding on homepage');
    $runner->assertNotContains('pkp_brand_footer', $html, 'No PKP footer brand');
});

$runner->run('Homepage impact stats reflect published content', function () use ($config, $runner) {
    $pdo = riara_pdo($config);
    $published = (int) $pdo->query('SELECT COUNT(*) FROM submissions WHERE status=3')->fetchColumn();
    if ($published < 1) {
        echo "    (skipped — no published submissions)\n";
        return;
    }
    $html = $runner->assertHttpOk(riara_journal_url($config), 'Journal home stats');
    $runner->assertContains('data-riara-count="' . $published . '"', $html, 'Published count in impact strip');
});

$runner->run('Theme locale file present', function () use ($config) {
    $path = '/var/www/html/plugins/themes/' . $config['themePath'] . '/locale/en/locale.po';
    if (!file_exists($path)) {
        throw new RuntimeException("Missing locale: $path");
    }
    $content = file_get_contents($path);
    if (!str_contains($content, 'plugins.themes.riarauniversity.name')) {
        throw new RuntimeException('Locale file incomplete');
    }
});

$runner->run('Article page uses riara theme layout', function () use ($config, $runner) {
    $pdo = riara_pdo($config);
    $id = (int) $pdo->query('SELECT submission_id FROM submissions WHERE status=3 ORDER BY submission_id DESC LIMIT 1')->fetchColumn();
    if (!$id) {
        throw new RuntimeException('No published submission');
    }
    $html = $runner->assertHttpOk(riara_journal_url($config, "article/view/$id"), 'Article page');
    $runner->assertContains('riara-page--article', $html, 'Article page class');
    $runner->assertContains('riara-article-hero', $html, 'Article hero');
    $runner->assertContains('riara-citation', $html, 'Citation block');
    if (str_contains($html, 'riara-csl')) {
        $runner->assertContains('riara-csl', $html, 'CSL citation formats');
    }
    $runner->assertContains('obj_article_details', $html, 'Article details');
});

$runner->run('Issue page uses riara issue hero', function () use ($config, $runner) {
    $pdo = riara_pdo($config);
    $issueId = (int) $pdo->query('SELECT issue_id FROM issues WHERE published=1 ORDER BY issue_id ASC LIMIT 1')->fetchColumn();
    if (!$issueId) {
        throw new RuntimeException('No published issue');
    }
    $html = $runner->assertHttpOk(riara_journal_url($config, "issue/view/$issueId"), 'Issue page');
    $runner->assertContains('riara-issue-hero', $html, 'Issue hero');
    $runner->assertContains('riara-issue-toc-section', $html, 'Issue TOC section');
    $runner->assertContains('riara-issue-toc-heading', $html, 'Issue TOC heading');
});

$runner->run('Current issue page resolves when configured', function () use ($config, $runner) {
    $pdo = riara_pdo($config);
    require_once __DIR__ . '/riara-ojs-lib.php';
    $journalId = riara_journal_id_from_path($pdo, $config['journalPath']);
    $stmt = $pdo->prepare("SELECT setting_value FROM journal_settings WHERE journal_id=? AND setting_name='currentIssueId'");
    $stmt->execute([$journalId]);
    $currentIssueId = $stmt->fetchColumn();
    if (!$currentIssueId) {
        echo "    (skipped — currentIssueId not set)\n";
        return;
    }
    $html = $runner->assertHttpOk(riara_journal_url($config, 'issue/current'), 'Current issue');
    $runner->assertContains('riara-issue-hero', $html, 'Current issue hero');
    $runner->assertContains('riara-issue-toc-section', $html, 'Current issue TOC section');
    $runner->assertNotContains('current.noCurrentIssue', $html, 'No missing current issue warning');
});

$runner->run('Announcements use riara card layout', function () use ($config, $runner) {
    $html = $runner->assertHttpOk(riara_journal_url($config, 'announcement'), 'Announcements page');
    $runner->assertContains('riara-announcements-page__grid', $html, 'Announcements responsive grid');
    $runner->assertContains('riara-announcement-card', $html, 'Announcement cards');
});

$runner->run('Register page matches login auth features', function () use ($config, $runner) {
    $html = $runner->assertHttpOk(riara_journal_url($config, 'user/register'), 'Register page');
    $runner->assertContains('riara-auth--immersive', $html, 'Immersive register layout');
    $runner->assertContains('riara-auth__highlights', $html, 'Auth highlight list');
    $runner->assertContains('riara-auth__section', $html, 'Register form sections');
});

$runner->run('Journal policies hub loads', function () use ($config, $runner) {
    $html = $runner->assertHttpOk(riara_journal_url($config, 'about/policies'), 'Policies hub');
    $runner->assertContains('riara-policy-hub', $html, 'Policy hub layout');
    $runner->assertContains('riara-page--static', $html, 'Static page theme');
});

$runner->run('Indexing page loads with identifiers', function () use ($config, $runner) {
    $html = $runner->assertHttpOk(riara_journal_url($config, 'about/indexing'), 'Indexing page');
    $runner->assertContains('OAI-PMH', $html, 'OAI reference');
    $runner->assertContains('DOI prefix', $html, 'DOI prefix');
});

$runner->run('Journal metrics page loads', function () use ($config, $runner) {
    $html = $runner->assertHttpOk(riara_journal_url($config, 'about/metrics'), 'Metrics page');
    $runner->assertContains('riara-metrics', $html, 'Metrics layout');
});

$policyPages = [
    'Ethics' => 'about/ethics',
    'Peer review' => 'about/peer-review',
    'Copyright' => 'about/copyright',
    'Preservation' => 'about/preservation',
];

foreach ($policyPages as $label => $path) {
    $runner->run("Policy page loads: $label", function () use ($config, $runner, $path) {
        $html = $runner->assertHttpOk(riara_journal_url($config, $path), $path);
        $runner->assertContains('riara-page--static', $html, 'Static page theme');
    });
}

$runner->run('XML sitemap responds', function () use ($config, $runner) {
    $html = $runner->assertHttpOk(riara_journal_url($config, 'sitemap'), 'Sitemap');
    $runner->assertContains('urlset', $html, 'Sitemap XML');
});

$runner->run('Submissions page has Riara author guidelines', function () use ($config, $runner) {
    $html = $runner->assertHttpOk(riara_journal_url($config, 'about/submissions'), 'Submissions');
    $runner->assertContains('riara-page--submissions', $html, 'Submissions page class');
    $runner->assertContains('Riara University Journal', $html, 'Riara guidelines copy');
    $runner->assertContains('APA 7', $html, 'Style guidance');
});

$runner->run('Discovery plugins enabled', function () use ($config) {
    $pdo = riara_pdo($config);
    require_once __DIR__ . '/riara-ojs-lib.php';
    $journalId = riara_journal_id_from_path($pdo, $config['journalPath']);
    foreach (['webfeedplugin', 'dublincoremetaplugin', 'googlescholarplugin', 'staticpagesplugin'] as $plugin) {
        $stmt = $pdo->prepare("SELECT setting_value FROM plugin_settings WHERE plugin_name=? AND context_id=? AND setting_name='enabled'");
        $stmt->execute([$plugin, $journalId]);
        if ($stmt->fetchColumn() !== '1') {
            throw new RuntimeException("Plugin not enabled: $plugin");
        }
    }
});

$runner->run('Indexing page lists sitemap', function () use ($config, $runner) {
    $html = $runner->assertHttpOk(riara_journal_url($config, 'about/indexing'), 'Indexing page');
    $runner->assertContains('/sitemap', $html, 'Sitemap link');
});

$runner->run('Citation Style Language plugin enabled', function () use ($config) {
    $pdo = riara_pdo($config);
    require_once __DIR__ . '/riara-ojs-lib.php';
    $journalId = riara_journal_id_from_path($pdo, $config['journalPath']);
    $stmt = $pdo->prepare("SELECT setting_value FROM plugin_settings WHERE plugin_name='citationstylelanguageplugin' AND context_id=? AND setting_name='enabled'");
    $stmt->execute([$journalId]);
    if ($stmt->fetchColumn() !== '1') {
        throw new RuntimeException('Citation Style Language plugin not enabled');
    }
});

$runner->run('Published article has DOI when prefix configured', function () use ($config, $runner) {
    $pdo = riara_pdo($config);
    require_once __DIR__ . '/riara-ojs-lib.php';
    $journalId = riara_journal_id_from_path($pdo, $config['journalPath']);
    $stmt = $pdo->prepare("SELECT setting_value FROM journal_settings WHERE journal_id=? AND setting_name='doiPrefix'");
    $stmt->execute([$journalId]);
    $prefix = $stmt->fetchColumn();
    if (!$prefix) {
        echo "    (skipped — doiPrefix not set)\n";
        return;
    }
    $id = (int) $pdo->query('SELECT submission_id FROM submissions WHERE status=3 ORDER BY submission_id DESC LIMIT 1')->fetchColumn();
    if (!$id) {
        throw new RuntimeException('No published submission');
    }
    $html = $runner->assertHttpOk(riara_journal_url($config, "article/view/$id"), 'Article DOI');
    $runner->assertContains('doi.org', $html, 'Resolvable DOI link');
});

$runner->run('Search page uses riara theme layout', function () use ($config, $runner) {
    $html = $runner->assertHttpOk(riara_journal_url($config, 'search'), 'Search page');
    $runner->assertContains('riara-page--search', $html, 'Search page class');
    $runner->assertContains('riara-search--page', $html, 'Search form styling');
});

$runner->run('About page uses riara theme layout', function () use ($config, $runner) {
    $html = $runner->assertHttpOk(riara_journal_url($config, 'about'), 'About page');
    $runner->assertContains('riara-page--about', $html, 'About page class');
    $runner->assertContains('riara-about-layout', $html, 'About sidebar layout');
    $runner->assertNotContains('Open Journal Systems', $html, 'No OJS branding on about page');
});

$runner->run('Platform page uses Riara University branding', function () use ($config, $runner) {
    $html = $runner->assertHttpOk(
        riara_journal_url($config, 'about/aboutThisPublishingSystem'),
        'Platform page'
    );
    $runner->assertContains('riara-page--platform', $html, 'Platform page class');
    $runner->assertContains('Riara University Publishing', $html, 'Platform title');
    $runner->assertNotContains('Open Journal Systems', $html, 'No OJS branding on platform page');
    $runner->assertNotContains('pkp_brand_footer', $html, 'No PKP footer brand');
});

$runner->run('Submissions page uses riara theme layout', function () use ($config, $runner) {
    $html = $runner->assertHttpOk(riara_journal_url($config, 'about/submissions'), 'Submissions page');
    $runner->assertContains('riara-page--submissions', $html, 'Submissions page class');
    $runner->assertContains('riara-about-layout', $html, 'About sidebar layout');
});

$runner->run('Login page uses riara auth layout', function () use ($config, $runner) {
    $html = $runner->assertHttpOk(riara_journal_url($config, 'login'), 'Login page');
    $runner->assertContains('riara-page--auth', $html, 'Auth page class');
    $runner->assertContains('riara-auth--immersive', $html, 'Immersive auth layout');
    $runner->assertContains('riara-auth__form-card', $html, 'Auth form card');
    $runner->assertContains('riara-brand-bar', $html, 'Brand bar in header');
});

$runner->run('Lost password page uses riara auth layout', function () use ($config, $runner) {
    $html = $runner->assertHttpOk(riara_journal_url($config, 'login/lostPassword'), 'Lost password page');
    $runner->assertContains('riara-page--auth', $html, 'Auth page class');
    $runner->assertContains('riara-auth--immersive', $html, 'Immersive reset layout');
    $runner->assertContains('riara-auth__steps', $html, 'Reset password steps');
    $runner->assertContains('lost_password', $html, 'Lost password form');
});

$runner->run('Announcements page uses riara theme layout', function () use ($config, $runner) {
    $html = $runner->assertHttpOk(riara_journal_url($config, 'announcement'), 'Announcements page');
    $runner->assertContains('riara-page--announcements', $html, 'Announcements page class');
    $runner->assertContains('riara-announcements-page', $html, 'Announcements page wrapper');
});

$runner->run('Editorial history page uses riara theme layout', function () use ($config, $runner) {
    $html = $runner->assertHttpOk(riara_journal_url($config, 'about/editorialHistory'), 'Editorial history page');
    $runner->assertContains('riara-page--history', $html, 'Editorial history page class');
    $runner->assertContains('riara-about-layout', $html, 'About sidebar layout');
});

$runner->run('Privacy page uses riara theme layout', function () use ($config, $runner) {
    $html = $runner->assertHttpOk(riara_journal_url($config, 'about/privacy'), 'Privacy page');
    $runner->assertContains('riara-page--privacy', $html, 'Privacy page class');
    $runner->assertContains('riara-about-layout', $html, 'About sidebar layout');
});

$runner->run('Contact page uses riara theme layout', function () use ($config, $runner) {
    $html = $runner->assertHttpOk(riara_journal_url($config, 'about/contact'), 'Contact page');
    $runner->assertContains('riara-page--contact', $html, 'Contact page class');
    $runner->assertContains('riara-about-layout', $html, 'About sidebar layout');
});

$runner->run('Issue archive uses riara theme layout', function () use ($config, $runner) {
    $html = $runner->assertHttpOk(riara_journal_url($config, 'issue/archive'), 'Archive page');
    $runner->assertContains('riara-page--archive', $html, 'Archive page class');
    $runner->assertContains('riara-issue-card', $html, 'Archive issue cards');
});

$runner->run('Public pages Riara branding sweep', function () use ($config, $runner) {
    $routes = [
        'Home' => '',
        'Login' => 'login',
        'Lost password' => 'login/lostPassword',
        'Register' => 'user/register',
        'About' => 'about',
        'Submissions' => 'about/submissions',
        'Platform' => 'about/aboutThisPublishingSystem',
        'Search' => 'search',
        'Announcements' => 'announcement',
        'Editorial history' => 'about/editorialHistory',
        'Contact' => 'about/contact',
        'Privacy' => 'about/privacy',
    ];
    foreach ($routes as $label => $path) {
        $html = $runner->assertHttpOk(riara_journal_url($config, $path), $label);
        riara_assert_public_branding($runner, $html, $label);
    }
});

$runner->run('Author and reviewer have correct roles', function () use ($config) {
    $pdo = riara_pdo($config);
    require_once __DIR__ . '/riara-ojs-lib.php';
    $journalId = riara_journal_id_from_path($pdo, $config['journalPath']);
    foreach (['author' => 'Author', 'reviewer' => 'Reviewer'] as $username => $roleName) {
        $stmt = $pdo->prepare(
            'SELECT ug.role_id FROM users u
             JOIN user_user_groups uug ON u.user_id = uug.user_id
             JOIN user_groups ug ON uug.user_group_id = ug.user_group_id
             WHERE u.username = ? AND ug.context_id = ?'
        );
        $stmt->execute([$username, $journalId]);
        $roles = $stmt->fetchAll(PDO::FETCH_COLUMN);
        if (empty($roles)) {
            throw new RuntimeException("$username has no journal roles");
        }
    }
});

$runner->run('Published article reachable', function () use ($config, $runner) {
    $pdo = riara_pdo($config);
    $id = (int) $pdo->query('SELECT submission_id FROM submissions WHERE status=3 ORDER BY submission_id DESC LIMIT 1')->fetchColumn();
    if (!$id) {
        throw new RuntimeException('No published submission to verify');
    }
    $runner->assertHttpOk(riara_journal_url($config, "article/view/$id"), 'Published article');
});

// --- Editorial workflow ---
if (!getenv('OJS_SKIP_WORKFLOW')) {
    echo "\n[Editorial workflow]\n";
    $runner->run('Author → reviewer → publisher pipeline', function () use (&$workflowSubmissionId) {
        ob_start();
        $code = 0;
        passthru('php ' . escapeshellarg(__DIR__ . '/workflow-runner.php'), $code);
        $output = ob_get_clean();
        if ($code !== 0) {
            throw new RuntimeException("Workflow runner failed:\n$output");
        }
        if (!preg_match('/"submissionId":\s*(\d+)/', $output, $m)) {
            throw new RuntimeException("Could not parse workflow output:\n$output");
        }
        $workflowSubmissionId = (int) $m[1];
        echo "    (created submission $workflowSubmissionId)\n";
    });

    if ($workflowSubmissionId) {
        $runner->run('Newly published article HTTP 200', function () use ($config, $runner, $workflowSubmissionId) {
            $html = $runner->assertHttpOk(
                riara_journal_url($config, "article/view/$workflowSubmissionId"),
                'Workflow article'
            );
            $runner->assertContains('riara-page--article', $html, 'Workflow article uses theme');
        });

        $runner->run('Workflow article has PDF galley', function () use ($config, $workflowSubmissionId) {
            require_once __DIR__ . '/riara-ojs-lib.php';
            $pdo = riara_pdo($config);
            $count = riara_published_galley_count($pdo, $workflowSubmissionId);
            if ($count < 1) {
                throw new RuntimeException("Expected at least one galley, found $count");
            }
        });

        $runner->run('Workflow emails logged for submission', function () use ($config, $workflowSubmissionId) {
            require_once __DIR__ . '/riara-ojs-lib.php';
            $pdo = riara_pdo($config);
            $total = riara_submission_email_log_count($pdo, $workflowSubmissionId);
            if ($total < 4) {
                throw new RuntimeException("Expected at least 4 workflow emails, found $total");
            }
            $ack = riara_submission_email_log_count($pdo, $workflowSubmissionId, 0x20000002);
            if ($ack < 1) {
                throw new RuntimeException('Missing submission acknowledgement email log entry');
            }
            $decisions = riara_submission_email_log_count($pdo, $workflowSubmissionId, 0x30000001);
            if ($decisions < 3) {
                throw new RuntimeException("Expected at least 3 decision notification emails, found $decisions");
            }
            echo "    ($total emails logged: $ack ack, $decisions decisions)\n";
        });
    }
} else {
    echo "\n[Editorial workflow] skipped (OJS_SKIP_WORKFLOW)\n";
}

// --- Google OAuth ---
echo "\n[Google OAuth]\n";
$runner->run('Google OAuth plugin files mounted', function () {
    $dir = '/var/www/html/plugins/generic/googleOAuth';
    foreach ([
        'GoogleOAuthPlugin.php',
        'GoogleOAuthHandler.php',
        'classes/DomainRoleResolver.php',
        'classes/GoogleOAuthService.php',
        'locale/en/locale.po',
    ] as $file) {
        if (!file_exists("$dir/$file")) {
            throw new RuntimeException("Missing plugin file: $file");
        }
    }
});

$runner->run('DomainRoleResolver maps Riara email domains', function () {
    riara_bootstrap_ojs('riara');
    $resolver = \APP\plugins\generic\googleOAuth\classes\DomainRoleResolver::class;
    if ($resolver::resolveRoleType('alice@stu.riarauniversity.ac.ke') !== $resolver::ROLE_STUDENT) {
        throw new RuntimeException('Student domain not mapped');
    }
    if ($resolver::resolveRoleType('bob@riarauniversity.ac.ke') !== $resolver::ROLE_STAFF) {
        throw new RuntimeException('Staff domain not mapped');
    }
    if ($resolver::resolveRoleType('guest@gmail.com') !== $resolver::ROLE_EXTERNAL) {
        throw new RuntimeException('External domain not mapped');
    }
    if (!$resolver::isUniversityAffiliated('carol@riarauniversity.ac.ke')) {
        throw new RuntimeException('Staff should be university affiliated');
    }
    if ($resolver::isUniversityAffiliated('guest@gmail.com')) {
        throw new RuntimeException('External should not be university affiliated');
    }
});

$runner->run('Google OAuth plugin registered and enabled', function () use ($config) {
    $pdo = riara_pdo($config);
    require_once __DIR__ . '/riara-ojs-lib.php';
    $journalId = riara_journal_id_from_path($pdo, $config['journalPath']);
    $stmt = $pdo->prepare("SELECT version_id FROM versions WHERE product_type='plugins.generic' AND product='googleOAuth'");
    $stmt->execute();
    if (!$stmt->fetchColumn()) {
        throw new RuntimeException('googleOAuth not in versions table');
    }
    $stmt = $pdo->prepare("SELECT setting_value FROM plugin_settings WHERE plugin_name='googleoauthplugin' AND context_id=? AND setting_name='enabled'");
    $stmt->execute([$journalId]);
    if ($stmt->fetchColumn() !== '1') {
        throw new RuntimeException('googleoauthplugin not enabled');
    }
});

$runner->run('Student and Staff user groups exist', function () use ($config) {
    $pdo = riara_pdo($config);
    require_once __DIR__ . '/riara-ojs-lib.php';
    $journalId = riara_journal_id_from_path($pdo, $config['journalPath']);
    foreach (['Student', 'Staff'] as $name) {
        $stmt = $pdo->prepare(
            'SELECT ug.user_group_id
             FROM user_groups ug
             JOIN user_group_settings ugs ON ug.user_group_id = ugs.user_group_id
             WHERE ug.context_id = ? AND ugs.setting_name = "name" AND ugs.locale = "en" AND ugs.setting_value = ?'
        );
        $stmt->execute([$journalId, $name]);
        if (!$stmt->fetchColumn()) {
            throw new RuntimeException("Missing user group: $name");
        }
    }
});

$runner->run('Login page shows Google sign-in when configured', function () use ($config, $runner) {
    $pdo = riara_pdo($config);
    require_once __DIR__ . '/riara-ojs-lib.php';
    $journalId = riara_journal_id_from_path($pdo, $config['journalPath']);
    $stmt = $pdo->prepare("SELECT setting_value FROM plugin_settings WHERE plugin_name='googleoauthplugin' AND context_id=? AND setting_name='clientId'");
    $stmt->execute([$journalId]);
    $clientId = (string) $stmt->fetchColumn();
    if ($clientId === '') {
        echo "    (skipped — Google OAuth client not configured)\n";
        return;
    }
    $html = $runner->assertHttpOk(riara_journal_url($config, 'login'), 'Login page');
    $runner->assertContains('riara-btn--google', $html, 'Google sign-in button');
    $runner->assertContains('Sign in with Google', $html, 'Google sign-in label');
});

$runner->run('Register page shows Google sign-in when configured', function () use ($config, $runner) {
    $pdo = riara_pdo($config);
    require_once __DIR__ . '/riara-ojs-lib.php';
    $journalId = riara_journal_id_from_path($pdo, $config['journalPath']);
    $stmt = $pdo->prepare("SELECT setting_value FROM plugin_settings WHERE plugin_name='googleoauthplugin' AND context_id=? AND setting_name='clientId'");
    $stmt->execute([$journalId]);
    if ((string) $stmt->fetchColumn() === '') {
        echo "    (skipped — Google OAuth client not configured)\n";
        return;
    }
    $html = $runner->assertHttpOk(riara_journal_url($config, 'user/register'), 'Register page');
    $runner->assertContains('riara-btn--google', $html, 'Google sign-in button on register');
});

$runner->run('Google OAuth connect redirects to Google', function () use ($config) {
    $pdo = riara_pdo($config);
    require_once __DIR__ . '/riara-ojs-lib.php';
    $journalId = riara_journal_id_from_path($pdo, $config['journalPath']);
    $stmt = $pdo->prepare("SELECT setting_value FROM plugin_settings WHERE plugin_name='googleoauthplugin' AND context_id=? AND setting_name='clientId'");
    $stmt->execute([$journalId]);
    if ((string) $stmt->fetchColumn() === '') {
        echo "    (skipped — Google OAuth client not configured)\n";
        return;
    }

    $url = riara_journal_url($config, 'googleoauth/connect');
    $context = stream_context_create([
        'http' => [
            'method' => 'GET',
            'timeout' => 15,
            'ignore_errors' => true,
            'follow_location' => 0,
            'header' => "User-Agent: RiaraTestSuite/1.0\r\n",
        ],
    ]);
    $body = @file_get_contents($url, false, $context);
    $status = 0;
    $location = '';
    foreach ($http_response_header ?? [] as $header) {
        if (preg_match('/^HTTP\/\S+\s+(\d+)/', $header, $m)) {
            $status = (int) $m[1];
        }
        if (stripos($header, 'Location:') === 0) {
            $location = trim(substr($header, 9));
        }
    }
    if ($status < 300 || $status >= 400) {
        throw new RuntimeException("Expected redirect from connect endpoint (HTTP $status)");
    }
    if (!str_contains($location, 'accounts.google.com/o/oauth2')) {
        throw new RuntimeException("Expected Google OAuth redirect, got: $location");
    }
});

$runner->run('Faculty journal clone works when configured', function () use ($config, $runner) {
    $faculties = getenv('OJS_FACULTY_JOURNALS');
    if ($faculties === false || $faculties === '') {
        echo "    (skipped — OJS_FACULTY_JOURNALS not set)\n";
        return;
    }
    $pdo = riara_pdo($config);
    $first = explode('|', $faculties)[0] ?? '';
    if (!str_contains($first, ':')) {
        throw new RuntimeException('Invalid OJS_FACULTY_JOURNALS format');
    }
    [$path, $name] = array_map('trim', explode(':', $first, 2));
    $stmt = $pdo->prepare('SELECT journal_id FROM journals WHERE path = ?');
    $stmt->execute([$path]);
    $journalId = (int) $stmt->fetchColumn();
    if ($journalId < 1) {
        throw new RuntimeException("Faculty journal not found: $path");
    }
    $html = $runner->assertHttpOk(riara_context_url($config, $path), "Faculty journal home: $path");
    $runner->assertContains('riara-hero', $html, 'Faculty journal uses Riara theme');
    $runner->assertContains('stylesheet', $html, 'Faculty journal theme stylesheet');
    $cssUrl = riara_context_url($config, $path) . '/$$$call$$$/page/page/css?name=stylesheet';
    $cssBody = @file_get_contents($cssUrl);
    if ($cssBody === false || strlen($cssBody) < 1000) {
        throw new RuntimeException('Faculty journal stylesheet failed to compile');
    }
    $stmt = $pdo->prepare("SELECT setting_value FROM plugin_settings WHERE plugin_name='defaultthemeplugin' AND context_id=? AND setting_name='enabled'");
    $stmt->execute([$journalId]);
    if ($stmt->fetchColumn() !== '1') {
        throw new RuntimeException("Default parent theme not enabled on faculty journal: $path");
    }
    $stmt = $pdo->prepare("SELECT setting_value FROM plugin_settings WHERE plugin_name='googleoauthplugin' AND context_id=? AND setting_name='enabled'");
    $loginHtml = $runner->assertHttpOk(riara_context_url($config, $path, 'login'), "Faculty journal login: $path");
    $runner->assertContains('riara-btn--google', $loginHtml, 'Faculty journal Google sign-in');
});

$runner->run('Site index lists Riara journals hub', function () use ($config, $runner) {
    $pdo = riara_pdo($config);
    $journalCount = (int) $pdo->query('SELECT COUNT(*) FROM journals WHERE enabled = 1')->fetchColumn();
    if ($journalCount < 2) {
        echo "    (skipped — fewer than 2 journals)\n";
        return;
    }
    $html = $runner->assertHttpOk(riara_site_url($config, 'index'), 'Site index');
    $runner->assertContains('riara-site-hub', $html, 'Site hub wrapper');
    $runner->assertContains('riara-site-hero--editorial', $html, 'Editorial site hero');
    $runner->assertContains('riara-site-catalog', $html, 'Journal catalog');
    $runner->assertContains('riara-site-journal-card', $html, 'Journal cards');
    $runner->assertContains('/index.php/law', $html, 'Law journal link');
});

$runner->run('Submission restriction policy uses university domains', function () use ($config) {
    $pdo = riara_pdo($config);
    require_once __DIR__ . '/riara-ojs-lib.php';
    $journalId = riara_journal_id_from_path($pdo, $config['journalPath']);
    $resolver = \APP\plugins\generic\googleOAuth\classes\DomainRoleResolver::class;

    $pdo->prepare(
        'INSERT INTO plugin_settings (plugin_name, context_id, setting_name, setting_value, setting_type)
         VALUES (?, ?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value), setting_type = VALUES(setting_type)'
    )->execute(['googleoauthplugin', $journalId, 'restrictSubmissionsToUniversity', '1', 'bool']);

    if (!$resolver::isUniversityAffiliated('student@stu.riarauniversity.ac.ke')) {
        throw new RuntimeException('Student domain should pass submission restriction');
    }
    if (!$resolver::isUniversityAffiliated('staff@riarauniversity.ac.ke')) {
        throw new RuntimeException('Staff domain should pass submission restriction');
    }
    if ($resolver::isUniversityAffiliated('external@gmail.com')) {
        throw new RuntimeException('External domain should fail submission restriction');
    }

    $pdo->prepare(
        'INSERT INTO plugin_settings (plugin_name, context_id, setting_name, setting_value, setting_type)
         VALUES (?, ?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value), setting_type = VALUES(setting_type)'
    )->execute(['googleoauthplugin', $journalId, 'restrictSubmissionsToUniversity', '0', 'bool']);
});

// --- OAI ---
echo "\n[Integrations]\n";
$runner->run('OAI endpoint responds', function () use ($config, $runner) {
    $html = $runner->assertHttpOk(riara_journal_url($config, 'oai?verb=Identify'), 'OAI Identify');
    $runner->assertContains('OAI-PMH', $html, 'OAI-PMH response');
});

$runner->run('OAI ListRecords returns published items', function () use ($config, $runner) {
    $html = $runner->assertHttpOk(riara_journal_url($config, 'oai?verb=ListRecords&metadataPrefix=oai_dc'), 'OAI ListRecords');
    $pdo = riara_pdo($config);
    $count = (int) $pdo->query('SELECT COUNT(*) FROM submissions WHERE status=3')->fetchColumn();
    if ($count > 0 && !str_contains($html, '<record>')) {
        throw new RuntimeException('OAI ListRecords has no records despite published submissions');
    }
});

$runner->run('RSS/Atom feed gateway responds', function () use ($config, $runner) {
    $runner->assertHttpOk(riara_journal_url($config, 'gateway/plugin/WebFeedGatewayPlugin/atom'), 'Atom feed');
});

exit($runner->printSummary());
