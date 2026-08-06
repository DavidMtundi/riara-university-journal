<?php

/**
 * OJS Riara — enable university-journal plugins, metadata, static pages, and DOIs.
 */

require __DIR__ . '/script-db.php';
require __DIR__ . '/riara-ojs-lib.php';

$config = require __DIR__ . '/test-config.php';
$pdo = riara_script_pdo();
$journalId = riara_journal_id_from_path($pdo, $config['journalPath']);
$journalPath = $config['journalPath'];
$baseUrl = '/index.php/' . $journalPath;

function riara_env(string $key, string $default = ''): string
{
    $value = getenv($key);
    return ($value !== false && $value !== '') ? $value : $default;
}

function riara_upsert_journal_setting(PDO $pdo, int $journalId, string $name, string $value, string $locale = ''): void
{
    $pdo->prepare(
        'INSERT INTO journal_settings (journal_id, locale, setting_name, setting_value)
         VALUES (?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)'
    )->execute([$journalId, $locale, $name, $value]);
}

function riara_enable_plugin(PDO $pdo, string $pluginName, ?int $contextId = null, array $settings = []): void
{
    $pdo->prepare(
        'INSERT INTO plugin_settings (plugin_name, context_id, setting_name, setting_value, setting_type)
         VALUES (?, ?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value), setting_type = VALUES(setting_type)'
    )->execute([$pluginName, $contextId, 'enabled', '1', 'bool']);

    foreach ($settings as $name => $spec) {
        $pdo->prepare(
            'INSERT INTO plugin_settings (plugin_name, context_id, setting_name, setting_value, setting_type)
             VALUES (?, ?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value), setting_type = VALUES(setting_type)'
        )->execute([$pluginName, $contextId, $name, (string) $spec['value'], $spec['type']]);
    }
}

function riara_disable_plugin(PDO $pdo, string $pluginName, ?int $contextId = null): void
{
    $pdo->prepare(
        'INSERT INTO plugin_settings (plugin_name, context_id, setting_name, setting_value, setting_type)
         VALUES (?, ?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)'
    )->execute([$pluginName, $contextId, 'enabled', '0', 'bool']);
}

function riara_upsert_static_page(PDO $pdo, int $journalId, string $path, string $title, string $content, string $locale = 'en'): void
{
    $stmt = $pdo->prepare('SELECT static_page_id FROM static_pages WHERE context_id = ? AND path = ?');
    $stmt->execute([$journalId, $path]);
    $pageId = (int) $stmt->fetchColumn();

    if ($pageId < 1) {
        $pdo->prepare('INSERT INTO static_pages (path, context_id) VALUES (?, ?)')->execute([$path, $journalId]);
        $pageId = (int) $pdo->lastInsertId();
        echo "Static page created: $path (id $pageId)\n";
    }

    foreach (['title' => $title, 'content' => $content] as $setting => $value) {
        $pdo->prepare(
            'INSERT INTO static_page_settings (static_page_id, locale, setting_name, setting_value, setting_type)
             VALUES (?, ?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)'
        )->execute([$pageId, $locale, $setting, $value, 'string']);
    }
}

function riara_mint_publication_dois(PDO $pdo, int $journalId, string $prefix): int
{
    $stmt = $pdo->prepare(
        'SELECT p.publication_id, p.submission_id
         FROM publications p
         INNER JOIN submissions s ON s.submission_id = p.submission_id
         WHERE s.context_id = ? AND s.status = 3 AND (p.doi_id IS NULL OR p.doi_id = 0)
         ORDER BY p.publication_id'
    );
    $stmt->execute([$journalId]);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $minted = 0;

    foreach ($rows as $row) {
        $suffix = 'article.' . $row['submission_id'];
        $doi = rtrim($prefix, '/') . '/' . $suffix;

        $check = $pdo->prepare('SELECT doi_id FROM dois WHERE context_id = ? AND doi = ?');
        $check->execute([$journalId, $doi]);
        $doiId = (int) $check->fetchColumn();

        if ($doiId < 1) {
            $pdo->prepare('INSERT INTO dois (context_id, doi, status) VALUES (?, ?, 3)')->execute([$journalId, $doi]);
            $doiId = (int) $pdo->lastInsertId();
        }

        $pdo->prepare('UPDATE publications SET doi_id = ? WHERE publication_id = ?')->execute([$doiId, $row['publication_id']]);
        $minted++;
    }

    return $minted;
}

