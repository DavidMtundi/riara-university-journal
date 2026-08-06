{**
 * Riara University — lost password page.
 *}
{include file="frontend/components/header.tpl" pageTitle="user.login.resetPassword"}

<div class="page page_lost_password riara-page riara-page--auth riara-page--auth-reset">
	<div class="riara-auth riara-auth--immersive">
		{include file="frontend/components/auth_scene.tpl" authSceneVariant="reset"}

		<div class="riara-auth__main">
			<div class="riara-auth__form-card">
				<header class="riara-auth__form-header">
					{if $currentContext}
						<p class="riara-auth__journal">{$currentContext->getLocalizedName()|escape}</p>
					{/if}
					<h1>{translate key="user.login.resetPassword"}</h1>
					<p class="riara-auth__subtitle">{translate key="user.login.resetPasswordInstructions"}</p>
				</header>

				<div class="riara-auth__help" role="note">
					<span class="riara-auth__help-icon fa fa-info-circle" aria-hidden="true"></span>
					<p>{translate key="plugins.themes.riarauniversity.auth.resetHelp"}</p>
				</div>

				<form class="cmp_form lost_password riara-form riara-form--auth" id="lostPasswordForm" action="{url page="login" op="requestResetPassword"}" method="post" role="form">
					{csrf}
					{if $error}
						<div class="pkp_form_error riara-auth__error">
							{translate key=$error reason=$reason}
						</div>
					{/if}

					<div class="fields">
						<div class="riara-field email">
							<label class="riara-field__label" for="email">
								{translate key="user.login.registeredEmail"}
								<span class="required" aria-hidden="true">*</span>
								<span class="pkp_screen_reader">{translate key="common.required"}</span>
							</label>
							<div class="riara-field__control">
								<span class="riara-field__icon fa fa-envelope-o" aria-hidden="true"></span>
								<input class="riara-field__input" type="email" name="email" id="email" value="{$email|escape}" required aria-required="true" autocomplete="email">
							</div>
						</div>

						{if $altchaEnabled}
							<fieldset class="altcha_wrapper">
								<div class="fields">
									<altcha-widget challengejson='{$altchaChallenge|@json_encode}' floating></altcha-widget>
								</div>
							</fieldset>
						{/if}

						<div class="riara-form__actions riara-form__actions--stacked">
							<button class="submit riara-btn riara-btn--primary riara-btn--block" type="submit">
								{translate key="plugins.themes.riarauniversity.auth.sendResetLink"}
								<span class="fa fa-paper-plane" aria-hidden="true"></span>
							</button>

							<div class="riara-auth__links">
								<a href="{url page="login"}" class="riara-auth__back-link">
									<span class="fa fa-arrow-left" aria-hidden="true"></span>
									{translate key="user.login"}
								</a>

								{if !$disableUserReg}
									{capture assign=registerUrl}{url page="user" op="register" source=$source}{/capture}
									<a href="{$registerUrl}" class="register">
										{translate key="user.login.registerNewAccount"}
									</a>
								{/if}
							</div>
						</div>
					</div>
				</form>

				{include file="frontend/components/auth_trust.tpl"}
			</div>
		</div>
	</div>
</div>

{include file="frontend/components/footer.tpl"}
