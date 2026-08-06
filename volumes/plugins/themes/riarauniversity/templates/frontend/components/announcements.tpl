{**

 * Riara University — announcements list page grid.

 *

 * @uses $announcements Announcement[]

 *}

{if $announcements|@count}

	<ul class="cmp_announcements riara-announcements-list riara-announcements-page__grid">

		{foreach from=$announcements item=announcement}

			<li class="riara-announcements-list__item">

				{include file="frontend/objects/announcement_summary.tpl" heading="h2"}

			</li>

		{/foreach}

	</ul>

{else}

	<div class="riara-page__panel riara-announcements-empty" role="status">

		<p>{translate key="plugins.themes.riarauniversity.announcements.empty"}</p>

	</div>

{/if}


