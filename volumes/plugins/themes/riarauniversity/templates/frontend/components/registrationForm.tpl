{**
 * Riara University — registration form fields with auth field styling.
 *}
<fieldset class="identity riara-auth__section">
	<legend class="riara-auth__section-title">
		<span class="riara-auth__section-badge" aria-hidden="true">1</span>
		{translate key="user.profile"}
	</legend>
	<div class="fields riara-auth__section-fields">
		<div class="riara-field given_name">
			<label class="riara-field__label" for="givenName">
				{translate key="user.givenName"}
				<span class="required" aria-hidden="true">*</span>
				<span class="pkp_screen_reader">{translate key="common.required"}</span>
			</label>
			<div class="riara-field__control">
				<span class="riara-field__icon fa fa-user" aria-hidden="true"></span>
				<input class="riara-field__input" type="text" name="givenName" autocomplete="given-name" id="givenName" value="{$givenName|default:""|escape}" maxlength="255" required aria-required="true">
			</div>
		</div>
		<div class="riara-field family_name">
			<label class="riara-field__label" for="familyName">
				{translate key="user.familyName"}
			</label>
			<div class="riara-field__control">
				<span class="riara-field__icon fa fa-user-o" aria-hidden="true"></span>
				<input class="riara-field__input" type="text" name="familyName" autocomplete="family-name" id="familyName" value="{$familyName|default:""|escape}" maxlength="255">
			</div>
		</div>
		<div class="riara-field affiliation">
			<label class="riara-field__label" for="affiliation">
				{translate key="user.affiliation"}
				<span class="required" aria-hidden="true">*</span>
				<span class="pkp_screen_reader">{translate key="common.required"}</span>
			</label>
			<div class="riara-field__control">
				<span class="riara-field__icon fa fa-building-o" aria-hidden="true"></span>
				<input class="riara-field__input" type="text" name="affiliation" autocomplete="organization" id="affiliation" value="{$affiliation|default:""|escape}" required aria-required="true">
			</div>
		</div>
		<div class="riara-field country">
			<label class="riara-field__label" for="country">
				{translate key="common.country"}
				<span class="required" aria-hidden="true">*</span>
				<span class="pkp_screen_reader">{translate key="common.required"}</span>
			</label>
			<div class="riara-field__control riara-field__control--select">
				<span class="riara-field__icon fa fa-globe" aria-hidden="true"></span>
				<select class="riara-field__input riara-field__select" name="country" id="country" autocomplete="country-name" required aria-required="true">
					<option></option>
					{html_options options=$countries selected=$country}
				</select>
			</div>
		</div>
	</div>
</fieldset>

<fieldset class="login riara-auth__section">
	<legend class="riara-auth__section-title">
		<span class="riara-auth__section-badge" aria-hidden="true">2</span>
		{translate key="user.login"}
	</legend>
	<p class="riara-auth__section-hint">{translate key="plugins.themes.riarauniversity.auth.passwordHint"}</p>
	<div class="fields riara-auth__section-fields">
		<div class="riara-field email">
			<label class="riara-field__label" for="email">
				{translate key="user.email"}
				<span class="required" aria-hidden="true">*</span>
				<span class="pkp_screen_reader">{translate key="common.required"}</span>
			</label>
			<div class="riara-field__control">
				<span class="riara-field__icon fa fa-envelope-o" aria-hidden="true"></span>
				<input class="riara-field__input" type="email" name="email" id="email" value="{$email|default:""|escape}" maxlength="90" required aria-required="true" autocomplete="email">
			</div>
		</div>
		<div class="riara-field username">
			<label class="riara-field__label" for="username">
				{translate key="user.username"}
				<span class="required" aria-hidden="true">*</span>
				<span class="pkp_screen_reader">{translate key="common.required"}</span>
			</label>
			<div class="riara-field__control">
				<span class="riara-field__icon fa fa-at" aria-hidden="true"></span>
				<input class="riara-field__input" type="text" name="username" id="username" value="{$username|default:""|escape}" maxlength="32" required aria-required="true" autocomplete="username">
			</div>
		</div>
		<div class="riara-field password">
			<label class="riara-field__label" for="password">
				{translate key="user.password"}
				<span class="required" aria-hidden="true">*</span>
				<span class="pkp_screen_reader">{translate key="common.required"}</span>
			</label>
			<div class="riara-field__control">
				<span class="riara-field__icon fa fa-lock" aria-hidden="true"></span>
				<input class="riara-field__input" type="password" name="password" id="password" password="true" maxlength="32" required aria-required="true" autocomplete="new-password">
				<button class="riara-field__toggle" type="button" data-riara-password-toggle="#password" aria-label="{translate key="plugins.themes.riarauniversity.auth.showPassword"}" aria-pressed="false">
					<span class="fa fa-eye" aria-hidden="true"></span>
				</button>
			</div>
		</div>
		<div class="riara-field password">
			<label class="riara-field__label" for="password2">
				{translate key="user.repeatPassword"}
				<span class="required" aria-hidden="true">*</span>
				<span class="pkp_screen_reader">{translate key="common.required"}</span>
			</label>
			<div class="riara-field__control">
				<span class="riara-field__icon fa fa-lock" aria-hidden="true"></span>
				<input class="riara-field__input" type="password" name="password2" id="password2" password="true" maxlength="32" required aria-required="true" autocomplete="new-password">
				<button class="riara-field__toggle" type="button" data-riara-password-toggle="#password2" aria-label="{translate key="plugins.themes.riarauniversity.auth.showPassword"}" aria-pressed="false">
					<span class="fa fa-eye" aria-hidden="true"></span>
				</button>
			</div>
		</div>
	</div>
</fieldset>
