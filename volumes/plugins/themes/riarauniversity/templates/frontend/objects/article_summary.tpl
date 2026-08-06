{**
 * Riara University — article card for lists (search, issue TOC).
 *}
{assign var=publication value=$article->getCurrentPublication()}

{assign var=articlePath value=$publication->getData('urlPath')|default:$article->getId()}
{if !$heading}
	{assign var="heading" value="h2"}
{/if}

{if is_array($section)}
	{assign var=sectionHideAuthor value=$section.hideAuthor}
{elseif $section}
	{assign var=sectionHideAuthor value=$section->getHideAuthor()}
{else}
	{assign var=sectionHideAuthor value=false}
{/if}

{if (!$sectionHideAuthor && $publication->getData('hideAuthor') == APP\submission\Submission::AUTHOR_TOC_DEFAULT) || $publication->getData('hideAuthor') == APP\submission\Submission::AUTHOR_TOC_SHOW}
	{assign var="showAuthor" value=true}
{/if}

<div class="obj_article_summary riara-article-card">
	<div class="riara-article-card__body">
		{if $publication->getLocalizedData('coverImage')}
			<div class="cover riara-article-card__cover">
				<a {if $journal}href="{url journal=$journal->getPath() page="article" op="view" path=$articlePath}"{else}href="{url page="article" op="view" path=$articlePath}"{/if} class="file">
					{assign var="coverImage" value=$publication->getLocalizedData('coverImage')}
					<img
						src="{$publication->getLocalizedCoverImageUrl($article->getData('contextId'))|escape}"
						alt="{$coverImage.altText|escape|default:''}"
					>
				</a>
			</div>
		{/if}

		<div class="riara-article-card__content">
			<{$heading} class="title">
				<a id="article-{$article->getId()}" {if $journal}href="{url journal=$journal->getPath() page="article" op="view" path=$articlePath}"{else}href="{url page="article" op="view" path=$articlePath}"{/if}>
					{if $currentContext}
						{$publication->getLocalizedTitle(null, 'html')|strip_unsafe_html}
						{assign var=localizedSubtitle value=$publication->getLocalizedSubtitle(null, 'html')|strip_unsafe_html}
						{if $localizedSubtitle}
							<span class="subtitle">{$localizedSubtitle}</span>
						{/if}
					{else}
						{$publication->getLocalizedFullTitle(null, 'html')|strip_unsafe_html}
						<span class="subtitle">
							{$journal->getLocalizedName()|escape}
						</span>
					{/if}
				</a>
			</{$heading}>

			{assign var=submissionPages value=$publication->getData('pages')}
			{assign var=submissionDatePublished value=$publication->getData('datePublished')}
			{if $showAuthor || $submissionPages || ($submissionDatePublished && $showDatePublished)}
				<div class="meta riara-article-card__meta">
					{if $showAuthor}
						<div class="authors">
							<span class="fa fa-user" aria-hidden="true"></span>
							{$publication->getAuthorString($authorUserGroups)|escape}
						</div>
					{/if}

					{if $submissionPages}
						<div class="pages">
							<span class="fa fa-file-text-o" aria-hidden="true"></span>
							{$submissionPages|escape}
						</div>
					{/if}

					{if $showDatePublished && $submissionDatePublished}
						<div class="published">
							<span class="fa fa-calendar" aria-hidden="true"></span>
							{$submissionDatePublished|date_format:$dateFormatShort}
						</div>
					{/if}
				</div>
			{/if}
		</div>
	</div>

	{if !$hideGalleys}
		<ul class="galleys_links riara-article-card__galleys">
			{foreach from=$publication->getData('galleys') item=galley}
				{if $primaryGenreIds}
					{assign var="file" value=$galley->getFile()}
					{if !$galley->getData('urlRemote') && !($file && in_array($file->getGenreId(), $primaryGenreIds))}
						{continue}
					{/if}
				{/if}
				<li>
					{assign var="hasArticleAccess" value=$hasAccess}
					{if $currentContext->getSetting('publishingMode') == APP\journal\Journal::PUBLISHING_MODE_OPEN || $publication->getData('accessStatus') == APP\submission\Submission::ARTICLE_ACCESS_OPEN}
						{assign var="hasArticleAccess" value=1}
					{/if}
					{assign var="id" value="article-{$article->getId()}-galley-{$galley->getId()}"}
					{include file="frontend/objects/galley_link.tpl" parent=$article publication=$publication id=$id labelledBy="{$id} article-{$article->getId()}" hasAccess=$hasArticleAccess purchaseFee=$currentJournal->getData('purchaseArticleFee') purchaseCurrency=$currentJournal->getData('currency')}
				</li>
			{/foreach}
		</ul>
	{/if}

	{call_hook name="Templates::Issue::Issue::Article"}
</div>
