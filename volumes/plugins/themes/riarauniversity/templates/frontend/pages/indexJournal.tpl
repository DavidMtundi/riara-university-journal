{**

 * Riara University — editorial homepage (magazine-style landing).

 *}

{include file="frontend/components/header.tpl" pageTitleTranslated=$currentJournal->getLocalizedName()}



<div class="page_index_journal riara-home">



	{call_hook name="Templates::Index::journal"}



	<section class="riara-hero" aria-labelledby="riara-hero-title">

		<div class="riara-hero__bg" aria-hidden="true">

			<div class="riara-hero__orb riara-hero__orb--1"></div>

			<div class="riara-hero__orb riara-hero__orb--2"></div>

			<div class="riara-hero__orb riara-hero__orb--3"></div>

			<div class="riara-hero__gridlines"></div>

			<div class="riara-hero__grain"></div>

			<div class="riara-hero__watermark" aria-hidden="true">{$smarty.now|date_format:"%Y"}</div>

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

				<span>{translate key="plugins.themes.riarauniversity.marquee.item3"}</span>

			</div>

		</div>



		<div class="riara-hero__shell">

			<div class="riara-hero__main riara-hero__entrance">

				<p class="riara-hero__eyebrow">{translate key="plugins.themes.riarauniversity.hero.eyebrow"}</p>



				<div class="riara-hero__meta">

					<span class="riara-pill riara-pill--gold">{translate key="plugins.themes.riarauniversity.pill.openAccess"}</span>

					<span class="riara-pill">{translate key="plugins.themes.riarauniversity.pill.peerReviewed"}</span>

					<span class="riara-pill riara-pill--muted">{translate key="plugins.themes.riarauniversity.pill.location"}</span>

				</div>



				<h1 id="riara-hero-title" class="riara-hero__title">

					<span class="riara-hero__title-line">{$currentJournal->getLocalizedName()|escape}</span>

				</h1>



				{if $currentContext->getLocalizedData('description') && (!$activeTheme || !$activeTheme->getOption('showDescriptionInJournalIndex'))}

					<p class="riara-hero__lead">

						{$currentContext->getLocalizedData('description')|strip_tags|truncate:260}

					</p>

				{/if}



				<div class="riara-hero__discovery">

					<p class="riara-hero__discovery-label">{translate key="plugins.themes.riarauniversity.hero.searchLabel"}</p>

					<p class="riara-hero__discovery-hint">{translate key="plugins.themes.riarauniversity.hero.searchHint"}</p>

					<form class="riara-search" action="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="search"}" method="get" role="search">

						<label class="riara-search__label pkp_screen_reader" for="riara-search-input">{translate key="common.search"}</label>

						<span class="riara-search__icon fa fa-search" aria-hidden="true"></span>

						<input id="riara-search-input" class="riara-search__input" type="search" name="query" placeholder="{translate key="common.search"}" autocomplete="off">

						<button class="riara-search__submit" type="submit">
							<span class="riara-search__submit-text">{translate key="common.search"}</span>
							<span class="riara-search__arrow fa fa-arrow-right" aria-hidden="true"></span>
						</button>

					</form>

					<div class="riara-hero__chips" role="group" aria-label="{translate key="common.search"}">

						<a class="riara-chip" href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="search"}?query=education">{translate key="plugins.themes.riarauniversity.hero.chip.education"}</a>

						<a class="riara-chip" href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="search"}?query=policy">{translate key="plugins.themes.riarauniversity.hero.chip.policy"}</a>

						<a class="riara-chip" href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="search"}?query=innovation">{translate key="plugins.themes.riarauniversity.hero.chip.innovation"}</a>

					</div>

				</div>



				<div class="riara-hero__cta">

					<a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="about" op="submissions"}" class="riara-btn riara-btn--primary">

						{translate key="about.submissions"}

					</a>

					{if $issue}

						<a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="view" path=$issue->getBestIssueId()}" class="riara-btn riara-btn--secondary">

							{translate key="journal.currentIssue"}

						</a>

					{else}

						<a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="archive"}" class="riara-btn riara-btn--secondary">

							{translate key="navigation.archives"}

						</a>

					{/if}

				</div>

			</div>



			<div class="riara-hero__aside riara-hero__entrance riara-hero__entrance--delay">

				{if $activeTheme && !$activeTheme->getOption('useHomepageImageAsHeader') && $homepageImage}

					<figure class="riara-hero__cover">

						<div class="riara-hero__cover-frame">

							<img src="{$publicFilesDir}/{$homepageImage.uploadName|escape:"url"}"{if $homepageImage.altText} alt="{$homepageImage.altText|escape}"{else} alt=""{/if}>

						</div>

						<figcaption class="riara-hero__cover-cap">{$currentJournal->getLocalizedName()|escape}</figcaption>

					</figure>

				{else}

					<div class="riara-hero__showcase">

						<div class="riara-hero__showcase-badge">

							<span class="riara-hero__showcase-icon fa fa-book" aria-hidden="true"></span>

						</div>

						<div class="riara-hero__card-stack" aria-hidden="true">

							<div class="riara-hero__float-card riara-hero__float-card--a" data-parallax="0.04">

								<span class="riara-hero__float-label">{translate key="plugins.themes.riarauniversity.float.focus"}</span>

								<strong>{translate key="plugins.themes.riarauniversity.float.focusValue"}</strong>

							</div>

							<div class="riara-hero__float-card riara-hero__float-card--b" data-parallax="0.07">

								<span class="riara-hero__float-label">{translate key="plugins.themes.riarauniversity.float.publisher"}</span>

								<strong>{translate key="plugins.themes.riarauniversity.float.publisherValue"}</strong>

							</div>

							<div class="riara-hero__float-card riara-hero__float-card--c" data-parallax="0.05">

								<span class="riara-hero__float-label">{translate key="plugins.themes.riarauniversity.float.audience"}</span>

								<strong>{translate key="plugins.themes.riarauniversity.float.audienceValue"}</strong>

							</div>

						</div>

					</div>

				{/if}

			</div>

		</div>



		<div class="riara-impact" aria-label="Journal impact">
			<div class="riara-impact__item">
				<strong class="riara-impact__value" data-riara-count="{$riaraHomeStats.published|default:0|escape}">{$riaraHomeStats.published|default:0|escape}</strong>
				<span class="riara-impact__label">{translate key="plugins.themes.riarauniversity.stats.published"}</span>
			</div>
			<div class="riara-impact__divider" aria-hidden="true"></div>
			<div class="riara-impact__item">
				<strong class="riara-impact__value" data-riara-count="{$riaraHomeStats.issues|default:0|escape}">{$riaraHomeStats.issues|default:0|escape}</strong>
				<span class="riara-impact__label">{translate key="plugins.themes.riarauniversity.stats.issues"}</span>
			</div>
			<div class="riara-impact__divider" aria-hidden="true"></div>
			<div class="riara-impact__item riara-impact__item--text">
				<strong class="riara-impact__value">100%</strong>
				<span class="riara-impact__label">{translate key="plugins.themes.riarauniversity.stats.access"}</span>
			</div>
			<div class="riara-impact__divider" aria-hidden="true"></div>
			<div class="riara-impact__item riara-impact__item--text">
				<strong class="riara-impact__value"><span class="fa fa-check" aria-hidden="true"></span></strong>
				<span class="riara-impact__label">{translate key="plugins.themes.riarauniversity.stats.review"}</span>
			</div>
		</div>



		{include file="frontend/components/trust_strip.tpl"}



		<nav class="riara-bento" aria-labelledby="riara-bento-title">

			<div class="riara-bento__head">

				<h2 id="riara-bento-title" class="riara-bento__heading">{translate key="plugins.themes.riarauniversity.bento.heading"}</h2>

			</div>

			<div class="riara-bento__grid">

				<a class="riara-bento__cell riara-bento__cell--featured" href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="about" op="submissions"}">

					<span class="riara-bento__icon fa fa-paper-plane" aria-hidden="true"></span>

					<span class="riara-bento__label">{translate key="about.submissions"}</span>

					<span class="riara-bento__hint">{translate key="plugins.themes.riarauniversity.bento.submissionsHint"}</span>

					<span class="riara-bento__arrow fa fa-arrow-right" aria-hidden="true"></span>

				</a>

				<a class="riara-bento__cell" href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="current"}">

					<span class="riara-bento__icon fa fa-book-open" aria-hidden="true"></span>

					<span class="riara-bento__label">{translate key="navigation.current"}</span>

					<span class="riara-bento__arrow fa fa-arrow-right" aria-hidden="true"></span>

				</a>

				<a class="riara-bento__cell" href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="archive"}">

					<span class="riara-bento__icon fa fa-archive" aria-hidden="true"></span>

					<span class="riara-bento__label">{translate key="navigation.archives"}</span>

					<span class="riara-bento__arrow fa fa-arrow-right" aria-hidden="true"></span>

				</a>

				<a class="riara-bento__cell" href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="about"}">

					<span class="riara-bento__icon fa fa-university" aria-hidden="true"></span>

					<span class="riara-bento__label">{translate key="about.aboutContext"}</span>

					<span class="riara-bento__arrow fa fa-arrow-right" aria-hidden="true"></span>

				</a>

				<a class="riara-bento__cell" href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="about" op="editorialMasthead"}">

					<span class="riara-bento__icon fa fa-users" aria-hidden="true"></span>

					<span class="riara-bento__label">{translate key="common.editorialMasthead"}</span>

					<span class="riara-bento__arrow fa fa-arrow-right" aria-hidden="true"></span>

				</a>

				<a class="riara-bento__cell" href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="search"}">

					<span class="riara-bento__icon fa fa-search" aria-hidden="true"></span>

					<span class="riara-bento__label">{translate key="common.search"}</span>

					<span class="riara-bento__arrow fa fa-arrow-right" aria-hidden="true"></span>

				</a>

			</div>

		</nav>



		<a href="#riara-pathway" class="riara-hero__scroll" aria-label="{translate key="plugins.themes.riarauniversity.hero.scrollHint"}">

			<span class="riara-hero__scroll-text">{translate key="plugins.themes.riarauniversity.hero.scrollHint"}</span>

			<span class="riara-hero__scroll-icon" aria-hidden="true"></span>

		</a>

	</section>



	<section id="riara-pathway" class="riara-pathway" aria-labelledby="riara-pathway-title">

		<div class="riara-pathway__head">

			<p class="riara-kicker">{translate key="plugins.themes.riarauniversity.pathway.kicker"}</p>

			<h2 id="riara-pathway-title" class="riara-pathway__title">{translate key="plugins.themes.riarauniversity.pathway.title"}</h2>

		</div>

		<div class="riara-pathway__track">
			<div class="riara-pathway__progress" aria-hidden="true"><span></span></div>
			<ol class="riara-pathway__steps">
			<li class="riara-pathway__step" data-riara-step="1">

				<div class="riara-pathway__node" aria-hidden="true"><span class="fa fa-upload"></span></div>

				<span class="riara-pathway__num">01</span>

				<h3 class="riara-pathway__step-title">{translate key="plugins.themes.riarauniversity.pathway.submit.title"}</h3>

				<p>{translate key="plugins.themes.riarauniversity.pathway.submit.text"}</p>

				<a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="about" op="submissions"}">{translate key="about.submissions"} <span class="fa fa-arrow-right" aria-hidden="true"></span></a>

			</li>

			<li class="riara-pathway__step" data-riara-step="2">

				<div class="riara-pathway__node" aria-hidden="true"><span class="fa fa-eye-slash"></span></div>

				<span class="riara-pathway__num">02</span>

				<h3 class="riara-pathway__step-title">{translate key="plugins.themes.riarauniversity.pathway.review.title"}</h3>

				<p>{translate key="plugins.themes.riarauniversity.pathway.review.text"}</p>

				<a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="about" op="editorialMasthead"}">{translate key="common.editorialMasthead"} <span class="fa fa-arrow-right" aria-hidden="true"></span></a>

			</li>

			<li class="riara-pathway__step" data-riara-step="3">

				<div class="riara-pathway__node" aria-hidden="true"><span class="fa fa-globe-africa"></span></div>

				<span class="riara-pathway__num">03</span>

				<h3 class="riara-pathway__step-title">{translate key="plugins.themes.riarauniversity.pathway.publish.title"}</h3>

				<p>{translate key="plugins.themes.riarauniversity.pathway.publish.text"}</p>

				{if $issue}

					<a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="view" path=$issue->getBestIssueId()}">{translate key="journal.currentIssue"} <span class="fa fa-arrow-right" aria-hidden="true"></span></a>

				{else}

					<a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="archive"}">{translate key="navigation.archives"} <span class="fa fa-arrow-right" aria-hidden="true"></span></a>

				{/if}

			</li>

		</ol>
		</div>

	</section>



	{if $highlights->count()}

		<section class="riara-section riara-section--highlights">

			<div class="riara-section__head">

				<p class="riara-kicker">{translate key="common.highlights"}</p>

				<h2 class="riara-section__title">{translate key="plugins.themes.riarauniversity.highlights.title"}</h2>

			</div>

			{include file="frontend/components/highlights.tpl" highlights=$highlights}

		</section>

	{/if}



	{if $activeTheme && $activeTheme->getOption('useHomepageImageAsHeader') && $homepageImage}

		<div class="homepage_image riara-home__banner">

			<img src="{$publicFilesDir}/{$homepageImage.uploadName|escape:"url"}"{if $homepageImage.altText} alt="{$homepageImage.altText|escape}"{else} alt=""{/if}>

		</div>

	{/if}



	{if $activeTheme && $activeTheme->getOption('showDescriptionInJournalIndex')}

		<section class="riara-section riara-about homepage_about">

			<div class="riara-about__grid">

				<div class="riara-about__intro">

					<p class="riara-kicker">{translate key="about.aboutContext"}</p>

					<h2 class="riara-section__title">

						<a id="homepageAbout"></a>

						{translate key="about.aboutContext"}

					</h2>

				</div>

				<div class="riara-about__body riara-prose">

					{$currentContext->getLocalizedData('description')}

				</div>

			</div>

		</section>

	{/if}



	<div class="riara-announcements-wrap">

		{include file="frontend/objects/announcements_list.tpl" numAnnouncements=$numAnnouncementsHomepage}

	</div>



	{if $issue}
		{assign var=riaraIssueCover value=$issue->getLocalizedCoverImageUrl()}
		<section class="riara-section riara-magazine current_issue{if $riaraIssueCover} riara-magazine--has-cover{/if}">
			<div class="riara-magazine__layout">
				{if $riaraIssueCover}
					<figure class="riara-magazine__cover">
						<a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="view" path=$issue->getBestIssueId()}">
							{capture assign="riaraIssueCoverAlt"}
								{translate key="issue.viewIssueIdentification" identification=$issue->getIssueIdentification()|escape}
							{/capture}
							<img src="{$riaraIssueCover|escape}" alt="{$issue->getLocalizedCoverImageAltText()|escape|default:$riaraIssueCoverAlt}" loading="lazy">
						</a>
					</figure>
				{/if}

				<div class="riara-magazine__main">
					<div class="riara-magazine__head">
						<div>
							<p class="riara-kicker">{translate key="journal.currentIssue"}</p>
							<h2 class="riara-section__title">
								<a id="homepageIssue"></a>
								{translate key="journal.currentIssue"}
							</h2>
							<div class="current_issue_title riara-magazine__issue-id">{$issue->getIssueIdentification()|escape}</div>
						</div>
						<a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="view" path=$issue->getBestIssueId()}" class="riara-btn riara-btn--primary">
							{translate key="plugins.themes.riarauniversity.magazine.viewIssue"}
						</a>
						<a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="archive"}" class="riara-btn riara-btn--outline read_more">
							{translate key="journal.viewAllIssues"}
						</a>
					</div>

					<div class="riara-magazine__body">
						{include file="frontend/objects/issue_toc.tpl" heading="h3"}
					</div>
				</div>
			</div>
		</section>
	{/if}



	<section class="riara-cta-band" aria-labelledby="riara-cta-title">

		<div class="riara-cta-band__panel">

			<div class="riara-cta-band__copy">

				<p class="riara-kicker riara-kicker--light">{translate key="plugins.themes.riarauniversity.cta.kicker"}</p>

				<h2 id="riara-cta-title" class="riara-cta-band__title">{translate key="plugins.themes.riarauniversity.cta.title"}</h2>

				<p class="riara-cta-band__text">{translate key="plugins.themes.riarauniversity.cta.text"}</p>

			</div>

			<div class="riara-cta-band__actions">

				<a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="about" op="submissions"}" class="riara-btn riara-btn--light">

					{translate key="about.submissions"}

				</a>

				<a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="user" op="register"}" class="riara-btn riara-btn--ghost-light">

					{translate key="user.register"}

				</a>

			</div>

		</div>

	</section>



	{if $additionalHomeContent}

		<section class="riara-section riara-extra additional_content">

			<div class="riara-prose">

				{$additionalHomeContent}

			</div>

		</section>

	{/if}

</div>



{include file="frontend/components/footer.tpl"}


