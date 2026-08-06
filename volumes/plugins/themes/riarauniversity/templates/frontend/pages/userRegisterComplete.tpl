{**
 * Riara University — registration complete page.
 *}
{include file="frontend/components/header.tpl" pageTitle=$pageTitle}

<div class="page page_register_complete riara-page riara-page--auth riara-page--auth-complete">
	<div class="riara-auth riara-auth--immersive">
		{include file="frontend/components/auth_scene.tpl" authSceneVariant="complete"}

		<div class="riara-auth__main">
			<div class="riara-auth__form-card">
				<header class="riara-auth__form-header">
					{if $currentContext}
						<p class="riara-auth__journal">{$currentContext->getLocalizedName()|escape}</p>
					{/if}
					<h1>{translate key=$pageTitle}</h1>
					<p class="riara-auth__subtitle">{translate key="user.login.registrationComplete.instructions"}</p>
				</header>

				<ul class="registration_complete_actions riara-auth__success-actions">
					{if array_intersect(array(PKP\security\Role::ROLE_ID_MANAGER, PKP\security\Role::ROLE_ID_SUB_EDITOR, PKP\security\Role::ROLE_ID_ASSISTANT, PKP\security\Role::ROLE_ID_REVIEWER), (array)$userRoles)}
						<li class="view_submissions">
							<a class="riara-btn riara-btn--primary riara-btn--block" href="{url page="submissions"}">
								{translate key="user.login.registrationComplete.manageSubmissions"}
								<span class="fa fa-arrow-right" aria-hidden="true"></span>
							</a>
						</li>
					{/if}
					{if $currentContext}
						<li class="new_submission">
							<a class="riara-btn riara-btn--primary riara-btn--block" href="{url page="submission"}">
								{translate key="user.login.registrationComplete.newSubmission"}
								<span class="fa fa-arrow-right" aria-hidden="true"></span>
							</a>
						</li>
					{/if}
					<li class="edit_profile">
						<a class="riara-btn riara-btn--outline riara-btn--block" href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="user" op="profile"}">
							{translate key="user.editMyProfile"}
						</a>
					</li>
					<li class="browse">
						<a class="riara-btn riara-btn--ghost riara-btn--block" href="{url page="index"}">
							{translate key="user.login.registrationComplete.continueBrowsing"}
						</a>
					</li>
				</ul>

				{include file="frontend/components/auth_trust.tpl"}
			</div>
		</div>
	</div>
</div>

{include file="frontend/components/footer.tpl"}
