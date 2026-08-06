{**
 * Riara University — Citation Style Language block.
 *}
{if $citation}
	<div class="riara-csl">
		<div class="riara-csl__output" id="citationOutput" role="region" aria-live="polite">
			{$citation}
		</div>

		<div class="riara-csl__formats">
			<button class="riara-csl__toggle riara-btn riara-btn--ghost" type="button" aria-controls="cslCitationFormats" aria-expanded="false" data-csl-dropdown="true">
				<span class="fa fa-quote-right" aria-hidden="true"></span>
				{translate key="submission.howToCite.citationFormats"}
			</button>

			<div id="cslCitationFormats" class="riara-csl__menu" aria-hidden="true">
				<ul class="riara-csl__styles">
					{foreach from=$citationStyles item="citationStyle"}
						<li>
							<a
								rel="nofollow"
								aria-controls="citationOutput"
								href="{url page="citationstylelanguage" op="get" path=$citationStyle.id params=$citationArgs}"
								data-load-citation
								data-json-href="{url page="citationstylelanguage" op="get" path=$citationStyle.id params=$citationArgsJson}"
							>
								{$citationStyle.title|escape}
							</a>
						</li>
					{/foreach}
				</ul>

				{if count($citationDownloads)}
					<p class="riara-csl__downloads-label">{translate key="submission.howToCite.downloadCitation"}</p>
					<ul class="riara-csl__styles">
						{foreach from=$citationDownloads item="citationDownload"}
							<li>
								<a href="{url page="citationstylelanguage" op="download" path=$citationDownload.id params=$citationArgs}">
									<span class="fa fa-download" aria-hidden="true"></span>
									{$citationDownload.title|escape}
								</a>
							</li>
						{/foreach}
					</ul>
				{/if}
			</div>
		</div>
	</div>
{/if}
