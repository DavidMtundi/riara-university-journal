<?php

/**
 * @file plugins/themes/riarauniversity/RiaraUniversityThemePlugin.php
 *
 * @brief Riara University journal theme — global editorial design.
 */

namespace APP\plugins\themes\riarauniversity;

use APP\core\Application;
use APP\facades\Repo;
use APP\submission\Submission;
use APP\template\TemplateManager;
use Illuminate\Support\Facades\DB;
use PKP\core\PKPSessionGuard;
use PKP\db\DAORegistry;
use PKP\plugins\Hook;
use PKP\plugins\PluginRegistry;
use PKP\security\Role;
use PKP\userGroup\UserGroup;

class RiaraUniversityThemePlugin extends \PKP\plugins\ThemePlugin
{
    /** @var array<string, ?array> */
    private static array $homeStatsCache = [];

    /** @var ?array */
    private static ?array $siteHubStatsCache = null;

    public function isActive()
    {
        if (PKPSessionGuard::isSessionDisable()) {
            return true;
        }
        return parent::isActive();
    }

    public function init()
    {
        $this->setParent('defaultthemeplugin');

        $this->addOption('baseColour', 'FieldColor', [
            'label' => __('plugins.themes.default.option.colour.label'),
            'description' => __('plugins.themes.default.option.colour.description'),
            'default' => '#7B1E3A',
        ]);

        $this->addOption('showDescriptionInJournalIndex', 'FieldOptions', [
            'label' => __('manager.setup.contextSummary'),
            'options' => [
                [
                    'value' => true,
                    'label' => __('plugins.themes.default.option.showDescriptionInJournalIndex.option'),
                ],
            ],
            'default' => true,
        ]);

        $this->addStyle('riara-fonts', 'styles/fonts.less');

        $modifyArgs = ['addLess' => ['styles/riara.less', 'styles/riara-dark.less']];

        $baseColour = $this->getOption('baseColour');
        if ($baseColour && $baseColour !== '#7B1E3A') {
            if (!preg_match('/^#[0-9a-fA-F]{1,6}$/', $baseColour)) {
                $baseColour = '#7B1E3A';
            }
            $additionalLessVariables = ['@bg-base:' . $baseColour . ';', '@riara-primary:' . $baseColour . ';'];
            if (!$this->isColourDark($baseColour)) {
                $additionalLessVariables[] = '@text-bg-base:rgba(0,0,0,0.84);';
                $additionalLessVariables[] = '@bg-base-border-color:rgba(0,0,0,0.2);';
            }
            $modifyArgs['addLessVariables'] = join("\n", $additionalLessVariables);
        }

        $this->modifyStyle('stylesheet', $modifyArgs);
        $this->addScript('riara-js', 'js/riara.js');

        $templateMgr = TemplateManager::getManager(Application::get()->getRequest());
        $templateMgr->addJavaScript(
            'riaraThemeBoot',
            '(function(){try{var s=localStorage.getItem("riara-theme");var d=s==="dark"||(!s&&window.matchMedia&&window.matchMedia("(prefers-color-scheme:dark)").matches);if(d){document.documentElement.setAttribute("data-theme","dark");}}catch(e){}})();',
            ['inline' => true, 'priority' => STYLE_SEQUENCE_CORE - 1]
        );

        $templateMgr->addJavaScript(
            'riaraThemeStrings',
			'window.riaraThemeStrings = ' . json_encode([
                'brandBar' => __('plugins.themes.riarauniversity.brandBar'),
                'scrollHint' => __('plugins.themes.riarauniversity.hero.scrollHint'),
                'citationCopied' => __('plugins.themes.riarauniversity.citation.copied'),
                'themeLight' => __('plugins.themes.riarauniversity.theme.light'),
                'themeDark' => __('plugins.themes.riarauniversity.theme.dark'),
                'showPassword' => __('plugins.themes.riarauniversity.auth.showPassword'),
                'hidePassword' => __('plugins.themes.riarauniversity.auth.hidePassword'),
            ], JSON_UNESCAPED_UNICODE) . ';',
            ['inline' => true, 'priority' => STYLE_SEQUENCE_CORE]
        );

        Hook::add('LoadHandler::loadHandler', [$this, 'loadRiaraGenericPlugins']);
        Hook::add('LoadHandler::loadHandler', [$this, 'assignRiaraBranding']);
        Hook::add('LoadHandler::loadHandler', [$this, 'assignHomepageStats']);
        Hook::add('LoadHandler::loadHandler', [$this, 'assignSiteHubStats']);
        Hook::add('TemplateManager::display', [$this, 'assignHomepageStatsOnDisplay']);
        Hook::add('TemplateManager::display', [$this, 'assignStaticPageMetrics']);
        Hook::add('ArticleHandler::view', [$this, 'assignRelatedArticles']);
    }

