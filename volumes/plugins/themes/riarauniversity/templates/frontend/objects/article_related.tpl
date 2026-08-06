{**
 * Riara University — related articles from the same issue.
 *
 * @uses $riaraRelatedArticles Submission[]
 *}
{if $riaraRelatedArticles|@count}
	<section class="riara-related-articles" aria-labelledby="riara-related-heading">
		<h2 id="riara-related-heading" class="riara-related-articles__heading">
			{translate key="plugins.themes.riarauniversity.article.relatedHeading"}
		</h2>
		<div class="riara-related-articles__grid">
			{foreach from=$riaraRelatedArticles item=relatedArticle}
				{include file="frontend/objects/article_summary.tpl" article=$relatedArticle heading="h3" hideGalleys=true section=[]}
			{/foreach}
		</div>
	</section>
{/if}
