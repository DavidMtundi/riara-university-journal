{**
 * Riara University — article hero (title, authors, meta, downloads).
 *}
{if !$publication}
	{assign var=publication value=$article->getCurrentPublication()}
{/if}

<header class="riara-article-hero" aria-labelledby="riara-article-title">
	<div class="riara-article-hero__content">
		{if $section}
			<p class="riara-kicker">{$section->getLocalizedTitle()|escape}</p>
		{/if}

		<h1 id="riara-article-title" class="riara-article-hero__title">
			{$publication->getLocalizedTitle(null, 'html')|strip_unsafe_html}
		</h1>

		{if $publication->getLocalizedData('subtitle')}
			<p class="riara-article-hero__subtitle">
				{$publication->getLocalizedSubTitle(null, 'html')|strip_unsafe_html}
			</p>
		{/if}

		{if $publication->getData('authors')}
			<ul class="riara-article-hero__authors">
				{foreach from=$publication->getData('authors') item=author name=heroAuthors}
					<li class="riara-article-hero__author">
						<span class="riara-article-hero__author-name">{$author->getFullName()|escape}</span>
						{if count($author->getAffiliations()) > 0}
							<span class="riara-article-hero__author-affiliation">
								{foreach name="affiliations" from=$author->getAffiliations() item="affiliation"}
									{$affiliation->getLocalizedName()|escape}{if !$smarty.foreach.affiliations.last}; {/if}
								{/foreach}
							</span>
						{/if}
					</li>
				{/foreach}
			</ul>
		{/if}

		<dl class="riara-article-hero__meta">
			{if $publication->getData('datePublished')}
				<div class="riara-article-hero__meta-item">
					<dt>{translate key="submissions.published"}</dt>
					<dd><time datetime="{$publication->getData('datePublished')|date_format:'Y-m-d'}">{$publication->getData('datePublished')|date_format:$dateFormatShort}</time></dd>
				</div>
			{/if}
			{if $publication->getData('pages')}
				<div class="riara-article-hero__meta-item">
					<dt>{translate key="plugins.themes.riarauniversity.article.pages"}</dt>
					<dd>{$publication->getData('pages')|escape}</dd>
				</div>
			{/if}
			{if $issue}
				<div class="riara-article-hero__meta-item">
					<dt>{translate key="issue.issue"}</dt>
					<dd>
						<a href="{url page="issue" op="view" path=$issue->getBestIssueId()}">
							{$issue->getIssueIdentification()|escape}
						</a>
					</dd>
				</div>
			{/if}
			{assign var=doiObject value=$publication->getData('doiObject')}
			{if $doiObject}
				{assign var="doiUrl" value=$doiObject->getData('resolvingUrl')|escape}
				<div class="riara-article-hero__meta-item">
					<dt>{translate key="doi.readerDisplayName"}</dt>
					<dd><a href="{$doiUrl}" class="riara-article-hero__doi">{$doiUrl}</a></dd>
				</div>
			{/if}
		</dl>
	</div>

	{if $primaryGalleys|@count}
		<div class="riara-article-hero__downloads" aria-label="{translate key="submission.downloads"}">
			<p class="riara-article-hero__downloads-label">{translate key="submission.downloads"}</p>
			<ul class="riara-article-hero__galleys">
				{foreach from=$primaryGalleys item=galley}
					<li>
						{include file="frontend/objects/galley_link.tpl" parent=$article publication=$publication galley=$galley purchaseFee=$currentJournal->getData('purchaseArticleFee') purchaseCurrency=$currentJournal->getData('currency')}
					</li>
				{/foreach}
			</ul>
		</div>
	{/if}
</header>
