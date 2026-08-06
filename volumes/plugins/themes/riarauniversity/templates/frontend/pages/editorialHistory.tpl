{**
 * Riara University — editorial history page.
 *}
{include file="frontend/components/header.tpl" pageTitle="common.editorialHistory"}

<div class="page page_masthead riara-page riara-page--about riara-page--history riara-inner">
	{include file="frontend/components/breadcrumbs.tpl" currentTitleKey="common.editorialHistory"}

	<div class="riara-about-layout">
		{include file="frontend/components/about_nav.tpl"}

		<div class="riara-about-layout__main">
			<header class="riara-page__header">
				<p class="riara-kicker">{translate key="common.editorialHistory"}</p>
				<h1>{translate key="common.editorialHistory.page"}</h1>
				<p class="riara-page__lead">{translate key="common.editorialHistory.page.description"}</p>
			</header>

			{foreach from=$mastheadRoles item="mastheadRole"}
				{if array_key_exists($mastheadRole->id, $mastheadUsers)}
					<section class="riara-masthead-group riara-page__panel">
						<h2 class="riara-masthead-group__title">{$mastheadRole->getLocalizedData('name')|escape}</h2>
						<ul class="user_listing riara-masthead-list" role="list">
							{foreach from=$mastheadUsers[$mastheadRole->id] item="mastheadUser"}
								<li class="riara-masthead-list__item">
									{strip}
									<span class="date_start riara-masthead-list__dates">
										{foreach name="services" from=$mastheadUser['services'] item="service"}
											{translate key="common.fromUntil" from=$service['dateStart'] until=$service['dateEnd']}
											{if !$smarty.foreach.services.last}{translate key="common.commaListSeparator"}{/if}
										{/foreach}
									</span>
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
									{/strip}
								</li>
							{/foreach}
						</ul>
					</section>
				{/if}
			{/foreach}

			{include file="frontend/components/editLink.tpl" page="management" op="settings" path="context" anchor="masthead" sectionTitleKey="common.editorialHistory"}

			{if $currentContext->getLocalizedData('editorialHistory')}
				<div class="riara-page__panel riara-prose">
					{$currentContext->getLocalizedData('editorialHistory')}
				</div>
			{/if}
		</div>
	</div>
</div>

{include file="frontend/components/footer.tpl"}
