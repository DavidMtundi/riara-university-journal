{**
 * Riara University — submissions information page.
 *}
{include file="frontend/components/header.tpl" pageTitle="about.submissions"}

<div class="page page_submissions riara-page riara-page--about riara-page--submissions riara-inner">
	{include file="frontend/components/breadcrumbs.tpl" currentTitleKey="about.submissions"}

	<div class="riara-about-layout">
		{include file="frontend/components/about_nav.tpl"}

		<div class="riara-about-layout__main">
			<header class="riara-page__header">
				<p class="riara-kicker">{translate key="navigation.submissions"}</p>
				<h1>{translate key="about.submissions"}</h1>
			</header>

			<div class="cmp_notification riara-page__panel riara-submissions-cta">
				{if $sections|@count == 0 || $currentContext->getData('disableSubmissions')}
					{translate key="author.submit.notAccepting"}
				{else}
					{if $isUserLoggedIn}
						<p class="riara-submissions-cta__title">{translate key="plugins.themes.riarauniversity.submissions.ctaTitle"}</p>
						<p class="riara-submissions-cta__text">{translate key="plugins.themes.riarauniversity.submissions.ctaText"}</p>
						<div class="riara-form__actions">
							<a class="riara-btn riara-btn--primary" href="{url page="submission"}">{translate key="about.onlineSubmissions.newSubmission"}</a>
							<a class="riara-btn riara-btn--ghost" href="{url page="submissions"}">{translate key="about.onlineSubmissions.viewSubmissions"}</a>
						</div>
					{else}
						{capture assign="login"}<a href="{url page="login"}">{translate key="about.onlineSubmissions.login"}</a>{/capture}
						{capture assign="register"}<a href="{url page="user" op="register"}">{translate key="about.onlineSubmissions.register"}</a>{/capture}
						{translate key="about.onlineSubmissions.registrationRequired" login=$login register=$register}
					{/if}
				{/if}
			</div>

			{if $currentContext->getLocalizedData('authorGuidelines')}
				<div class="author_guidelines riara-page__panel riara-prose" id="authorGuidelines">
					<h2>
						{translate key="about.authorGuidelines"}
						{include file="frontend/components/editLink.tpl" page="management" op="settings" path="workflow" anchor="submission/instructions" sectionTitleKey="about.authorGuidelines"}
					</h2>
					{$currentContext->getLocalizedData('authorGuidelines')}
				</div>
			{/if}

			{if $submissionChecklist}
				<div class="submission_checklist riara-page__panel riara-prose">
					<h2>
						{translate key="about.submissionPreparationChecklist"}
						{include file="frontend/components/editLink.tpl" page="management" op="settings" path="workflow" anchor="submission/instructions" sectionTitleKey="about.submissionPreparationChecklist"}
					</h2>
					{$submissionChecklist}
				</div>
			{/if}

			{foreach from=$sections item="section"}
				{if $section->getLocalizedPolicy()}
					<div class="section_policy riara-page__panel riara-prose">
						<h2>{$section->getLocalizedTitle()|escape}</h2>
						{$section->getLocalizedPolicy()}
						{if $isUserLoggedIn}
							{capture assign="sectionSubmissionUrl"}{url page="submission" sectionId=$section->getId()}{/capture}
							<p>
								{translate key="about.onlineSubmissions.submitToSection" name=$section->getLocalizedTitle()|escape url=$sectionSubmissionUrl}
							</p>
						{/if}
					</div>
				{/if}
			{/foreach}

			{if $currentContext->getLocalizedData('copyrightNotice')}
				<div class="copyright_notice riara-page__panel riara-prose">
					<h2>
						{translate key="about.copyrightNotice"}
						{include file="frontend/components/editLink.tpl" page="management" op="settings" path="workflow" anchor="submission/instructions" sectionTitleKey="about.copyrightNotice"}
					</h2>
					{$currentContext->getLocalizedData('copyrightNotice')}
				</div>
			{/if}

			{if $currentContext->getLocalizedData('privacyStatement')}
				<div class="privacy_statement riara-page__panel riara-prose" id="privacyStatement">
					<h2>
						{translate key="about.privacyStatement"}
						{include file="frontend/components/editLink.tpl" page="management" op="settings" path="website" anchor="setup/privacy" sectionTitleKey="about.privacyStatement"}
					</h2>
					{$currentContext->getLocalizedData('privacyStatement')}
				</div>
			{/if}
		</div>
	</div>
</div>

{include file="frontend/components/footer.tpl"}
