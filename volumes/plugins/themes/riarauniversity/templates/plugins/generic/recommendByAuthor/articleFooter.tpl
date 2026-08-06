{**
 * Riara University — more by same author recommendations.
 *}
{if !$articlesBySameAuthor->wasEmpty()}
	<section class="riara-recommendations riara-recommendations--author" id="articlesBySameAuthorList" aria-labelledby="riara-rec-author-heading">
		<h2 id="riara-rec-author-heading" class="riara-recommendations__heading">{translate key="plugins.generic.recommendByAuthor.heading"}</h2>
		<ul class="riara-recommendations__list">
			{iterate from=articlesBySameAuthor item=articleBySameAuthor}
				{assign var=submission value=$articleBySameAuthor.publishedSubmission}
				{assign var=article value=$articleBySameAuthor.article}
				{assign var=issue value=$articleBySameAuthor.issue}
				{assign var=journal value=$articleBySameAuthor.journal}
				{assign var=publication value=$article->getCurrentPublication()}
				<li class="riara-recommendations__item">
					<a class="riara-recommendations__link" href="{url router=PKP\core\PKPApplication::ROUTE_PAGE journal=$journal->getPath() page="article" op="view" path=$submission->getBestId() urlLocaleForPage=""}">
						<span class="riara-recommendations__title">{$publication->getLocalizedFullTitle(null, 'html')|strip_unsafe_html}</span>
						<span class="riara-recommendations__meta">
							{$journal->getLocalizedName()|escape}{if $issue}: {$issue->getIssueIdentification()|escape}{/if}
						</span>
					</a>
				</li>
			{/iterate}
		</ul>
		<div id="articlesBySameAuthorPages" class="riara-recommendations__pager">
			{page_links anchor="articlesBySameAuthor" iterator=$articlesBySameAuthor name="articlesBySameAuthor"}
		</div>
	</section>
{/if}
