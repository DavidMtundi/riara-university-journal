{**
 * Riara University — about the publishing platform (replaces OJS software page).
 *}
{include file="frontend/components/header.tpl" pageTitle="plugins.themes.riarauniversity.platform.title"}

<div class="page page_about_publishing_system riara-page riara-page--platform riara-inner">
	{include file="frontend/components/breadcrumbs.tpl" currentTitleKey="plugins.themes.riarauniversity.platform.title"}

	<header class="riara-page__header">
		<p class="riara-kicker">{translate key="plugins.themes.riarauniversity.platform.kicker"}</p>
		<h1>{translate key="plugins.themes.riarauniversity.platform.title"}</h1>
	</header>

	<div class="riara-page__panel riara-prose">
		<p>{translate key="plugins.themes.riarauniversity.platform.lead"}</p>
		<p>{translate key="plugins.themes.riarauniversity.platform.body"}</p>
		<p>
			<a class="riara-btn riara-btn--primary" href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="about"}">
				{translate key="about.aboutContext"}
			</a>
			<a class="riara-btn riara-btn--ghost" href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="about" op="contact"}">
				{translate key="about.contact"}
			</a>
		</p>
	</div>
</div>

{include file="frontend/components/footer.tpl"}
