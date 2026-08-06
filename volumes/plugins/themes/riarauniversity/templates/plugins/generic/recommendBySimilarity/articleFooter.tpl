{**
 * Riara University — similar article recommendations.
 *}
{if !$articlesBySimilarity->submissions->isEmpty()}
	<section class="riara-recommendations riara-recommendations--similarity" id="articlesBySimilarityList" aria-labelledby="riara-rec-similarity-heading">
		<h2 id="riara-rec-similarity-heading" class="riara-recommendations__heading">
			{translate key="plugins.generic.recommendBySimilarity.heading"}
		</h2>
		<ul class="riara-recommendations__list">
			{foreach from=$articlesBySimilarity->submissions item=submission}
				{assign var=publication value=$submission->getCurrentPublication()}
				{assign var=issue value=$articlesBySimilarity->issues->get($publication->getData('issueId'))}
				<li class="riara-recommendations__item">
					<a class="riara-recommendations__link" href="{url router=PKP\core\PKPApplication::ROUTE_PAGE journal=$currentContext->getPath() page="article" op="view" path=$submission->getBestId() urlLocaleForPage=""}">
						<span class="riara-recommendations__title">{$publication->getLocalizedFullTitle(null, 'html')|strip_unsafe_html}</span>
						{if $issue}
							<span class="riara-recommendations__meta">{$currentContext->getLocalizedName()|escape}: {$issue->getIssueIdentification()|escape}</span>
						{/if}
					</a>
				</li>
			{/foreach}
		</ul>
		<p id="articlesBySimilarityPages" class="riara-recommendations__pager">
			{include
				file="frontend/components/pagination.tpl"
				prevUrl=$articlesBySimilarity->previousUrl
				nextUrl=$articlesBySimilarity->nextUrl
				showingStart=$articlesBySimilarity->start
				showingEnd=$articlesBySimilarity->end
				total=$articlesBySimilarity->total
			}
		</p>
		<p id="articlesBySimilaritySearch" class="riara-recommendations__search">
			{capture assign="articlesBySimilaritySearchLink"}{strip}
				<a href="{url page="search" op="search" query=$articlesBySimilarity->query}">
					{translate key="plugins.generic.recommendBySimilarity.advancedSearch"}
				</a>
			{/strip}{/capture}
			{translate key="plugins.generic.recommendBySimilarity.advancedSearchIntro" advancedSearchLink=$articlesBySimilaritySearchLink}
		</p>
	</section>
{/if}
