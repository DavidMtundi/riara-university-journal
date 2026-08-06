{**
 * Riara theme — global editorial footer.
 *}

	</div><!-- pkp_structure_main -->

	{if empty($isFullWidth)}
		{capture assign="sidebarCode"}{call_hook name="Templates::Common::Sidebar"}{/capture}
		{if $sidebarCode}
			<div class="pkp_structure_sidebar left" role="complementary">
				{$sidebarCode}
			</div>
		{/if}
	{/if}
</div><!-- pkp_structure_content -->

<footer class="pkp_structure_footer_wrapper riara-footer" role="contentinfo">
	<a id="pkp_content_footer"></a>

	<div class="riara-footer__main">
		<div class="riara-footer__brand">
			<p class="riara-footer__logo">
				{if $currentContext}
					{$currentContext->getLocalizedName()|escape}
				{else}
					{$siteTitle|escape}
				{/if}
			</p>
			<p class="riara-footer__tagline">
				{translate key="plugins.themes.riarauniversity.footer.tagline"}
			</p>
		</div>

		<div class="riara-footer__columns">
			<div class="riara-footer__col">
				<h3 class="riara-footer__heading">{translate key="plugins.themes.riarauniversity.footer.journal"}</h3>
				<ul class="riara-footer__links">
					<li><a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="current"}">{translate key="navigation.current"}</a></li>
					<li><a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="archive"}">{translate key="navigation.archives"}</a></li>
					<li><a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="about" op="submissions"}">{translate key="about.submissions"}</a></li>
					<li><a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="search"}">{translate key="common.search"}</a></li>
				</ul>
			</div>
			<div class="riara-footer__col">
				<h3 class="riara-footer__heading">{translate key="about.aboutContext"}</h3>
				<ul class="riara-footer__links">
					<li><a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="about" op="policies"}">{translate key="plugins.themes.riarauniversity.footer.policies"}</a></li>
					<li><a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="about" op="indexing"}">{translate key="plugins.themes.riarauniversity.footer.indexing"}</a></li>
					<li><a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="about" op="metrics"}">{translate key="plugins.themes.riarauniversity.footer.metrics"}</a></li>
					<li><a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="about"}">{translate key="navigation.about"}</a></li>
					<li><a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="about" op="editorialMasthead"}">{translate key="common.editorialMasthead"}</a></li>
					<li><a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="about" op="privacy"}">{translate key="about.privacyStatement"}</a></li>
				</ul>
			</div>
			<div class="riara-footer__col">
				<h3 class="riara-footer__heading">{translate key="plugins.themes.riarauniversity.footer.contact"}</h3>
				<ul class="riara-footer__links">
					{if $currentContext && $currentContext->getData('contactEmail')}
						<li><a href="mailto:{$currentContext->getData('contactEmail')|escape}">{$currentContext->getData('contactEmail')|escape}</a></li>
					{/if}
					<li>{translate key="plugins.themes.riarauniversity.footer.location"}</li>
					<li><a href="https://riarauniversity.ac.ke" rel="noopener noreferrer">riarauniversity.ac.ke</a></li>
				</ul>
			</div>
		</div>
	</div>

	<div class="pkp_structure_footer riara-footer__base">
		{if $pageFooter}
			<div class="pkp_footer_content">
				{$pageFooter}
			</div>
		{/if}

		<div class="riara-footer__credit">
			<p class="riara-footer__copyright">
				&copy; {$smarty.now|date_format:'Y'} {translate key="plugins.themes.riarauniversity.footer.copyright"}
			</p>
			<p class="riara-footer__publisher">
				<a href="https://riarauniversity.ac.ke" rel="noopener noreferrer">{translate key="plugins.themes.riarauniversity.footer.publisherLink"}</a>
			</p>
		</div>
	</div>
</footer>

</div><!-- pkp_structure_page -->

{load_script context="frontend"}

{call_hook name="Templates::Common::Footer::PageFooter"}
</body>
</html>
