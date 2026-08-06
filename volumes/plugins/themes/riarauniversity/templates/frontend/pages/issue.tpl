{**

 * Riara University — single issue / current issue page.

 *}

{include file="frontend/components/header.tpl" pageTitleTranslated=$issueIdentification}



<div class="page page_issue riara-page riara-page--issue riara-inner">

	{if !$issue}

		{include file="frontend/components/breadcrumbs_issue.tpl" currentTitleKey="current.noCurrentIssue"}

		<header class="riara-page__header">

			<p class="riara-kicker">{translate key="navigation.current"}</p>

			<h1>{translate key="current.noCurrentIssue"}</h1>

		</header>

		<div class="riara-page__panel">

			{include file="frontend/components/notification.tpl" type="warning" messageKey="current.noCurrentIssueDesc"}

		</div>

	{else}

		{include file="frontend/components/breadcrumbs_issue.tpl" currentTitle=$issueIdentification}

		{assign var=currentIssueId value=$currentJournal->getData('currentIssueId')}

		{assign var=riaraIssueIsCurrent value=($currentIssueId && $issue->getId() == $currentIssueId)}

		{include file="frontend/objects/issue_hero.tpl" riaraIssueIsCurrent=$riaraIssueIsCurrent}



		<section class="riara-issue-toc-section" aria-labelledby="riara-issue-toc-heading">

			<div class="riara-issue-toc-section__head">

				<h2 id="riara-issue-toc-heading" class="riara-issue-toc-heading">{translate key="plugins.themes.riarauniversity.issue.tocHeading"}</h2>

				<a class="riara-btn riara-btn--outline" href="{url page="issue" op="archive"}">{translate key="navigation.archives"}</a>

			</div>

			<div class="riara-page__panel riara-issue-toc-panel">

				{include file="frontend/objects/issue_toc.tpl"}

			</div>

		</section>

	{/if}

</div>



{include file="frontend/components/footer.tpl"}