// ─── Journal metadata ─────────────────────────────────────────────────────────

$onlineIssn = riara_env('OJS_ONLINE_ISSN', 'Pending assignment');
$printIssn = riara_env('OJS_PRINT_ISSN', '');
$doiPrefix = riara_env('OJS_DOI_PREFIX', '10.55555');
$publisher = riara_env('OJS_PUBLISHER', 'Riara University');
$depositorName = riara_env('OJS_CROSSREF_DEPOSITOR_NAME', 'Riara University Journal');
$depositorEmail = riara_env('OJS_CROSSREF_DEPOSITOR_EMAIL', 'dgetaro@riarauniversity.ac.ke');

riara_upsert_journal_setting($pdo, $journalId, 'publisherInstitution', $publisher);
riara_upsert_journal_setting($pdo, $journalId, 'onlineIssn', $onlineIssn);
if ($printIssn !== '') {
    riara_upsert_journal_setting($pdo, $journalId, 'printIssn', $printIssn);
}
riara_upsert_journal_setting($pdo, $journalId, 'doiPrefix', $doiPrefix);
riara_upsert_journal_setting($pdo, $journalId, 'registrationAgency', 'crossrefplugin');
riara_upsert_journal_setting($pdo, $journalId, 'enableDois', '1');
riara_upsert_journal_setting($pdo, $journalId, 'enabledDoiTypes', '["publication"]');

// ─── Author guidelines & submission copy (locale: en) ─────────────────────────

$submissionsUrl = $baseUrl . '/about/submissions';
$policiesUrl = $baseUrl . '/about/policies';
$ethicsUrl = $baseUrl . '/about/ethics';

$authorGuidelines = <<<HTML
<h3>Preparing your manuscript</h3>
<p>Riara University Journal welcomes original research, review articles, and practice-oriented papers from Riara faculty, students, and collaborating scholars. Before submitting, read our <a href="{$policiesUrl}">journal policies</a> and <a href="{$ethicsUrl}">publication ethics</a> statements.</p>
<h4>Manuscript format</h4>
<ul>
<li>Submit in <strong>Microsoft Word (.docx)</strong> or <strong>PDF</strong> unless a special issue calls for another format.</li>
<li>Use a clear title page with author names, affiliations, and ORCID iDs where available.</li>
<li>Include an abstract of 150–250 words and 4–6 keywords.</li>
<li>Follow APA 7th edition for in-text citations and references unless your discipline requires another style (note this in your cover letter).</li>
<li>Figures and tables must be numbered, titled, and cited in the text. Supply high-resolution images separately when requested.</li>
</ul>
<h4>Length</h4>
<ul>
<li>Research articles: typically 4,000–8,000 words (excluding references).</li>
<li>Review articles and case studies: up to 10,000 words with editor approval.</li>
</ul>
<h4>Ethics &amp; declarations</h4>
<ul>
<li>Disclose funding sources and conflicts of interest on the submission form.</li>
<li>Studies involving human participants require ethics approval; state the approving body and reference number.</li>
<li>Authors are responsible for securing permission to reproduce third-party material.</li>
</ul>
<h4>What happens after submission</h4>
<p>All manuscripts are screened by an editor, sent for double-blind peer review where appropriate, and published open access under <a href="{$baseUrl}/about/copyright">CC BY 4.0</a> unless otherwise agreed. Track progress through your author dashboard after <a href="{$baseUrl}/login">logging in</a>.</p>
HTML;

