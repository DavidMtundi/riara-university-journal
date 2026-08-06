{**

 * Riara University — announcements list page.

 *}

{include file="frontend/components/header.tpl" pageTitle="announcement.announcements"}



<div class="page page_announcements riara-page riara-page--announcements riara-inner">

	{include file="frontend/components/breadcrumbs.tpl" currentTitleKey="announcement.announcements"}



	<header class="riara-page__header">

		<p class="riara-kicker">{translate key="plugins.themes.riarauniversity.announcements.kicker"}</p>

		<h1>{translate key="announcement.announcements"}</h1>

	</header>



	{include file="frontend/components/editLink.tpl" page="management" op="settings" path="announcements" anchor="announcements" sectionTitleKey="announcement.announcements"}



	{if $announcementsIntroduction}

		<div class="riara-page__panel riara-prose riara-announcements-intro">

			{$announcementsIntroduction}

		</div>

	{/if}



	<div class="riara-announcements-page">

		{include file="frontend/components/announcements.tpl"}

	</div>

</div>



{include file="frontend/components/footer.tpl"}


