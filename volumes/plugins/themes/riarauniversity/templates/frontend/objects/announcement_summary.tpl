{**
 * Riara University — announcement card.
 *
 * @uses $announcement Announcement
 * @uses $heading string HTML heading element, default: h2
 * @uses $highlight bool Featured card styling on homepage
 *}
{if !$heading}
	{assign var="heading" value="h2"}
{/if}

<article class="obj_announcement_summary riara-announcement-card{if $announcement->image} riara-announcement-card--has-image{/if}{if $highlight} riara-announcement-card--featured{/if}">
	{if $announcement->image}
		<div class="riara-announcement-card__media">
			<img
				class="obj_announcement_summary_image"
				src="{$announcement->imageUrl|escape}"
				alt="{$announcement->imageAltText|escape}"
			/>
		</div>
	{/if}

	<div class="riara-announcement-card__body obj_announcement_summary_details">
		<time class="riara-announcement-card__date" datetime="{$announcement->datePosted->format('Y-m-d')}">
			{$announcement->datePosted->format($dateFormatShort)}
		</time>

		<{$heading} class="riara-announcement-card__title">
			<a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="announcement" op="view" path=$announcement->id}">
				{$announcement->getLocalizedData('title')|escape}
			</a>
		</{$heading}>

		<div class="riara-announcement-card__summary summary">
			{$announcement->getLocalizedData('descriptionShort')|strip_unsafe_html}
		</div>

		<a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="announcement" op="view" path=$announcement->id}" class="riara-announcement-card__link">
			<span aria-hidden="true">{translate key="common.readMore"}</span>
			<span class="pkp_screen_reader">
				{translate key="common.readMoreWithTitle" title=$announcement->getLocalizedData('title')|escape}
			</span>
			<span class="fa fa-arrow-right" aria-hidden="true"></span>
		</a>
	</div>
</article>
