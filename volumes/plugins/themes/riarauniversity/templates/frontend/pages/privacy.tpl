{**
 * Riara University — privacy statement page.
 *}
{include file="frontend/components/header.tpl" pageTitle="manager.setup.privacyStatement"}

<div class="page page_privacy riara-page riara-page--about riara-page--privacy riara-inner">
	{include file="frontend/components/breadcrumbs.tpl" currentTitleKey="manager.setup.privacyStatement"}

	<div class="riara-about-layout">
		{include file="frontend/components/about_nav.tpl"}

		<div class="riara-about-layout__main">
			<header class="riara-page__header">
				<p class="riara-kicker">{translate key="about.privacyStatement"}</p>
				<h1>{translate key="manager.setup.privacyStatement"}</h1>
			</header>

			<div class="riara-page__panel riara-prose">
				{$privacyStatement}
			</div>
		</div>
	</div>
</div>

{include file="frontend/components/footer.tpl"}
