{**
 * Riara University — issue archive card.
 *
 * @uses $issue Issue
 *}
{if $issue->getShowTitle()}
	{assign var=issueTitle value=$issue->getLocalizedTitle()}
{/if}
{assign var=issueSeries value=$issue->getIssueSeries()}
{assign var=issueCover value=$issue->getLocalizedCoverImageUrl()}
{capture assign="issueUrl"}{url op="view" path=$issue->getBestIssueId()}{/capture}

<article class="obj_issue_summary riara-issue-card{if $issueCover} riara-issue-card--has-cover{/if}">
	{if $issueCover}
		<a class="riara-issue-card__cover cover" href="{$issueUrl|escape}">
			<img
				src="{$issueCover|escape}"
				alt="{$issue->getLocalizedCoverImageAltText()|escape|default:''}"
				loading="lazy"
			>
		</a>
	{/if}

	<div class="riara-issue-card__body">
		<h2 class="riara-issue-card__title">
			<a class="title" href="{$issueUrl|escape}">
				{if $issueTitle}
					{$issueTitle|escape}
				{else}
					{$issueSeries|escape}
				{/if}
			</a>
		</h2>

		{if $issueTitle && $issueSeries}
			<p class="riara-issue-card__series series">{$issueSeries|escape}</p>
		{/if}

		{if $issue->getLocalizedDescription()}
			<div class="riara-issue-card__description description">
				{$issue->getLocalizedDescription()|strip_unsafe_html|truncate:220}
			</div>
		{/if}

		<a class="riara-issue-card__cta" href="{$issueUrl|escape}">
			{translate key="plugins.themes.riarauniversity.archive.viewIssue"}
			<span class="fa fa-arrow-right" aria-hidden="true"></span>
		</a>
	</div>
</article>
