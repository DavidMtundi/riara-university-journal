<?php

/**
 * Minimal test runner for OJS Riara (no PHPUnit dependency).
 */

class RiaraTestRunner
{
    private array $results = [];

    public function __construct(private readonly string $suite = 'default')
    {
    }

    public function run(string $name, callable $fn): void
    {
        $start = microtime(true);
        try {
            $fn();
            $this->results[] = [
                'name' => $name,
                'status' => 'pass',
                'ms' => (int) round((microtime(true) - $start) * 1000),
            ];
            echo "  PASS  $name\n";
        } catch (Throwable $e) {
            $this->results[] = [
                'name' => $name,
                'status' => 'fail',
                'ms' => (int) round((microtime(true) - $start) * 1000),
                'error' => $e->getMessage(),
            ];
            echo "  FAIL  $name — {$e->getMessage()}\n";
        }
    }

    public function assertTrue(bool $condition, string $message): void
    {
        if (!$condition) {
            throw new RuntimeException($message);
        }
    }

    public function assertContains(string $needle, string $haystack, string $message): void
    {
        if (!str_contains($haystack, $needle)) {
            throw new RuntimeException($message . " (missing: $needle)");
        }
    }

    public function assertNotContains(string $needle, string $haystack, string $message): void
    {
        if (str_contains($haystack, $needle)) {
            throw new RuntimeException($message . " (found: $needle)");
        }
    }

    public function assertHttpOk(string $url, string $message, int $timeout = 15): string
    {
        $context = stream_context_create([
            'http' => [
                'timeout' => $timeout,
                'ignore_errors' => true,
                'header' => "User-Agent: RiaraTestSuite/1.0\r\n",
            ],
        ]);
        $body = @file_get_contents($url, false, $context);
        $status = 0;
        if (isset($http_response_header[0]) && preg_match('/\s(\d{3})\s/', $http_response_header[0], $m)) {
            $status = (int) $m[1];
        }
        if ($status < 200 || $status >= 400 || $body === false) {
            throw new RuntimeException("$message (HTTP $status for $url)");
        }
        return $body;
    }

    public function summary(): array
    {
        $passed = count(array_filter($this->results, fn ($r) => $r['status'] === 'pass'));
        $failed = count($this->results) - $passed;
        return [
            'suite' => $this->suite,
            'total' => count($this->results),
            'passed' => $passed,
            'failed' => $failed,
            'ok' => $failed === 0,
            'results' => $this->results,
        ];
    }

    public function printSummary(): int
    {
        $s = $this->summary();
        echo "\n=== {$s['suite']}: {$s['passed']}/{$s['total']} passed ===\n";
        if (!$s['ok']) {
            foreach ($s['results'] as $r) {
                if ($r['status'] === 'fail') {
                    echo "  - {$r['name']}: {$r['error']}\n";
                }
            }
        }
        return $s['ok'] ? 0 : 1;
    }
}

function riara_assert_public_branding(RiaraTestRunner $runner, string $html, string $pageLabel): void
{
    $runner->assertContains('riara-brand-bar', $html, "$pageLabel: brand bar");
    $runner->assertContains('riara-footer', $html, "$pageLabel: custom footer");
    $runner->assertNotContains('pkp_brand_footer', $html, "$pageLabel: no PKP footer");
    $runner->assertNotContains('Open Journal Systems', $html, "$pageLabel: no OJS branding");
}

function riara_journal_url(array $config, string $path = ''): string
{
    return riara_context_url($config, $config['journalPath'], $path);
}

function riara_context_url(array $config, string $journalPath, string $path = ''): string
{
    $base = rtrim($config['baseUrl'], '/');
    $path = ltrim($path, '/');
    return $path === ''
        ? "$base/index.php/$journalPath"
        : "$base/index.php/$journalPath/$path";
}

function riara_site_url(array $config, string $path = ''): string
{
    $base = rtrim($config['baseUrl'], '/');
    $path = ltrim($path, '/');
    return $path === '' ? $base . '/' : "$base/index.php/$path";
}

function riara_pdo(array $config): PDO
{
    $db = $config['db'];
    return new PDO(
        "mysql:host={$db['host']};dbname={$db['name']};charset=utf8mb4",
        $db['user'],
        $db['pass'],
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );
}

function riara_bootstrap_ojs(string $journalPath = 'riara'): ?PKP\context\Context
{
    if (!defined('INDEX_FILE_LOCATION')) {
        define('INDEX_FILE_LOCATION', '/var/www/html/index.php');
    }
    require_once '/var/www/html/lib/pkp/includes/bootstrap.php';

    $_SERVER['PATH_INFO'] = '/' . $journalPath;
    $_SERVER['REQUEST_URI'] = '/index.php/' . $journalPath;

    $application = APP\core\Application::get();
    $request = $application->getRequest();
    $dispatcher = $application->getDispatcher();
    $pageRouter = new APP\core\PageRouter();
    $request->setRouter($pageRouter);
    $request->setDispatcher($dispatcher);

    $context = $request->getContext();
    if (!$context) {
        throw new RuntimeException("Journal context not found: $journalPath");
    }

    \PKP\plugins\PluginRegistry::loadPlugin('generic', 'riaraworkflownotifications', $context->getId());
    \PKP\plugins\PluginRegistry::loadPlugin('generic', 'googleOAuth', $context->getId());

    return $context;
}
