{**
 * Riara University — single announcement page.
 *}
{include file="frontend/components/header.tpl" pageTitleTranslated=$announcement->getLocalizedData('title')|escape}

<div class="page page_announcement riara-page riara-page--announcement riara-inner">
	{include file="frontend/components/breadcrumbs_announcement.tpl" currentTitle=$announcement->getLocalizedData('title')|escape}

	{include file="frontend/objects/announcement_full.tpl"}
</div>

{include file="frontend/components/footer.tpl"}