$authorInformation = <<<HTML
<p>Interested in submitting to <em>Riara University Journal</em>? Review the <a href="{$baseUrl}/about">About the Journal</a> page, read the <a href="{$submissionsUrl}">Author Guidelines</a>, and consult our <a href="{$policiesUrl}">policies hub</a>. Register or <a href="{$baseUrl}/login">log in</a> to begin a new submission.</p>
HTML;

$beginSubmissionHelp = <<<HTML
<p>Thank you for submitting to Riara University Journal. You will upload your manuscript, identify co-authors, and provide metadata such as the title, abstract, and keywords.</p>
<p>Please read the <a href="{$submissionsUrl}">Author Guidelines</a> and confirm each item on the submission checklist before you submit. You may save your work and return later.</p>
HTML;

$submissionChecklist = <<<HTML
<p>All submissions must meet the following requirements.</p>
<ul>
<li>This submission meets the requirements in the <a href="{$submissionsUrl}">Author Guidelines</a>.</li>
<li>This submission has not been previously published and is not under review elsewhere.</li>
<li>All authors have approved the manuscript and meet authorship criteria.</li>
<li>References have been checked for accuracy and completeness (APA 7 unless otherwise stated).</li>
<li>Tables and figures are numbered, labelled, and cited in the text.</li>
<li>Ethics approval and funding disclosures are included where applicable.</li>
<li>Permission has been obtained for any third-party material requiring reproduction rights.</li>
</ul>
HTML;

foreach ([
    'authorGuidelines' => $authorGuidelines,
    'authorInformation' => $authorInformation,
    'beginSubmissionHelp' => $beginSubmissionHelp,
    'submissionChecklist' => $submissionChecklist,
] as $name => $value) {
    riara_upsert_journal_setting($pdo, $journalId, $name, $value, 'en');
}
echo "Author guidelines and submission copy updated\n";

// ORCID — enable when credentials are supplied
$orcidClientId = riara_env('OJS_ORCID_CLIENT_ID');
$orcidClientSecret = riara_env('OJS_ORCID_CLIENT_SECRET');
if ($orcidClientId !== '' && $orcidClientSecret !== '') {
    riara_upsert_journal_setting($pdo, $journalId, 'orcidEnabled', '1');
    riara_upsert_journal_setting($pdo, $journalId, 'orcidClientId', $orcidClientId);
    riara_upsert_journal_setting($pdo, $journalId, 'orcidClientSecret', $orcidClientSecret);
    riara_upsert_journal_setting($pdo, $journalId, 'orcidSendMailToAuthorsOnPublication', '1');
    echo "ORCID enabled (client id configured)\n";
} else {
    riara_upsert_journal_setting($pdo, $journalId, 'orcidEnabled', '0');
}

// ─── Plugins ──────────────────────────────────────────────────────────────────

$plugins = [
    'citationstylelanguageplugin' => [
        'primaryCitationStyle' => ['value' => 'apa', 'type' => 'string'],
    ],
    'recommendbyauthorplugin' => [],
    'recommendbysimilarityplugin' => [],
    'staticpagesplugin' => [],
    'crossrefplugin' => [
        'depositorName' => ['value' => $depositorName, 'type' => 'string'],
        'depositorEmail' => ['value' => $depositorEmail, 'type' => 'string'],
        'testMode' => ['value' => riara_env('OJS_CROSSREF_TEST_MODE', '1'), 'type' => 'bool'],
    ],
    'creditplugin' => [],
    'pflplugin' => [],
    'dublincoremetaplugin' => [],
    'googlescholarplugin' => [],
    'webfeedplugin' => [
        'displayPage' => ['value' => 'homepage', 'type' => 'string'],
        'recentItems' => ['value' => '30', 'type' => 'int'],
        'displayItems' => ['value' => '1', 'type' => 'bool'],
        'includeIdentifiers' => ['value' => '0', 'type' => 'bool'],
    ],
    'htmlarticlegalleyplugin' => [],
    'pdfjsviewerplugin' => [],
    'lensgalleyplugin' => [],
    'jatstemplateplugin' => [],
];

