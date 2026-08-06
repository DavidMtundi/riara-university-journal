{**
 * Riara University — issue archive page.
 *}
{capture assign="pageTitle"}
	{if $prevPage}
		{translate key="archive.archivesPageNumber" pageNumber=$prevPage+1}
	{else}
		{translate key="archive.archives"}
	{/if}
{/capture}
{include file="frontend/components/header.tpl" pageTitleTranslated=$pageTitle}

<div class="page page_issue_archive riara-page riara-page--archive riara-inner">
	{include file="frontend/components/breadcrumbs.tpl" currentTitle=$pageTitle}
	<div class="riara-page__header">
		<p class="riara-kicker">{translate key="navigation.archives"}</p>
		<h1>{$pageTitle|escape}</h1>
	</div>

	{if empty($issues)}
		<div class="riara-page__panel">
			<p>{translate key="current.noCurrentIssueDesc"}</p>
		</div>
	{else}
		<ul class="issues_archive riara-archive">
			{foreach from=$issues item="issue"}
				<li class="riara-archive__item">
					{include file="frontend/objects/issue_summary.tpl"}
				</li>
			{/foreach}
		</ul>

		{if $prevPage > 1}
			{capture assign=prevUrl}{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="archive" path=$prevPage}{/capture}
		{elseif $prevPage === 1}
			{capture assign=prevUrl}{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="archive"}{/capture}
		{/if}
		{if $nextPage}
			{capture assign=nextUrl}{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="archive" path=$nextPage}{/capture}
		{/if}
		{include
			file="frontend/components/pagination.tpl"
			prevUrl=$prevUrl
			nextUrl=$nextUrl
			showingStart=$showingStart
			showingEnd=$showingEnd
			total=$total
		}
	{/if}
</div>

{include file="frontend/components/footer.tpl"}
