{**
 * Riara University — homepage announcements grid.
 *
 * @uses $numAnnouncements int
 * @uses $announcements Announcement[]
 *}
{if $numAnnouncements && $announcements|@count}
	<section class="cmp_announcements riara-announcements-grid">
		<a id="homepageAnnouncements" class="pkp_screen_reader">{translate key="announcement.announcements"}</a>

		<header class="riara-announcements-grid__head">
			<p class="riara-kicker">{translate key="plugins.themes.riarauniversity.announcements.kicker"}</p>
			<h2 class="riara-section__title">{translate key="announcement.announcements"}</h2>
		</header>

		<div class="riara-announcements-grid__items">
			{foreach name=announcements from=$announcements item=announcement}
				{if $smarty.foreach.announcements.iteration > $numAnnouncements}
					{break}
				{/if}
				{include file="frontend/objects/announcement_summary.tpl" heading="h3" highlight=($smarty.foreach.announcements.iteration == 1)}
			{/foreach}
		</div>
	</section>
{/if}