    public function loadRiaraGenericPlugins(string $hookName, array $args): bool
    {
        $request = Application::get()->getRequest();
        $context = $request->getContext() ?? $request->getJournal();
        if ($context) {
            PluginRegistry::loadPlugin('generic', 'riaraworkflownotifications', $context->getId());
            PluginRegistry::loadPlugin('generic', 'googleOAuth', $context->getId());
        }

        return Hook::CONTINUE;
    }

    public function assignRiaraBranding(string $hookName, array $args): bool
    {
        $page = $args[0] ?? '';
        if (in_array($page, ['management', 'dashboard', 'admin'], true)) {
            return Hook::CONTINUE;
        }

        $request = Application::get()->getRequest();
        $templateMgr = TemplateManager::getManager($request);
        $context = $request->getContext() ?? $request->getJournal();
        $journalName = $context
            ? $context->getLocalizedName()
            : __('plugins.themes.riarauniversity.brand.name');

        $templateMgr->assign([
            'applicationName' => $journalName,
            'riaraUniversityBrand' => true,
            'riaraThemeUrl' => $request->getBaseUrl() . '/' . $this->getPluginPath(),
        ]);

        return Hook::CONTINUE;
    }

    public function assignHomepageStats(string $hookName, array $args): bool
    {
        $page = $args[0] ?? '';
        $op = $args[1] ?? '';
        if ($page !== 'index' || $op !== 'index') {
            return Hook::CONTINUE;
        }

        $stats = $this->getHomeStats();
        if ($stats) {
            TemplateManager::getManager(Application::get()->getRequest())
                ->assign('riaraHomeStats', $stats);
        }

        return Hook::CONTINUE;
    }

    public function assignSiteHubStats(string $hookName, array $args): bool
    {
        $page = $args[0] ?? '';
        $op = $args[1] ?? '';
        if ($page !== 'index' || $op !== 'index') {
            return Hook::CONTINUE;
        }

        $request = Application::get()->getRequest();
        if ($request->getContext() ?? $request->getJournal()) {
            return Hook::CONTINUE;
        }

        $stats = $this->getSiteHubStats();
        if ($stats) {
            TemplateManager::getManager($request)->assign('riaraSiteHubStats', $stats);
        }

        return Hook::CONTINUE;
    }

    private function getSiteHubStats(): ?array
    {
        if (self::$siteHubStatsCache !== null) {
            return self::$siteHubStatsCache;
        }

        self::$siteHubStatsCache = [
            'journals' => (int) DB::table('journals')->where('enabled', 1)->count(),
            'published' => (int) DB::table('submissions')->where('status', Submission::STATUS_PUBLISHED)->count(),
            'issues' => (int) DB::table('issues')->where('published', 1)->count(),
        ];

        return self::$siteHubStatsCache;
    }

    private function getHomeStats(): ?array
    {
        $request = Application::get()->getRequest();
        $context = $request->getContext() ?? $request->getJournal();
        if (!$context) {
            return null;
        }

        $cacheKey = 'ctx:' . $context->getId();
        if (array_key_exists($cacheKey, self::$homeStatsCache)) {
            return self::$homeStatsCache[$cacheKey];
        }

        self::$homeStatsCache[$cacheKey] = $this->buildHomeStats();
        return self::$homeStatsCache[$cacheKey];
    }

    private function buildHomeStats(): ?array
    {
        $request = Application::get()->getRequest();
        $context = $request->getContext() ?? $request->getJournal();
        if (!$context) {
            return null;
        }

        $contextId = (int) $context->getId();

        return [
            'published' => (int) DB::table('submissions')
                ->where('context_id', $contextId)
                ->where('status', 3)
                ->count(),
            'issues' => (int) DB::table('issues')
                ->where('journal_id', $contextId)
                ->where('published', 1)
                ->count(),
        ];
    }

