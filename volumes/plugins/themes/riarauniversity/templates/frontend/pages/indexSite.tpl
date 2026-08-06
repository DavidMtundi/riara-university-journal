{**
 * Riara University — site index (multi-journal hub).
 *}
{include file="frontend/components/header.tpl"}

<div class="page_index_site riara-site-hub">
	<section class="riara-site-hero riara-site-hero--editorial" aria-labelledby="riara-site-title">
		<div class="riara-site-hero__bg" aria-hidden="true">
			<div class="riara-hero__orb riara-hero__orb--1"></div>
			<div class="riara-hero__orb riara-hero__orb--2"></div>
			<div class="riara-hero__orb riara-hero__orb--3"></div>
			<div class="riara-hero__gridlines"></div>
			<div class="riara-hero__grain"></div>
			<div class="riara-hero__watermark" aria-hidden="true">RIARA</div>
		</div>

		<div class="riara-marquee" aria-hidden="true">
			<div class="riara-marquee__track">
				<span>{translate key="plugins.themes.riarauniversity.marquee.item1"}</span>
				<span>{translate key="plugins.themes.riarauniversity.marquee.item2"}</span>
				<span>{translate key="plugins.themes.riarauniversity.marquee.item3"}</span>
				<span>{translate key="plugins.themes.riarauniversity.marquee.item4"}</span>
				<span>{translate key="plugins.themes.riarauniversity.marquee.item5"}</span>
				<span>{translate key="plugins.themes.riarauniversity.marquee.item1"}</span>
				<span>{translate key="plugins.themes.riarauniversity.marquee.item2"}</span>
			</div>
		</div>

		<div class="riara-site-hero__shell">
			<div class="riara-site-hero__main riara-hero__entrance">
				<p class="riara-kicker">{translate key="plugins.themes.riarauniversity.site.kicker"}</p>

				<div class="riara-site-hero__meta">
					<span class="riara-pill riara-pill--gold">{translate key="plugins.themes.riarauniversity.pill.openAccess"}</span>
					<span class="riara-pill">{translate key="plugins.themes.riarauniversity.pill.peerReviewed"}</span>
					<span class="riara-pill riara-pill--muted">{translate key="plugins.themes.riarauniversity.pill.location"}</span>
				</div>

				<h1 id="riara-site-title" class="riara-site-hero__title">
					{if $siteTitle}{$siteTitle|escape}{else}{translate key="plugins.themes.riarauniversity.site.hubTitle"}{/if}
				</h1>

				{if $about}
					<div class="riara-site-hero__intro riara-prose">
						{$about}
					</div>
				{else}
					<p class="riara-site-hero__intro">{translate key="plugins.themes.riarauniversity.site.hubText"}</p>
				{/if}

				<div class="riara-site-hero__cta">
					<a class="riara-btn riara-btn--primary" href="#riara-site-catalog">
						{translate key="plugins.themes.riarauniversity.site.browseJournals"}
						<span class="fa fa-arrow-down" aria-hidden="true"></span>
					</a>
					<a class="riara-btn riara-btn--secondary" href="{url page="login"}">
						{translate key="user.login"}
					</a>
				</div>
			</div>

			<aside class="riara-site-hero__aside riara-hero__entrance" aria-label="{translate key="plugins.themes.riarauniversity.site.asideLabel"}">
				<div class="riara-site-hero__stack">
					{if $journals|@count}
						{foreach from=$journals item=journal name=hubPreview}
							{if $smarty.foreach.hubPreview.iteration <= 3}
								{capture assign="previewUrl"}{url journal=$journal->getPath()}{/capture}
								<a class="riara-site-hero__preview{if $smarty.foreach.hubPreview.iteration == 2} riara-site-hero__preview--offset{/if}" href="{$previewUrl}" style="--riara-preview-index: {$smarty.foreach.hubPreview.iteration}">
									<span class="riara-site-hero__preview-kicker">{translate key="plugins.themes.riarauniversity.site.previewKicker"}</span>
									<strong class="riara-site-hero__preview-title">{$journal->getLocalizedName()|escape}</strong>
									<span class="riara-site-hero__preview-link">{translate key="site.journalView"} <span class="fa fa-arrow-right" aria-hidden="true"></span></span>
								</a>
							{/if}
						{/foreach}
					{else}
						<div class="riara-site-hero__preview riara-site-hero__preview--placeholder">
							<span class="riara-site-hero__preview-kicker">{translate key="plugins.themes.riarauniversity.site.kicker"}</span>
							<strong class="riara-site-hero__preview-title">{translate key="plugins.themes.riarauniversity.site.hubTitle"}</strong>
						</div>
					{/if}
				</div>
			</aside>
		</div>

		<div class="riara-impact riara-impact--site" aria-label="{translate key="plugins.themes.riarauniversity.site.statsLabel"}">
			<div class="riara-impact__item">
				<strong class="riara-impact__value" data-riara-count="{$riaraSiteHubStats.journals|default:$journals|@count|escape}">{$riaraSiteHubStats.journals|default:$journals|@count|escape}</strong>
				<span class="riara-impact__label">{translate key="plugins.themes.riarauniversity.site.stats.journals"}</span>
			</div>
			<div class="riara-impact__divider" aria-hidden="true"></div>
			<div class="riara-impact__item">
				<strong class="riara-impact__value" data-riara-count="{$riaraSiteHubStats.published|default:0|escape}">{$riaraSiteHubStats.published|default:0|escape}</strong>
				<span class="riara-impact__label">{translate key="plugins.themes.riarauniversity.stats.published"}</span>
			</div>
			<div class="riara-impact__divider" aria-hidden="true"></div>
			<div class="riara-impact__item">
				<strong class="riara-impact__value" data-riara-count="{$riaraSiteHubStats.issues|default:0|escape}">{$riaraSiteHubStats.issues|default:0|escape}</strong>
				<span class="riara-impact__label">{translate key="plugins.themes.riarauniversity.stats.issues"}</span>
			</div>
			<div class="riara-impact__divider" aria-hidden="true"></div>
			<div class="riara-impact__item riara-impact__item--text">
				<strong class="riara-impact__value">100%</strong>
				<span class="riara-impact__label">{translate key="plugins.themes.riarauniversity.stats.access"}</span>
			</div>
		</div>
	</section>

	<div class="riara-page riara-page--site">
		{include file="frontend/components/trust_strip.tpl"}

		<section class="riara-section riara-site-catalog" aria-labelledby="riara-site-catalog-heading" id="riara-site-catalog">
			<header class="riara-section__head riara-site-catalog__head">
				<div>
					<p class="riara-kicker">{translate key="plugins.themes.riarauniversity.site.catalogKicker"}</p>
					<h2 id="riara-site-catalog-heading" class="riara-section__title">
						{translate key="plugins.themes.riarauniversity.site.journalsHeading"}
					</h2>
					<p class="riara-site-catalog__lead">{translate key="plugins.themes.riarauniversity.site.catalogLead"}</p>
				</div>
			</header>

			{if !$journals|@count}
				<div class="riara-page__panel riara-site-catalog__empty">
					<p>{translate key="site.noJournals"}</p>
				</div>
			{else}
				<div class="riara-site-catalog__grid">
					{foreach from=$journals item=journal name=hubJournals}
						{include file="frontend/objects/site_journal_card.tpl" journal=$journal featured=($smarty.foreach.hubJournals.first)}
					{/foreach}
				</div>
			{/if}
		</section>

		<section class="riara-pathway riara-pathway--site" aria-labelledby="riara-site-pathway-title">
			<header class="riara-pathway__head">
				<p class="riara-kicker">{translate key="plugins.themes.riarauniversity.pathway.kicker"}</p>
				<h2 id="riara-site-pathway-title" class="riara-pathway__title">{translate key="plugins.themes.riarauniversity.pathway.title"}</h2>
			</header>
			<div class="riara-pathway__track">
				<div class="riara-pathway__progress" aria-hidden="true"><span></span></div>
				<ol class="riara-pathway__steps">
					<li class="riara-pathway__step is-active" data-riara-step="1">
						<div class="riara-pathway__node" aria-hidden="true"><span class="fa fa-upload"></span></div>
						<span class="riara-pathway__num">01</span>
						<h3 class="riara-pathway__step-title">{translate key="plugins.themes.riarauniversity.pathway.submit.title"}</h3>
						<p>{translate key="plugins.themes.riarauniversity.pathway.submit.text"}</p>
					</li>
					<li class="riara-pathway__step" data-riara-step="2">
						<div class="riara-pathway__node" aria-hidden="true"><span class="fa fa-eye-slash"></span></div>
						<span class="riara-pathway__num">02</span>
						<h3 class="riara-pathway__step-title">{translate key="plugins.themes.riarauniversity.pathway.review.title"}</h3>
						<p>{translate key="plugins.themes.riarauniversity.pathway.review.text"}</p>
					</li>
					<li class="riara-pathway__step" data-riara-step="3">
						<div class="riara-pathway__node" aria-hidden="true"><span class="fa fa-globe-africa"></span></div>
						<span class="riara-pathway__num">03</span>
						<h3 class="riara-pathway__step-title">{translate key="plugins.themes.riarauniversity.pathway.publish.title"}</h3>
						<p>{translate key="plugins.themes.riarauniversity.pathway.publish.text"}</p>
					</li>
				</ol>
			</div>
		</section>

		{if $highlights->count()}
			<div class="riara-section">
				{include file="frontend/components/highlights.tpl" highlights=$highlights}
			</div>
		{/if}

		<div class="riara-section riara-announcements-wrap">
			{include file="frontend/objects/announcements_list.tpl" numAnnouncements=$numAnnouncementsHomepage}
		</div>

		<section class="riara-cta-band" aria-labelledby="riara-site-cta-title">
			<div class="riara-cta-band__panel">
				<div class="riara-cta-band__copy">
					<p class="riara-kicker">{translate key="plugins.themes.riarauniversity.cta.kicker"}</p>
					<h2 id="riara-site-cta-title" class="riara-cta-band__title">{translate key="plugins.themes.riarauniversity.cta.title"}</h2>
					<p class="riara-cta-band__text">{translate key="plugins.themes.riarauniversity.cta.text"}</p>
				</div>
				<div class="riara-cta-band__actions">
					<a class="riara-btn riara-btn--primary" href="{url page="user" op="register"}">
						{translate key="user.register"}
					</a>
					<a class="riara-btn riara-btn--outline" href="#riara-site-catalog">
						{translate key="plugins.themes.riarauniversity.site.browseJournals"}
					</a>
				</div>
			</div>
		</section>
	</div>
</div>

{include file="frontend/components/footer.tpl"}
