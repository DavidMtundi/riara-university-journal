{**
 * Riara University — registration page.
 *}
{include file="frontend/components/header.tpl" pageTitle="user.register"}

{assign var="siteContextId" value=PKP\core\PKPApplication::SITE_CONTEXT_ID|intval}

<div class="page page_register riara-page riara-page--auth riara-page--auth-register">
	<div class="riara-auth riara-auth--immersive">
		{include file="frontend/components/auth_scene.tpl" authSceneVariant="register"}

		<div class="riara-auth__main">
			<div class="riara-auth__form-card riara-auth__form-card--wide">
				<header class="riara-auth__form-header">
					{if $currentContext}
						<p class="riara-auth__journal">{$currentContext->getLocalizedName()|escape}</p>
					{/if}
					<h1>{translate key="user.register"}</h1>
					<p class="riara-auth__subtitle">{translate key="plugins.themes.riarauniversity.auth.registerSubtitle"}</p>
				</header>

				{if $googleOAuthEnabled}
					<div class="riara-auth__oauth">
						<a class="riara-btn riara-btn--google" href="{$googleOAuthAuthorizeUrl|escape}">
							<span class="riara-btn__google-icon" aria-hidden="true">G</span>
							{translate key="plugins.generic.googleOAuth.signInWithGoogle"}
						</a>
						<p class="riara-auth__oauth-divider"><span>{translate key="plugins.generic.googleOAuth.orContinueWith"}</span></p>
					</div>
				{/if}

				<form class="cmp_form register riara-form riara-form--auth riara-form--register" id="register" method="post" action="{url op="register"}" role="form">
					{if $orcidEnabled}
						{include file="form/orcidProfile.tpl"}
					{/if}

					{csrf}

					{if $source}
						<input type="hidden" name="source" value="{$source|escape}" />
					{/if}

					{include file="common/formErrors.tpl"}
					{include file="frontend/components/registrationForm.tpl"}

					{if $currentContext}
						<fieldset class="consent riara-auth__section">
							<legend class="riara-auth__section-title">
								<span class="riara-auth__section-badge" aria-hidden="true">3</span>
								{translate key="plugins.themes.riarauniversity.auth.registerPreferences"}
							</legend>
							<div class="fields riara-auth__section-fields">
								{if $currentContext->getData('privacyStatement')}
									<div class="riara-field riara-field--checkbox optin optin-privacy">
										<label class="riara-field__checkbox">
											<input type="checkbox" name="privacyConsent" value="1"{if $privacyConsent} checked="checked"{/if}>
											<span class="riara-field__checkbox-box" aria-hidden="true"></span>
											<span class="riara-field__checkbox-label">
												{capture assign="privacyUrl"}{url router=PKP\core\PKPApplication::ROUTE_PAGE page="about" op="privacy"}{/capture}
												{translate key="user.register.form.privacyConsent" privacyUrl=$privacyUrl}
											</span>
										</label>
									</div>
								{/if}
								<div class="riara-field riara-field--checkbox optin optin-email">
									<label class="riara-field__checkbox">
										<input type="checkbox" name="emailConsent" value="1"{if $emailConsent} checked="checked"{/if}>
										<span class="riara-field__checkbox-box" aria-hidden="true"></span>
										<span class="riara-field__checkbox-label">{translate key="user.register.form.emailConsent"}</span>
									</label>
								</div>
							</div>
						</fieldset>

						{assign var=contextId value=$currentContext->getId()}
						{assign var=userCanRegisterReviewer value=0}
						{foreach from=$reviewerUserGroups[$contextId] item=userGroup}
							{if $userGroup->permitSelfRegistration}
								{assign var=userCanRegisterReviewer value=$userCanRegisterReviewer+1}
							{/if}
						{/foreach}
						{if $userCanRegisterReviewer}
							<fieldset class="reviewer riara-auth__section">
								{if $userCanRegisterReviewer > 1}
									<legend class="riara-auth__section-title">{translate key="user.reviewerPrompt"}</legend>
									{capture assign="checkboxLocaleKey"}user.reviewerPrompt.userGroup{/capture}
								{else}
									<legend class="riara-auth__section-title">{translate key="user.reviewerPrompt"}</legend>
									{capture assign="checkboxLocaleKey"}user.reviewerPrompt.optin{/capture}
								{/if}
								<div class="fields riara-auth__section-fields">
									<div id="reviewerOptinGroup" class="optin">
										{foreach from=$reviewerUserGroups[$contextId] item=userGroup}
											{if $userGroup->permitSelfRegistration}
												<div class="riara-field riara-field--checkbox">
													<label class="riara-field__checkbox">
														{assign var="userGroupId" value=$userGroup->id}
														<input type="checkbox" name="reviewerGroup[{$userGroupId}]" value="1"{if in_array($userGroupId, $userGroupIds)} checked="checked"{/if}>
														<span class="riara-field__checkbox-box" aria-hidden="true"></span>
														<span class="riara-field__checkbox-label">{translate key=$checkboxLocaleKey userGroup=$userGroup->getLocalizedData('name')}</span>
													</label>
												</div>
											{/if}
										{/foreach}
									</div>
									<div id="reviewerInterests" class="reviewer_interests riara-field">
										<label class="riara-field__label" for="interests">{translate key="user.interests"}</label>
										<div class="riara-field__control">
											<span class="riara-field__icon fa fa-tags" aria-hidden="true"></span>
											<input class="riara-field__input" type="text" name="interests" id="interests" value="{$interests|default:""|escape}">
										</div>
									</div>
								</div>
							</fieldset>
						{/if}
					{/if}

					{include file="frontend/components/registrationFormContexts.tpl"}

					{if !$currentContext}
						<div class="fields riara-auth__section-fields">
							<div class="reviewer_nocontext_interests riara-field">
								<label class="riara-field__label" for="interests">{translate key="user.register.noContextReviewerInterests"}</label>
								<div class="riara-field__control">
									<span class="riara-field__icon fa fa-tags" aria-hidden="true"></span>
									<input class="riara-field__input" type="text" name="interests" id="interests" value="{$interests|default:""|escape}">
								</div>
							</div>
						</div>

						{if $siteWidePrivacyStatement}
							<div class="riara-field riara-field--checkbox optin optin-privacy">
								<label class="riara-field__checkbox">
									<input type="checkbox" name="privacyConsent[{$siteContextId}]" id="privacyConsent[{$siteContextId}]" value="1"{if $privacyConsent[$siteContextId]} checked="checked"{/if}>
									<span class="riara-field__checkbox-box" aria-hidden="true"></span>
									<span class="riara-field__checkbox-label">
										{capture assign="privacyUrl"}{url router=PKP\core\PKPApplication::ROUTE_PAGE page="about" op="privacy"}{/capture}
										{translate key="user.register.form.privacyConsent" privacyUrl=$privacyUrl}
									</span>
								</label>
							</div>
						{/if}

						<div class="riara-field riara-field--checkbox optin optin-email">
							<label class="riara-field__checkbox">
								<input type="checkbox" name="emailConsent" value="1"{if $emailConsent} checked="checked"{/if}>
								<span class="riara-field__checkbox-box" aria-hidden="true"></span>
								<span class="riara-field__checkbox-label">{translate key="user.register.form.emailConsent"}</span>
							</label>
						</div>
					{/if}

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
							{translate key="user.register"}
							<span class="fa fa-arrow-right" aria-hidden="true"></span>
						</button>

						{capture assign="rolesProfileUrl"}{url page="user" op="profile" path="roles"}{/capture}
						<p class="riara-auth__register">
							{translate key="plugins.themes.riarauniversity.auth.hasAccount"}
							<a href="{url page="login" source=$rolesProfileUrl}" class="login">{translate key="user.login"}</a>
						</p>
					</div>
				</form>

				{include file="frontend/components/auth_trust.tpl"}
				<p class="riara-auth__required">{translate key="common.requiredField"}</p>
			</div>
		</div>
	</div>
</div>

{include file="frontend/components/footer.tpl"}