    private function buildJournalMetrics(): ?array
    {
        $stats = $this->getHomeStats();
        if (!$stats) {
            return null;
        }

        $request = Application::get()->getRequest();
        $context = $request->getContext() ?? $request->getJournal();
        if (!$context) {
            return null;
        }

        $contextId = (int) $context->getId();

        $downloads = (int) DB::table('metrics_submission')
            ->where('context_id', $contextId)
            ->sum('metric');

        $authors = (int) DB::table('authors as a')
            ->join('publications as p', 'p.publication_id', '=', 'a.publication_id')
            ->join('submissions as s', 's.submission_id', '=', 'p.submission_id')
            ->where('s.context_id', $contextId)
            ->where('s.status', 3)
            ->count(DB::raw('DISTINCT a.author_id'));

        return array_merge($stats, [
            'downloads' => $downloads,
            'authors' => $authors,
        ]);
    }

    public function assignStaticPageMetrics(string $hookName, array $args): bool
    {
        $template = $args[1] ?? '';
        $templateName = is_object($template) ? (string) $template : (string) $template;
        if (!str_contains($templateName, 'staticPages') && !str_contains($templateName, 'content.tpl')) {
            return Hook::CONTINUE;
        }

        $metrics = $this->buildJournalMetrics() ?? ['published' => 0, 'issues' => 0, 'downloads' => 0, 'authors' => 0];
        $args[0]->assign('riaraJournalMetrics', $metrics);

        return Hook::CONTINUE;
    }

    public function assignHomepageStatsOnDisplay(string $hookName, array $args): bool
    {
        $template = $args[1] ?? '';
        if (!str_contains((string) $template, 'indexJournal')) {
            return Hook::CONTINUE;
        }

        $stats = $this->getHomeStats();
        if ($stats) {
            $args[0]->assign('riaraHomeStats', $stats);
        }

        return Hook::CONTINUE;
    }

    public function assignRelatedArticles(string $hookName, array $args): bool
    {
        $request = $args[0];
        $issue = $args[1] ?? null;
        $article = $args[2] ?? null;
        if (!$issue || !$article) {
            return Hook::CONTINUE;
        }

        $context = $request->getContext();
        if (!$context) {
            return Hook::CONTINUE;
        }

        $related = Repo::submission()->getCollector()
            ->filterByContextIds([$context->getId()])
            ->filterByIssueIds([$issue->getId()])
            ->filterByStatus([Submission::STATUS_PUBLISHED])
            ->orderBy(\APP\submission\Collector::ORDERBY_SEQUENCE, \APP\submission\Collector::ORDER_DIR_ASC)
            ->getMany()
            ->filter(fn ($submission) => $submission->getId() !== $article->getId())
            ->take(4)
            ->values()
            ->all();

        if (empty($related)) {
            return Hook::CONTINUE;
        }

        $genreDao = DAORegistry::getDAO('GenreDAO');
        $primaryGenres = $genreDao->getPrimaryByContextId($context->getId())->toArray();
        $primaryGenreIds = array_map(fn ($genre) => $genre->getId(), $primaryGenres);

        $authorUserGroups = UserGroup::withRoleIds([Role::ROLE_ID_AUTHOR])
            ->withContextIds([$context->getId()])
            ->get();

        TemplateManager::getManager($request)->assign([
            'riaraRelatedArticles' => $related,
            'primaryGenreIds' => $primaryGenreIds,
            'authorUserGroups' => $authorUserGroups,
        ]);

        return Hook::CONTINUE;
    }

    public function saveOption($name, $value, $contextId = null)
    {
        if ($name == 'baseColour' && !preg_match('/^#[0-9a-fA-F]{1,6}$/', $value)) {
            $value = null;
        }

        parent::saveOption($name, $value, $contextId);
    }

    public function getDisplayName()
    {
        return __('plugins.themes.riarauniversity.name');
    }

    public function getDescription()
    {
        return __('plugins.themes.riarauniversity.description');
    }
}
