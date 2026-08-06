{**
 * plugins/generic/googleOAuth/templates/oauthButton.tpl
 *}
{if $googleOAuthEnabled}
	<div class="riara-auth__oauth">
		<a class="riara-btn riara-btn--google" href="{$googleOAuthAuthorizeUrl|escape}">
			<span class="riara-btn__google-icon" aria-hidden="true">G</span>
			{translate key="plugins.generic.googleOAuth.signInWithGoogle"}
		</a>
		<p class="riara-auth__oauth-divider"><span>{translate key="plugins.generic.googleOAuth.orContinueWith"}</span></p>
	</div>
{/if}
