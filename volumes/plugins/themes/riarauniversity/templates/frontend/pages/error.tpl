{**
 * Riara University — error page.
 *}
{include file="frontend/components/header.tpl" pageTitle=$pageTitle}

<div class="page page_error riara-page riara-page--message riara-inner">
	{include file="frontend/components/breadcrumbs.tpl" currentTitleKey=$pageTitle}

	<header class="riara-page__header">
		<p class="riara-kicker">{translate key="plugins.themes.riarauniversity.error.kicker"}</p>
		<h1>{translate key=$pageTitle}</h1>
	</header>

	<div class="riara-page__panel riara-prose riara-message-panel">
		<div class="riara-message-panel__icon fa fa-exclamation-circle" aria-hidden="true"></div>
		<p class="riara-message-panel__lead">{translate key="plugins.themes.riarauniversity.error.lead"}</p>
		<div class="description">
			{translate key=$errorMsg params=$errorParams}
		</div>
		{if $backLink}
			<p class="riara-form__actions">
				<a class="riara-btn riara-btn--primary" href="{$backLink|escape}">{translate key=$backLinkLabel}</a>
			</p>
		{/if}
	</div>
</div>

{include file="frontend/components/footer.tpl"}
