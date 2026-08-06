{**
 * Riara University — themed static page layout.
 *}
{include file="frontend/components/header.tpl" pageTitleTranslated=$title|escape}

<div class="page page_static riara-page riara-page--static riara-inner">
	{include file="frontend/components/breadcrumbs.tpl" currentTitle=$title|escape}

	<header class="riara-page__header">
		<p class="riara-kicker">{translate key="plugins.themes.riarauniversity.static.kicker"}</p>
		<h1>{$title|escape}</h1>
	</header>

	<div class="riara-page__panel">
		{if $title == 'Journal metrics'}
			{include file="frontend/objects/journal_metrics.tpl"}
		{else}
			<div class="riara-prose riara-static-content">
				{$content}
			</div>
		{/if}
	</div>
</div>

{include file="frontend/components/footer.tpl"}
