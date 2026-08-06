{**
 * Riara University — search page.
 *}
{include file="frontend/components/header.tpl" pageTitle="common.search"}

{if !$heading}
	{assign var="heading" value="h2"}
{/if}

<div class="page page_search riara-page riara-page--search riara-inner">
	{include file="frontend/components/breadcrumbs.tpl" currentTitleKey="common.search"}
	<div class="riara-page__header">
		<p class="riara-kicker">{translate key="common.search"}</p>
		<h1>{translate key="common.search"}</h1>
	</div>

	<div class="riara-page__panel riara-search-page">
		{capture name="searchFormUrl"}{url escape=false}{/capture}
		{assign var=formUrlParameters value=[]}
		{$smarty.capture.searchFormUrl|parse_url:$smarty.const.PHP_URL_QUERY|default:""|parse_str:$formUrlParameters}
		<form class="cmp_form riara-search-form" method="get" action="{$smarty.capture.searchFormUrl|strtok:"?"|escape}" role="search">
			{foreach from=$formUrlParameters key=paramKey item=paramValue}
				<input type="hidden" name="{$paramKey|escape}" value="{$paramValue|escape}"/>
			{/foreach}

			<div class="riara-search riara-search--page">
				<label class="riara-search__label pkp_screen_reader" for="query">{translate key="search.searchFor"}</label>
				<span class="riara-search__icon fa fa-search" aria-hidden="true"></span>
				{block name=searchQuery}
					<input type="search" id="query" name="query" value="{$query|escape}" class="riara-search__input query" placeholder="{translate|escape key="common.search"}">
				{/block}
				<button class="riara-search__submit" type="submit">
					<span class="riara-search__submit-text">{translate key="common.search"}</span>
					<span class="riara-search__arrow fa fa-arrow-right" aria-hidden="true"></span>
				</button>
			</div>

			<button type="button" class="riara-search-advanced-toggle" aria-expanded="false" aria-controls="riara-search-advanced">
				{translate key="search.advancedFilters"}
				<span class="fa fa-chevron-down" aria-hidden="true"></span>
			</button>

			<fieldset class="search_advanced riara-search-advanced" id="riara-search-advanced" hidden>
				<legend>{translate key="search.advancedFilters"}</legend>
				<div class="date_range">
					<div class="from">
						{capture assign="dateFromLegend"}{translate key="search.dateFrom"}{/capture}
						{html_select_date_a11y legend=$dateFromLegend prefix="dateFrom" time=$dateFrom start_year=$yearStart end_year=$yearEnd}
					</div>
					<div class="to">
						{capture assign="dateFromTo"}{translate key="search.dateTo"}{/capture}
						{html_select_date_a11y legend=$dateFromTo prefix="dateTo" time=$dateTo start_year=$yearStart end_year=$yearEnd}
					</div>
				</div>
				<div class="author">
					<label class="label" for="authors">{translate key="search.author"}</label>
					{block name=searchAuthors}
						<input type="text" id="authors" name="authors" value="{$authors|escape}">
					{/block}

					{if $searchableContexts}
						<label class="label label_contexts" for="searchJournal">{translate key="search.journal"}</label>
						<select name="searchJournal" id="searchJournal">
							<option></option>
							{foreach from=$searchableContexts item="searchableContext"}
								<option value="{$searchableContext->id}" {if $searchJournal == $searchableContext->id}selected{/if}>
									{$searchableContext->name|escape}
								</option>
							{/foreach}
						</select>
					{/if}
				</div>
				{call_hook name="Templates::Search::SearchResults::AdditionalFilters"}
			</fieldset>
		</form>
	</div>

	{call_hook name="Templates::Search::SearchResults::PreResults"}

	<div class="riara-search-results">
		<h2 class="pkp_screen_reader">{translate key="search.searchResults"}</h2>

		{if !$results->wasEmpty()}
			{assign var="count" value=$results->count}
			<div class="riara-search-results__meta" role="status">
				<span class="riara-search-results__badge">
					{if $results->count > 1}
						{translate key="search.searchResults.foundPlural" count=$results->count}
					{else}
						{translate key="search.searchResults.foundSingle"}
					{/if}
				</span>
			</div>
		{/if}

		<ul class="search_results riara-search-results__list">
			{iterate from=results item=result}
				<li class="riara-search-results__item">
					{include file="frontend/objects/article_summary.tpl" article=$result.publishedSubmission journal=$result.journal showDatePublished=true hideGalleys=true heading="h3"}
				</li>
			{/iterate}
		</ul>

		{if $results->wasEmpty()}
			<div class="riara-search-empty" role="status">
				<div class="riara-search-empty__icon fa fa-search" aria-hidden="true"></div>
				{if $error}
					{include file="frontend/components/notification.tpl" type="error" message=$error|escape}
				{else}
					<h3 class="riara-search-empty__title">{translate key="plugins.themes.riarauniversity.search.emptyTitle"}</h3>
					<p class="riara-search-empty__text">{translate key="plugins.themes.riarauniversity.search.emptyText"}</p>
				{/if}
			</div>
		{else}
			<div class="cmp_pagination">
				{page_info iterator=$results}
				{page_links anchor="results" iterator=$results name="search" query=$query searchJournal=$searchJournal authors=$authors dateFromMonth=$dateFromMonth dateFromDay=$dateFromDay dateFromYear=$dateFromYear dateToMonth=$dateToMonth dateToDay=$dateToDay dateToYear=$dateToYear}
			</div>
		{/if}
	</div>

	{block name=searchSyntaxInstructions}{/block}
</div>

{include file="frontend/components/footer.tpl"}
