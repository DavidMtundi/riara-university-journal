{**
 * Riara University — editorial masthead page.
 *}
{include file="frontend/components/header.tpl" pageTitle="common.editorialMasthead"}

<div class="page page_masthead riara-page riara-page--about riara-page--masthead riara-inner">
	{include file="frontend/components/breadcrumbs.tpl" currentTitleKey="common.editorialMasthead"}

	<div class="riara-about-layout">
		{include file="frontend/components/about_nav.tpl"}

		<div class="riara-about-layout__main">
			<header class="riara-page__header">
				<p class="riara-kicker">{translate key="common.editorialMasthead"}</p>
				<h1>{translate key="common.editorialMasthead"}</h1>
			</header>

			{foreach from=$mastheadRoles item="mastheadRole"}
				{if array_key_exists($mastheadRole->id, $mastheadUsers)}
					<section class="riara-masthead-group riara-page__panel">
						<h2 class="riara-masthead-group__title">{$mastheadRole->getLocalizedData('name')|escape}</h2>
						<ul class="user_listing riara-masthead-list" role="list">
							{foreach from=$mastheadUsers[$mastheadRole->id] item="mastheadUser"}
								<li class="riara-masthead-list__item">
									{if !empty($mastheadUser['dateStart'])}
										<span class="date_start riara-masthead-list__dates">{translate key="common.fromUntil" from=$mastheadUser['dateStart'] until=""}</span>
									{/if}
									<span class="name riara-masthead-list__name">
										{$mastheadUser['user']->getFullName()|escape}
										{if $mastheadUser['user']->getData('orcid') && $mastheadUser['user']->hasVerifiedOrcid()}
											<span class="orcid">
												<a href="{$mastheadUser['user']->getData('orcid')|escape}" target="_blank" aria-label="{translate key="common.editorialHistory.page.orcidLink" name=$mastheadUser['user']->getFullName()|escape}">
													{$orcidIcon}
												</a>
											</span>
										{/if}
									</span>
									{if !empty($mastheadUser['user']->getLocalizedData('affiliation'))}
										<span class="affiliation riara-masthead-list__affiliation">{$mastheadUser['user']->getLocalizedData('affiliation')|escape}</span>
									{/if}
								</li>
							{/foreach}
						</ul>
					</section>
				{/if}
			{/foreach}

			<p class="riara-masthead-history">
				{capture assign=editorialHistoryUrl}{url page="about" op="editorialHistory" router=\PKP\core\PKPApplication::ROUTE_PAGE}{/capture}
				{translate key="about.editorialMasthead.linkToEditorialHistory" url=$editorialHistoryUrl}
			</p>

			{if $reviewers->count()}
				<section class="riara-masthead-group riara-page__panel">
					<h2 class="riara-masthead-group__title">{translate key="common.editorialMasthead.peerReviewers"}</h2>
					<p class="riara-masthead-group__intro">{translate key="common.editorialMasthead.peerReviewers.description" year=$previousYear}</p>
					<ul class="user_listing riara-masthead-list riara-masthead-list--compact" role="list">
						{foreach from=$reviewers item="reviewer"}
							<li class="riara-masthead-list__item">
								<span class="name riara-masthead-list__name">
									{$reviewer->getFullName()|escape}
									{if $reviewer->getData('orcid') && $reviewer->hasVerifiedOrcid()}
										<span class="orcid">
											<a href="{$reviewer->getData('orcid')|escape}" target="_blank" aria-label="{translate key="common.editorialHistory.page.orcidLink" name=$reviewer->getFullName()|escape}">
												{$orcidIcon}
											</a>
										</span>
									{/if}
								</span>
								{if $reviewer->getLocalizedData('affiliation')}
									<span class="affiliation riara-masthead-list__affiliation">{$reviewer->getLocalizedData('affiliation')|escape}</span>
								{/if}
							</li>
						{/foreach}
					</ul>
				</section>
			{/if}
		</div>
	</div>
</div>

{include file="frontend/components/footer.tpl"}
