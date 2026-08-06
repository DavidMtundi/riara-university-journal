{**
 * Riara University — immersive auth brand scene (login, register, reset).
 *
 * @uses $authSceneVariant string login|register|reset
 *}
<aside class="riara-auth__scene" aria-labelledby="riara-auth-scene-title">
	<div class="riara-auth__scene-bg" aria-hidden="true">
		<span class="riara-auth__orb riara-auth__orb--1"></span>
		<span class="riara-auth__orb riara-auth__orb--2"></span>
		<span class="riara-auth__grain"></span>
		<span class="riara-auth__watermark">RIARA</span>
	</div>

	<div class="riara-auth__scene-content">
		<p class="riara-auth__eyebrow">{translate key="plugins.themes.riarauniversity.auth.kicker"}</p>

		{if $authSceneVariant == 'register'}
			<h2 id="riara-auth-scene-title" class="riara-auth__scene-title">{translate key="plugins.themes.riarauniversity.auth.registerTitle"}</h2>
			<p class="riara-auth__scene-text">{translate key="plugins.themes.riarauniversity.auth.registerText"}</p>

			<ul class="riara-auth__highlights">
				<li>
					<span class="riara-auth__highlight-icon" aria-hidden="true"><span class="fa fa-graduation-cap"></span></span>
					<span>{translate key="plugins.themes.riarauniversity.auth.registerHighlight1"}</span>
				</li>
				<li>
					<span class="riara-auth__highlight-icon" aria-hidden="true"><span class="fa fa-file-text-o"></span></span>
					<span>{translate key="plugins.themes.riarauniversity.auth.registerHighlight2"}</span>
				</li>
				<li>
					<span class="riara-auth__highlight-icon" aria-hidden="true"><span class="fa fa-users"></span></span>
					<span>{translate key="plugins.themes.riarauniversity.auth.registerHighlight3"}</span>
				</li>
			</ul>

			<div class="riara-auth__showcase" aria-hidden="true">
				<div class="riara-auth__showcase-card riara-auth__showcase-card--1">
					<span class="riara-auth__showcase-label">{translate key="plugins.themes.riarauniversity.pill.peerReviewed"}</span>
				</div>
				<div class="riara-auth__showcase-card riara-auth__showcase-card--2">
					<span class="riara-auth__showcase-label">{translate key="plugins.themes.riarauniversity.pill.openAccess"}</span>
				</div>
			</div>
		{elseif $authSceneVariant == 'reset'}
			<h2 id="riara-auth-scene-title" class="riara-auth__scene-title">{translate key="plugins.themes.riarauniversity.auth.lostPasswordTitle"}</h2>
			<p class="riara-auth__scene-text">{translate key="plugins.themes.riarauniversity.auth.lostPasswordText"}</p>

			<ol class="riara-auth__steps">
				<li class="riara-auth__step is-active">
					<span class="riara-auth__step-index" aria-hidden="true">1</span>
					<span class="riara-auth__step-copy">{translate key="plugins.themes.riarauniversity.auth.resetStep1"}</span>
				</li>
				<li class="riara-auth__step">
					<span class="riara-auth__step-index" aria-hidden="true">2</span>
					<span class="riara-auth__step-copy">{translate key="plugins.themes.riarauniversity.auth.resetStep2"}</span>
				</li>
				<li class="riara-auth__step">
					<span class="riara-auth__step-index" aria-hidden="true">3</span>
					<span class="riara-auth__step-copy">{translate key="plugins.themes.riarauniversity.auth.resetStep3"}</span>
				</li>
			</ol>
		{elseif $authSceneVariant == 'activate'}
			<h2 id="riara-auth-scene-title" class="riara-auth__scene-title">{translate key="plugins.themes.riarauniversity.auth.activateTitle"}</h2>
			<p class="riara-auth__scene-text">{translate key="plugins.themes.riarauniversity.auth.activateText"}</p>

			<ul class="riara-auth__highlights">
				<li>
					<span class="riara-auth__highlight-icon" aria-hidden="true"><span class="fa fa-envelope-o"></span></span>
					<span>{translate key="plugins.themes.riarauniversity.auth.activateHighlight1"}</span>
				</li>
				<li>
					<span class="riara-auth__highlight-icon" aria-hidden="true"><span class="fa fa-check-circle"></span></span>
					<span>{translate key="plugins.themes.riarauniversity.auth.activateHighlight2"}</span>
				</li>
			</ul>
		{elseif $authSceneVariant == 'complete'}
			<h2 id="riara-auth-scene-title" class="riara-auth__scene-title">{translate key="plugins.themes.riarauniversity.auth.completeTitle"}</h2>
			<p class="riara-auth__scene-text">{translate key="plugins.themes.riarauniversity.auth.completeText"}</p>

			<ul class="riara-auth__highlights">
				<li>
					<span class="riara-auth__highlight-icon" aria-hidden="true"><span class="fa fa-file-text-o"></span></span>
					<span>{translate key="plugins.themes.riarauniversity.auth.completeHighlight1"}</span>
				</li>
				<li>
					<span class="riara-auth__highlight-icon" aria-hidden="true"><span class="fa fa-user"></span></span>
					<span>{translate key="plugins.themes.riarauniversity.auth.completeHighlight2"}</span>
				</li>
				<li>
					<span class="riara-auth__highlight-icon" aria-hidden="true"><span class="fa fa-book"></span></span>
					<span>{translate key="plugins.themes.riarauniversity.auth.completeHighlight3"}</span>
				</li>
			</ul>
		{else}
			<h2 id="riara-auth-scene-title" class="riara-auth__scene-title">{translate key="plugins.themes.riarauniversity.auth.loginTitle"}</h2>
			<p class="riara-auth__scene-text">{translate key="plugins.themes.riarauniversity.auth.loginText"}</p>

			<ul class="riara-auth__highlights">
				<li>
					<span class="riara-auth__highlight-icon" aria-hidden="true"><span class="fa fa-pencil"></span></span>
					<span>{translate key="plugins.themes.riarauniversity.auth.loginHighlight1"}</span>
				</li>
				<li>
					<span class="riara-auth__highlight-icon" aria-hidden="true"><span class="fa fa-line-chart"></span></span>
					<span>{translate key="plugins.themes.riarauniversity.auth.loginHighlight2"}</span>
				</li>
				<li>
					<span class="riara-auth__highlight-icon" aria-hidden="true"><span class="fa fa-unlock-alt"></span></span>
					<span>{translate key="plugins.themes.riarauniversity.pill.openAccess"}</span>
				</li>
			</ul>

			<div class="riara-auth__showcase" aria-hidden="true">
				<div class="riara-auth__showcase-card riara-auth__showcase-card--1">
					<span class="riara-auth__showcase-label">{translate key="plugins.themes.riarauniversity.pill.peerReviewed"}</span>
				</div>
				<div class="riara-auth__showcase-card riara-auth__showcase-card--2">
					<span class="riara-auth__showcase-label">{translate key="plugins.themes.riarauniversity.auth.loginShowcase"}</span>
				</div>
			</div>
		{/if}

		<a class="riara-auth__home-link" href="{url page="index" router=PKP\core\PKPApplication::ROUTE_PAGE}">
			<span class="fa fa-arrow-left" aria-hidden="true"></span>
			{translate key="plugins.themes.riarauniversity.auth.backToJournal"}
		</a>
	</div>
</aside>
