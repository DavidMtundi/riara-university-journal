{**
 * Riara University — account activation confirmation page.
 *}
{include file="frontend/components/header.tpl" pageTitle=$pageTitle}

<div class="page user_confirm_activation riara-page riara-page--auth riara-page--auth-activate">
	<div class="riara-auth riara-auth--immersive">
		{include file="frontend/components/auth_scene.tpl" authSceneVariant="activate"}

		<div class="riara-auth__main">
			<div class="riara-auth__form-card">
				<header class="riara-auth__form-header">
					{if $currentContext}
						<p class="riara-auth__journal">{$currentContext->getLocalizedName()|escape}</p>
					{/if}
					<h1>{translate key=$pageTitle}</h1>
					<p class="riara-auth__subtitle">{translate key="user.login.activate.description"}</p>
				</header>

				<div class="riara-auth__help" role="note">
					<span class="riara-auth__help-icon fa fa-envelope-o" aria-hidden="true"></span>
					<p>{translate key="plugins.themes.riarauniversity.auth.activateHelp"}</p>
				</div>

				<div class="riara-form__actions riara-form__actions--stacked">
					<a href="{$activationUrl|escape}" class="riara-btn riara-btn--primary riara-btn--block">
						{translate key="user.login.activate"}
						<span class="fa fa-arrow-right" aria-hidden="true"></span>
					</a>
					<a class="riara-auth__back-link" href="{url page="login"}">
						<span class="fa fa-arrow-left" aria-hidden="true"></span>
						{translate key="user.login"}
					</a>
				</div>

				{include file="frontend/components/auth_trust.tpl"}
			</div>
		</div>
	</div>
</div>

{include file="frontend/components/footer.tpl"}
