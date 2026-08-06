{**
 * Riara University — journal card for the site hub catalog.
 *
 * @uses $journal Journal
 * @uses $featured bool Optional featured layout
 *}
{capture assign="url"}{url journal=$journal->getPath()}{/capture}
{assign var="thumb" value=$journal->getLocalizedData('journalThumbnail')}
{assign var="description" value=$journal->getLocalizedDescription()}
{assign var="journalName" value=$journal->getLocalizedName()|escape}

<article class="riara-site-journal-card{if $featured} riara-site-journal-card--featured{/if}">
	<a class="riara-site-journal-card__media" href="{$url}" tabindex="-1" aria-hidden="true">
		{if $thumb}
			<img
				class="riara-site-journal-card__cover"
				src="{$journalFilesPath}{$journal->getId()}/{$thumb.uploadName|escape:"url"}"
				alt=""
				{if $thumb.altText}data-alt="{$thumb.altText|escape}"{/if}
			>
		{else}
			<div class="riara-site-journal-card__placeholder" aria-hidden="true">
				<span class="riara-site-journal-card__monogram">{$journalName|truncate:1:""}</span>
			</div>
		{/if}
		<span class="riara-site-journal-card__shine" aria-hidden="true"></span>
	</a>

	<div class="riara-site-journal-card__body">
		<div class="riara-site-journal-card__meta">
			<span class="riara-pill riara-pill--gold">{translate key="plugins.themes.riarauniversity.pill.openAccess"}</span>
			<span class="riara-pill">{translate key="plugins.themes.riarauniversity.pill.peerReviewed"}</span>
		</div>

		<h3 class="riara-site-journal-card__title">
			<a href="{$url}" rel="bookmark">{$journalName}</a>
		</h3>

		{if $description}
			<p class="riara-site-journal-card__description">
				{if $featured}
					{$description|strip_tags|truncate:320}
				{else}
					{$description|strip_tags|truncate:180}
				{/if}
			</p>
		{/if}

		<div class="riara-site-journal-card__actions">
			<a class="riara-btn riara-btn--primary" href="{$url}">
				{translate key="site.journalView"}
				<span class="fa fa-arrow-right" aria-hidden="true"></span>
			</a>
			<a class="riara-btn riara-btn--outline" href="{url journal=$journal->getPath() page="issue" op="current"}">
				{translate key="site.journalCurrent"}
			</a>
		</div>
	</div>

	<a class="riara-site-journal-card__link" href="{$url}" aria-label="{$journalName}">
		<span class="fa fa-arrow-right" aria-hidden="true"></span>
	</a>
</article>
