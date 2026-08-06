{**
 * Riara University — login page.
 *}
{include file="frontend/components/header.tpl" pageTitle="user.login"}

<div class="page page_login riara-page riara-page--auth riara-page--auth-login">
	<div class="riara-auth riara-auth--immersive">
		{include file="frontend/components/auth_scene.tpl" authSceneVariant="login"}

		<div class="riara-auth__main">
			<div class="riara-auth__form-card">
				<header class="riara-auth__form-header">
					{if $currentContext}
						<p class="riara-auth__journal">{$currentContext->getLocalizedName()|escape}</p>
					{/if}
					<h1>{translate key="user.login"}</h1>
					<p class="riara-auth__subtitle">{translate key="plugins.themes.riarauniversity.auth.loginSubtitle"}</p>
				</header>

				{if $loginMessage}
					<div class="cmp_notification notice riara-auth__notice">
						{translate key=$loginMessage}
					</div>
				{/if}

				{if $googleOAuthEnabled}
					<div class="riara-auth__oauth">
						<a class="riara-btn riara-btn--google" href="{$googleOAuthAuthorizeUrl|escape}">
							<span class="riara-btn__google-icon" aria-hidden="true">G</span>
							{translate key="plugins.generic.googleOAuth.signInWithGoogle"}
						</a>
						<p class="riara-auth__oauth-divider"><span>{translate key="plugins.generic.googleOAuth.orContinueWith"}</span></p>
					</div>
				{/if}

				<form class="cmp_form cmp_form login riara-form riara-form--auth" id="login" method="post" action="{$loginUrl}" role="form">
					{csrf}

					{if $error}
						<div class="pkp_form_error riara-auth__error">
							{translate key=$error reason=$reason}
						</div>
					{/if}

					<input type="hidden" name="source" value="{$source|default:""|escape}" />

					<fieldset class="fields">
						<legend class="pkp_screen_reader">{translate key="user.login"}</legend>

						<div class="riara-field username">
							<label class="riara-field__label" for="username">
								{translate key="user.usernameOrEmail"}
								<span class="required" aria-hidden="true">*</span>
								<span class="pkp_screen_reader">{translate key="common.required"}</span>
							</label>
							<div class="riara-field__control">
								<span class="riara-field__icon fa fa-user" aria-hidden="true"></span>
								<input class="riara-field__input" type="text" name="username" id="username" value="{$username|default:""|escape}" required aria-required="true" autocomplete="username">
							</div>
						</div>

						<div class="riara-field password">
							<div class="riara-field__label-row">
								<label class="riara-field__label" for="password">
									{translate key="user.password"}
									<span class="required" aria-hidden="true">*</span>
									<span class="pkp_screen_reader">{translate key="common.required"}</span>
								</label>
								<a class="riara-auth__forgot" href="{url page="login" op="lostPassword"}">
									{translate key="user.login.forgotPassword"}
								</a>
							</div>
							<div class="riara-field__control">
								<span class="riara-field__icon fa fa-lock" aria-hidden="true"></span>
								<input class="riara-field__input" type="password" name="password" id="password" value="{$password|default:""|escape}" password="true" maxlength="32" required aria-required="true" autocomplete="current-password">
								<button class="riara-field__toggle" type="button" data-riara-password-toggle="#password" aria-label="{translate key="plugins.themes.riarauniversity.auth.showPassword"}" aria-pressed="false">
									<span class="fa fa-eye" aria-hidden="true"></span>
								</button>
							</div>
						</div>

						<div class="riara-field riara-field--checkbox remember checkbox">
							<label class="riara-field__checkbox">
								<input type="checkbox" name="remember" id="remember" value="1" checked="$remember">
								<span class="riara-field__checkbox-box" aria-hidden="true"></span>
								<span class="riara-field__checkbox-label">{translate key="user.login.rememberUsernameAndPassword"}</span>
							</label>
						</div>

						{if $recaptchaPublicKey}
							<fieldset class="recaptcha_wrapper">
								<div class="fields">
									<div class="recaptcha">
										<div class="g-recaptcha" data-sitekey="{$recaptchaPublicKey|escape}"></div>
										<label for="g-recaptcha-response" style="display:none;" hidden>Recaptcha response</label>
									</div>
								</div>
							</fieldset>
						{/if}

						{if $altchaEnabled}
							<fieldset class="altcha_wrapper">
								<div class="fields">
									<altcha-widget challengejson='{$altchaChallenge|@json_encode}' floating></altcha-widget>
								</div>
							</fieldset>
						{/if}

						<div class="riara-form__actions riara-form__actions--stacked">
							<button class="submit riara-btn riara-btn--primary riara-btn--block" type="submit">
								{translate key="user.login"}
								<span class="fa fa-arrow-right" aria-hidden="true"></span>
							</button>

							{if !$disableUserReg}
								{capture assign=registerUrl}{url page="user" op="register" source=$source}{/capture}
								<p class="riara-auth__register">
									{translate key="plugins.themes.riarauniversity.auth.noAccount"}
									<a href="{$registerUrl}" class="register">{translate key="user.login.registerNewAccount"}</a>
								</p>
							{/if}
						</div>
					</fieldset>
				</form>

				{include file="frontend/components/auth_trust.tpl"}
				<p class="riara-auth__required">{translate key="common.requiredField"}</p>
			</div>
		</div>
	</div>
</div>

{include file="frontend/components/footer.tpl"}
