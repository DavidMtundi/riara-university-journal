{**
 * Riara University — full announcement article.
 *
 * @uses $announcement Announcement
 *}
<article class="obj_announcement_full riara-announcement-article">
	<header class="riara-announcement-article__header riara-page__header">
		<p class="riara-kicker">{translate key="plugins.themes.riarauniversity.announcements.kicker"}</p>
		<h1 class="riara-announcement-article__title">
			{$announcement->getLocalizedData('title')|escape}
		</h1>
		<time class="riara-announcement-article__date date" datetime="{$announcement->datePosted->format('Y-m-d')}">
			{$announcement->datePosted->format($dateFormatShort)}
		</time>
	</header>

	{if $announcement->image}
		<figure class="riara-announcement-article__figure">
			<img
				class="obj_announcement_full_image"
				src="{$announcement->imageUrl|escape}"
				alt="{$announcement->imageAltText|escape}"
				loading="lazy"
			>
		</figure>
	{/if}

	<div class="riara-announcement-article__body description riara-page__panel riara-prose">
		{if $announcement->getLocalizedData('description')}
			{$announcement->getLocalizedData('description')|strip_unsafe_html}
		{else}
			{$announcement->getLocalizedData('descriptionShort')|strip_unsafe_html}
		{/if}
	</div>

	<footer class="riara-announcement-article__footer">
		<a class="riara-btn riara-btn--ghost" href="{url page="announcement"}">
			<span class="fa fa-arrow-left" aria-hidden="true"></span>
			{translate key="announcement.announcements"}
		</a>
	</footer>
</article>
