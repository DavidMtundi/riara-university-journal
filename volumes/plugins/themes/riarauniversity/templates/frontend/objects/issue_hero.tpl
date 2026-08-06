{**
 * Riara University — issue magazine hero.
 *}
{if !$issue}
	{* no issue *}
{else}
	{assign var=issueCover value=$issue->getLocalizedCoverImageUrl()}
	<section class="riara-issue-hero" aria-labelledby="riara-issue-title">
		<div class="riara-issue-hero__layout">
			{if $issueCover}
				<div class="riara-issue-hero__cover">
					{capture assign="defaultAltText"}
						{translate key="issue.viewIssueIdentification" identification=$issue->getIssueIdentification()|escape}
					{/capture}
					<img src="{$issueCover|escape}" alt="{$issue->getLocalizedCoverImageAltText()|escape|default:$defaultAltText}">
				</div>
			{/if}

			<div class="riara-issue-hero__content">
				{if $riaraIssueIsCurrent}
					<p class="riara-kicker">{translate key="journal.currentIssue"}</p>
				{else}
					<p class="riara-kicker">{translate key="plugins.themes.riarauniversity.issue.kicker"}</p>
				{/if}
				<h1 id="riara-issue-title" class="riara-issue-hero__title">{$issueIdentification|escape}</h1>

				{if $issue->hasDescription()}
					<div class="riara-issue-hero__description riara-prose">
						{$issue->getLocalizedDescription()|strip_unsafe_html|truncate:420}
					</div>
				{/if}

				<dl class="riara-issue-hero__meta">
					{if $issue->getDatePublished()}
						<div class="riara-issue-hero__meta-item">
							<dt>{translate key="submissions.published"}</dt>
							<dd><time datetime="{$issue->getDatePublished()|date_format:'Y-m-d'}">{$issue->getDatePublished()|date_format:$dateFormatShort}</time></dd>
						</div>
					{/if}
					{assign var=doiObject value=$issue->getData('doiObject')}
					{if $doiObject}
						<div class="riara-issue-hero__meta-item">
							<dt>DOI</dt>
							<dd><a href="{$doiObject->getData('resolvingUrl')|escape}">{$doiObject->getData('resolvingUrl')|escape}</a></dd>
						</div>
					{/if}
				</dl>

				<div class="riara-issue-hero__actions">
					{if $issueGalleys|@count}
						<ul class="riara-issue-hero__galleys">
							{foreach from=$issueGalleys item=galley}
								<li>
									{include file="frontend/objects/galley_link.tpl" parent=$issue labelledBy="riara-issue-title" purchaseFee=$currentJournal->getData('purchaseIssueFee') purchaseCurrency=$currentJournal->getData('currency')}
								</li>
							{/foreach}
						</ul>
					{/if}
					<a class="riara-btn riara-btn--ghost" href="{url page="issue" op="archive"}">{translate key="navigation.archives"}</a>
				</div>
			</div>
		</div>
	</section>
{/if}
