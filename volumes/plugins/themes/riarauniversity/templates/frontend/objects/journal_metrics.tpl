{**
 * Riara University — public journal metrics.
 *
 * @uses $riaraJournalMetrics array
 *}
<section class="riara-metrics" aria-labelledby="riara-metrics-heading">
	<h2 id="riara-metrics-heading" class="pkp_screen_reader">{translate key="plugins.themes.riarauniversity.metrics.heading"}</h2>

	<div class="riara-metrics__grid">
		<div class="riara-metrics__card">
			<p class="riara-metrics__value" data-riara-count="{$riaraJournalMetrics.published|default:0|escape}">{$riaraJournalMetrics.published|default:0|escape}</p>
			<p class="riara-metrics__label">{translate key="plugins.themes.riarauniversity.stats.published"}</p>
		</div>
		<div class="riara-metrics__card">
			<p class="riara-metrics__value" data-riara-count="{$riaraJournalMetrics.issues|default:0|escape}">{$riaraJournalMetrics.issues|default:0|escape}</p>
			<p class="riara-metrics__label">{translate key="plugins.themes.riarauniversity.stats.issues"}</p>
		</div>
		<div class="riara-metrics__card">
			<p class="riara-metrics__value">{$riaraJournalMetrics.downloads|default:0|escape}</p>
			<p class="riara-metrics__label">{translate key="plugins.themes.riarauniversity.metrics.downloads"}</p>
		</div>
		<div class="riara-metrics__card">
			<p class="riara-metrics__value">{$riaraJournalMetrics.authors|default:0|escape}</p>
			<p class="riara-metrics__label">{translate key="plugins.themes.riarauniversity.metrics.authors"}</p>
		</div>
	</div>

	<div class="riara-metrics__note riara-prose">
		<p>{translate key="plugins.themes.riarauniversity.metrics.note"}</p>
		{if $currentJournal && $currentJournal->getData('onlineIssn')}
			<p><strong>ISSN (online):</strong> {$currentJournal->getData('onlineIssn')|escape}</p>
		{/if}
		{if $currentJournal && $currentJournal->getData('doiPrefix')}
			<p><strong>DOI prefix:</strong> {$currentJournal->getData('doiPrefix')|escape}</p>
		{/if}
	</div>
</section>
