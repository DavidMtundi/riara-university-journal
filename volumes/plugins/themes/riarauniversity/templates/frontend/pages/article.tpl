{**
 * Riara University — article detail page.
 *}
{include file="frontend/components/header.tpl" pageTitleTranslated=$article->getCurrentPublication()->getLocalizedFullTitle(null, 'html')|strip_unsafe_html}

<div class="page page_article riara-page riara-page--article riara-inner">
	{if $section}
		{include file="frontend/components/breadcrumbs_article.tpl" currentTitle=$section->getLocalizedTitle()}
	{else}
		{include file="frontend/components/breadcrumbs_article.tpl" currentTitleKey="common.publication"}
	{/if}

	<div id="riara-article-top" class="pkp_screen_reader" tabindex="-1"></div>

	{include file="frontend/objects/article_hero.tpl"}
	{include file="frontend/objects/article_citation.tpl"}
	{include file="frontend/objects/article_details.tpl"}
	{include file="frontend/objects/article_related.tpl"}

	{call_hook name="Templates::Article::Footer::PageFooter"}
</div>

{include file="frontend/components/footer.tpl"}
