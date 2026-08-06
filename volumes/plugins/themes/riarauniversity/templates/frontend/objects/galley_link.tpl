{**
 * Riara University — galley download / view link (pill button).
 *}
{if $journalOverride}
	{assign var="currentJournal" value=$journalOverride}
{/if}

{if $galley->isPdfGalley()}
	{assign var="type" value="pdf"}
	{assign var="icon" value="fa-file-pdf-o"}
{else}
	{assign var="type" value="file"}
	{assign var="icon" value="fa-file-text-o"}
{/if}

{if $parent instanceOf APP\issue\Issue}
	{assign var="page" value="issue"}
	{assign var="parentId" value=$parent->getBestIssueId()}
	{assign var="path" value=$parentId|to_array:$galley->getBestGalleyId()}
{else}
	{assign var="page" value="article"}
	{if $publication}
		{if $publication->getId() !== $parent->getData('currentPublicationId')}
			{assign var="path" value=$parent->getBestId()|to_array:"version":$publication->getId():$galley->getBestGalleyId()}
		{else}
			{assign var="parentId" value=$publication->getData('urlPath')|default:$article->getId()}
			{assign var="path" value=$parentId|to_array:$galley->getBestGalleyId()}
		{/if}
	{else}
		{assign var="path" value=$parent->getBestId()|to_array:$galley->getBestGalleyId()}
	{/if}
{/if}

{if !$hasAccess}
	{if $restrictOnlyPdf && $type=="pdf"}
		{assign var=restricted value="1"}
	{elseif !$restrictOnlyPdf}
		{assign var=restricted value="1"}
	{/if}
{/if}

<a
	class="riara-galley-link obj_galley_link {$type|escape}{if $isSupplementary} obj_galley_link_supplementary{/if}{if $restricted} restricted{/if}"
	href="{url page=$page op="view" path=$path}"
	{if $id} id="{$id}"{/if}
	{if $labelledBy} aria-labelledby="{$labelledBy}"{/if}
>
	{if $restricted}
		<span class="pkp_screen_reader">
			{if $purchaseArticleEnabled}
				{translate key="reader.subscriptionOrFeeAccess"}
			{else}
				{translate key="reader.subscriptionAccess"}
			{/if}
		</span>
	{/if}

	<span class="riara-galley-link__icon fa {$icon|escape}" aria-hidden="true"></span>
	<span class="riara-galley-link__label">{$galley->getGalleyLabel()|escape}</span>
	<span class="riara-galley-link__action">
		{if $type == "pdf"}
			{translate key="plugins.themes.riarauniversity.galley.view"}
		{else}
			{translate key="plugins.themes.riarauniversity.galley.download"}
		{/if}
	</span>

	{if $restricted && $purchaseFee && $purchaseCurrency}
		<span class="riara-galley-link__price purchase_cost">
			{translate key="reader.purchasePrice" price=$purchaseFee currency=$purchaseCurrency}
		</span>
	{/if}
</a>
