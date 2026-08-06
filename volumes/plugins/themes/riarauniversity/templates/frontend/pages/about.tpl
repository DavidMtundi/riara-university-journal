{**

 * Riara University — about the journal page.

 *}

{include file="frontend/components/header.tpl" pageTitle="about.aboutContext"}



<div class="page page_about riara-page riara-page--about riara-inner">

	{include file="frontend/components/breadcrumbs.tpl" currentTitleKey="about.aboutContext"}



	<div class="riara-about-layout">

		{include file="frontend/components/about_nav.tpl"}



		<div class="riara-about-layout__main">

			<header class="riara-page__header">

				<p class="riara-kicker">{translate key="navigation.about"}</p>

				<h1>{translate key="about.aboutContext"}</h1>

				{include file="frontend/components/editLink.tpl" page="management" op="settings" path="context" anchor="masthead" sectionTitleKey="about.aboutContext"}

			</header>



			<div class="riara-page__panel riara-prose">

				{$currentContext->getLocalizedData('about')}

			</div>

		</div>

	</div>

</div>



{include file="frontend/components/footer.tpl"}


