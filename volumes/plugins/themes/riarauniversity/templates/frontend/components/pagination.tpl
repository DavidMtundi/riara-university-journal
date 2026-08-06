{**
 * Riara University — pagination controls.
 *
 * @uses $prevUrl string
 * @uses $nextUrl string
 * @uses $showingStart int
 * @uses $showingEnd int
 * @uses $total int
 *}
{if $prevUrl || $nextUrl}
	<nav class="cmp_pagination riara-pagination" aria-label="{translate|escape key="common.pagination.label"}">
		{if $prevUrl}
			<a class="riara-pagination__btn riara-pagination__btn--prev prev" href="{$prevUrl|escape}">
				<span class="fa fa-arrow-left" aria-hidden="true"></span>
				{translate key="help.previous"}
			</a>
		{else}
			<span class="riara-pagination__spacer" aria-hidden="true"></span>
		{/if}

		<span class="riara-pagination__status current">
			{translate key="common.pagination" start=$showingStart end=$showingEnd total=$total}
		</span>

		{if $nextUrl}
			<a class="riara-pagination__btn riara-pagination__btn--next next" href="{$nextUrl|escape}">
				{translate key="help.next"}
				<span class="fa fa-arrow-right" aria-hidden="true"></span>
			</a>
		{else}
			<span class="riara-pagination__spacer" aria-hidden="true"></span>
		{/if}
	</nav>
{/if}
