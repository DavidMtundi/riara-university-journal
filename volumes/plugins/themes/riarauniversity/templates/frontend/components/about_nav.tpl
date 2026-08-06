{**
 * Riara University — about section sidebar navigation.
 *}
<nav class="riara-about-nav" aria-labelledby="riara-about-nav-title">
	<p id="riara-about-nav-title" class="riara-about-nav__title">{translate key="plugins.themes.riarauniversity.about.navTitle"}</p>
	<ul class="riara-about-nav__list">
		<li>
			<a class="riara-about-nav__link{if $requestedPage == 'about' && (!$requestedOp || $requestedOp == 'index')} is-active{/if}" href="{url page="about"}">
				{translate key="about.aboutContext"}
			</a>
		</li>
		<li>
			<a class="riara-about-nav__link{if $requestedPage == 'about' && $requestedOp == 'submissions'} is-active{/if}" href="{url page="about" op="submissions"}">
				{translate key="about.submissions"}
			</a>
		</li>
		<li>
			<a class="riara-about-nav__link{if $requestedPage == 'about' && $requestedOp == 'editorialMasthead'} is-active{/if}" href="{url page="about" op="editorialMasthead"}">
				{translate key="common.editorialMasthead"}
			</a>
		</li>
		<li>
			<a class="riara-about-nav__link{if $requestedPage == 'about' && $requestedOp == 'editorialHistory'} is-active{/if}" href="{url page="about" op="editorialHistory"}">
				{translate key="common.editorialHistory"}
			</a>
		</li>
		<li>
			<a class="riara-about-nav__link{if $requestedPage == 'about' && $requestedOp == 'policies'} is-active{/if}" href="{url page="about" op="policies"}">
				{translate key="plugins.themes.riarauniversity.footer.policies"}
			</a>
		</li>
		<li>
			<a class="riara-about-nav__link{if $requestedPage == 'about' && $requestedOp == 'contact'} is-active{/if}" href="{url page="about" op="contact"}">
				{translate key="common.contact"}
			</a>
		</li>
		<li>
			<a class="riara-about-nav__link{if $requestedPage == 'about' && $requestedOp == 'privacy'} is-active{/if}" href="{url page="about" op="privacy"}">
				{translate key="about.privacyStatement"}
			</a>
		</li>
	</ul>
</nav>
