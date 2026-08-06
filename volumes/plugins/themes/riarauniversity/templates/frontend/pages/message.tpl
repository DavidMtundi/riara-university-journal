{**
 * Riara University — generic message page.
 *}
{include file="frontend/components/header.tpl" pageTitle=$pageTitle}

<div class="page page_message riara-page riara-page--message riara-inner">
	{include file="frontend/components/breadcrumbs.tpl" currentTitleKey=$pageTitle}

	<header class="riara-page__header">
		<p class="riara-kicker">{translate key="plugins.themes.riarauniversity.message.kicker"}</p>
		<h1>{translate key=$pageTitle}</h1>
	</header>

	<div class="riara-page__panel riara-prose riara-message-panel">
		<div class="riara-message-panel__icon fa fa-info-circle" aria-hidden="true"></div>
		<p class="riara-message-panel__lead">{translate key="plugins.themes.riarauniversity.message.lead"}</p>
		<div class="description">
			{if $messageTranslated}
				{$messageTranslated}
			{else}
				{translate key=$message}
			{/if}
		</div>
		{if $backLink}
			<p class="riara-form__actions">
				<a class="riara-btn riara-btn--primary" href="{$backLink|escape}">{translate key=$backLinkLabel}</a>
			</p>
		{/if}
	</div>
</div>

{include file="frontend/components/footer.tpl"}