$gaId = riara_env('OJS_GOOGLE_ANALYTICS_ID');
if ($gaId !== '') {
    $plugins['googleanalyticsplugin'] = [
        'googleAnalyticsSiteId' => ['value' => $gaId, 'type' => 'string'],
    ];
}

foreach ($plugins as $pluginName => $settings) {
    riara_enable_plugin($pdo, $pluginName, $journalId, $settings);
    echo "Enabled plugin: $pluginName\n";
}

riara_disable_plugin($pdo, 'riarathemeplugin', $journalId);
riara_disable_plugin($pdo, 'riarathemeplugin', null);
riara_enable_plugin($pdo, 'usageeventplugin', null);

// ─── DOIs for published articles ──────────────────────────────────────────────

$minted = riara_mint_publication_dois($pdo, $journalId, $doiPrefix);
if ($minted > 0) {
    echo "Minted DOIs for $minted publication(s) using prefix $doiPrefix\n";
}

// ─── Static pages ─────────────────────────────────────────────────────────────

$policyHub = <<<HTML
<div class="riara-policy-hub">
<p class="riara-policy-hub__lead">Riara University Journal follows international standards for scholarly publishing, peer review, open access, and long-term preservation.</p>
<ul class="riara-policy-hub__grid">
<li><a class="riara-policy-card" href="{$baseUrl}/about/indexing"><strong>Indexing &amp; discovery</strong><span>Where the journal is listed and how content is harvested.</span></a></li>
<li><a class="riara-policy-card" href="{$baseUrl}/about/ethics"><strong>Publication ethics</strong><span>Research integrity, misconduct, and corrections.</span></a></li>
<li><a class="riara-policy-card" href="{$baseUrl}/about/peer-review"><strong>Peer review policy</strong><span>How manuscripts are evaluated and reviewed.</span></a></li>
<li><a class="riara-policy-card" href="{$baseUrl}/about/copyright"><strong>Copyright &amp; licensing</strong><span>Author rights and reader reuse terms.</span></a></li>
<li><a class="riara-policy-card" href="{$baseUrl}/about/preservation"><strong>Preservation</strong><span>Archiving, backups, and long-term access.</span></a></li>
<li><a class="riara-policy-card" href="{$baseUrl}/about/metrics"><strong>Journal metrics</strong><span>Published content and usage overview.</span></a></li>
</ul>
</div>
HTML;

$indexingPage = <<<HTML
<div class="riara-prose">
<h3>Identifiers</h3>
<ul>
<li><strong>ISSN (online):</strong> {$onlineIssn}</li>
<li><strong>DOI prefix:</strong> {$doiPrefix} (Crossref registration agency)</li>
<li><strong>Publisher:</strong> {$publisher}</li>
</ul>
<h3>Discovery services</h3>
<ul>
<li>Google Scholar (metadata indexing enabled)</li>
<li>OAI-PMH harvest — <code>{$baseUrl}/oai</code></li>
<li>XML sitemap — <a href="{$baseUrl}/sitemap">{$baseUrl}/sitemap</a></li>
<li>RSS/Atom web feed on the journal homepage</li>
<li>Dublin Core metadata embedded in article pages</li>
</ul>
<h3>Archiving &amp; preservation</h3>
<p>This journal supports LOCKSS and CLOCKSS archiving networks. See our <a href="{$baseUrl}/about/preservation">preservation policy</a> for details.</p>
<h3>Indexing applications</h3>
<p>Riara University Journal is preparing applications to DOAJ and other relevant abstracting and indexing databases. Check this page for updates.</p>
</div>
HTML;

