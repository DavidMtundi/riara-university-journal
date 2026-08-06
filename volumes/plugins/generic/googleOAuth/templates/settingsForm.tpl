{**
 * plugins/generic/googleOAuth/templates/settingsForm.tpl
 *}
<script>
	$(function() {ldelim}
		$('#googleOAuthSettingsForm').pkpHandler('$.pkp.controllers.form.AjaxFormHandler');
	{rdelim});
</script>

<form class="pkp_form" id="googleOAuthSettingsForm" method="post" action="{url router=PKP\core\PKPApplication::ROUTE_COMPONENT op="manage" category="generic" plugin=$pluginName verb="settings" save=true}">
	{csrf}
	{include file="controllers/notification/inPlaceNotification.tpl" notificationId="googleOAuthSettingsFormNotification"}

	<p>{translate key="plugins.generic.googleOAuth.settings.description"}</p>
	<p><strong>{translate key="plugins.generic.googleOAuth.settings.redirectUri"}</strong><br><code>{$redirectUri|escape}</code></p>

	{fbvFormArea id="googleOAuthSettingsArea"}
		{fbvElement type="text" id="clientId" value=$clientId required=true label="plugins.generic.googleOAuth.settings.clientId"}
		{fbvElement type="text" id="clientSecret" value=$clientSecret required=true label="plugins.generic.googleOAuth.settings.clientSecret"}
		{fbvElement type="select" id="studentUserGroupId" from=$studentUserGroupOptions|default:[] selected=$studentUserGroupId label="plugins.generic.googleOAuth.settings.studentUserGroup"}
		{fbvElement type="select" id="staffUserGroupId" from=$staffUserGroupOptions|default:[] selected=$staffUserGroupId label="plugins.generic.googleOAuth.settings.staffUserGroup"}
		{fbvElement type="checkbox" id="restrictSubmissionsToUniversity" value=1 checked=$restrictSubmissionsToUniversity label="plugins.generic.googleOAuth.settings.restrictSubmissions"}
	{/fbvFormArea}

	{fbvFormButtons}
</form>
