{**
 * Riara University — how to cite block with copy action.
 *}
{if !$publication}
	{assign var=publication value=$article->getCurrentPublication()}
{/if}

{capture assign=riaraCitationText}{strip}
{foreach from=$publication->getData('authors') item=author name=citeAuthors}{$author->getFullName()|escape}{if !$smarty.foreach.citeAuthors.last}, {/if}{/foreach}{if $publication->getData('datePublished')} ({$publication->getData('datePublished')|date_format:'Y'}).{/if} {$publication->getLocalizedTitle(null, 'html')|strip_unsafe_html|strip_tags}.{if $currentContext} {$currentContext->getLocalizedName()|escape}.{/if}{if $issue} {$issue->getIssueIdentification()|escape}.{/if}{if $publication->getData('pages')} {$publication->getData('pages')|escape}.{/if}{assign var=riaraDoi value=$publication->getData('doiObject')}{if $riaraDoi} {$riaraDoi->getData('resolvingUrl')|escape}{/if}
{/strip}{/capture}

<section class="riara-citation" aria-labelledby="riara-citation-heading">
	<div class="riara-citation__header">
		<h2 id="riara-citation-heading" class="riara-citation__title">{translate key="plugins.themes.riarauniversity.citation.title"}</h2>
		<button type="button" class="riara-citation__copy riara-btn riara-btn--ghost" data-riara-copy-target="riara-citation-text">
			<span class="fa fa-copy" aria-hidden="true"></span>
			<span class="riara-citation__copy-label">{translate key="plugins.themes.riarauniversity.citation.copy"}</span>
		</button>
	</div>
	<p id="riara-citation-text" class="riara-citation__text" tabindex="0">{$riaraCitationText|trim|escape}</p>
	<p class="riara-citation__hint">{translate key="plugins.themes.riarauniversity.citation.hint"}</p>

	{if $citationStyles|@count}
		{include file="plugins/generic/citationStyleLanguage/citationblock.tpl"}
	{/if}
</section>