$ethicsPage = <<<HTML
<div class="riara-prose">
<p>Riara University Journal is committed to the highest standards of publication ethics and follows principles aligned with the Committee on Publication Ethics (COPE).</p>
<h3>Research integrity</h3>
<ul>
<li>Submissions must be original and not under review elsewhere.</li>
<li>Plagiarism, data fabrication, and image manipulation are grounds for rejection.</li>
<li>Authors must disclose conflicts of interest and funding sources.</li>
</ul>
<h3>Authorship</h3>
<p>All listed authors must meet authorship criteria and approve the final manuscript. Changes to authorship require editorial approval.</p>
<h3>Corrections &amp; retractions</h3>
<p>Errors affecting the scholarly record will be corrected via errata or, when necessary, retraction with a public notice.</p>
</div>
HTML;

$peerReviewPage = <<<HTML
<div class="riara-prose">
<h3>Review model</h3>
<p>Manuscripts undergo rigorous peer review. Reviewers are selected for subject expertise and asked to declare conflicts of interest.</p>
<h3>Process</h3>
<ol>
<li>Editorial screening for scope and quality</li>
<li>Double-blind peer review (reviewer and author identities concealed)</li>
<li>Editorial decision: accept, minor/major revisions, or decline</li>
<li>Production and open access publication</li>
</ol>
<h3>Timelines</h3>
<p>Reviewers are typically given four weeks to complete a review. Authors are notified of decisions through the editorial dashboard.</p>
<h3>Reviewer recognition</h3>
<p>Reviewers may link a verified ORCID iD to their profile. With consent, completed reviews can be deposited to ORCID.</p>
</div>
HTML;

$copyrightPage = <<<HTML
<div class="riara-prose">
<h3>Open access</h3>
<p>Riara University Journal provides immediate open access to published content to support global knowledge exchange.</p>
<h3>Licensing</h3>
<p>Unless otherwise stated, articles are published under <a href="https://creativecommons.org/licenses/by/4.0/" rel="noopener noreferrer">Creative Commons Attribution 4.0 (CC BY 4.0)</a>. Authors retain copyright and grant the journal a license to publish.</p>
<h3>Author self-archiving</h3>
<p>Authors may deposit the accepted manuscript or published version in institutional repositories and share on scholarly networks, with appropriate citation to the version of record.</p>
<h3>Article processing charges</h3>
<p>There are currently <strong>no article processing charges (APCs)</strong> for authors publishing in this journal.</p>
</div>
HTML;

$preservationPage = <<<HTML
<div class="riara-prose">
<h3>Digital preservation</h3>
<p>Riara University maintains this journal on Open Journal Systems with regular database and file backups. Content is intended for long-term public access.</p>
<h3>LOCKSS &amp; CLOCKSS</h3>
<p>The journal participates in distributed preservation networks (LOCKSS/CLOCKSS) to ensure continued availability if the primary site is unavailable.</p>
<h3>Metadata persistence</h3>
<p>Article metadata is exposed via OAI-PMH and DOI registration to support discovery and citation even when file formats evolve.</p>
</div>
HTML;

$metricsPage = '<div class="riara-metrics-placeholder" data-riara-metrics="1"></div>';

$staticPages = [
    'about/policies' => ['Journal policies', $policyHub],
    'about/indexing' => ['Indexing & discovery', $indexingPage],
    'about/ethics' => ['Publication ethics', $ethicsPage],
    'about/peer-review' => ['Peer review policy', $peerReviewPage],
    'about/copyright' => ['Copyright & licensing', $copyrightPage],
    'about/preservation' => ['Preservation policy', $preservationPage],
    'about/metrics' => ['Journal metrics', $metricsPage],
];

foreach ($staticPages as $path => [$title, $content]) {
    riara_upsert_static_page($pdo, $journalId, $path, $title, $content);
}

echo "Journal services bootstrap complete (journal $journalId)\n";
