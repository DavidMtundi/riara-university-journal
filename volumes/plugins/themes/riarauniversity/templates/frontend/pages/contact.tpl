{**
 * Riara University — contact page.
 *}
{include file="frontend/components/header.tpl" pageTitle="about.contact"}

<div class="page page_contact riara-page riara-page--about riara-page--contact riara-inner">
	{include file="frontend/components/breadcrumbs.tpl" currentTitleKey="about.contact"}

	<div class="riara-about-layout">
		{include file="frontend/components/about_nav.tpl"}

		<div class="riara-about-layout__main">
			<header class="riara-page__header">
				<p class="riara-kicker">{translate key="navigation.contact"}</p>
				<h1>{translate key="about.contact"}</h1>
				{include file="frontend/components/editLink.tpl" page="management" op="settings" path="context" anchor="contact" sectionTitleKey="about.contact"}
			</header>

			<div class="riara-contact-grid">
				{if $mailingAddress}
					<section class="riara-page__panel riara-contact-card">
						<h2 class="riara-contact-card__title">
							<span class="fa fa-map-marker" aria-hidden="true"></span>
							{translate key="common.mailingAddress"}
						</h2>
						<div class="riara-prose address">
							{$mailingAddress|nl2br|strip_unsafe_html}
						</div>
					</section>
				{/if}

				{if $contactTitle || $contactName || $contactAffiliation || $contactPhone || $contactEmail}
					<section class="riara-page__panel riara-contact-card">
						<h2 class="riara-contact-card__title">
							<span class="fa fa-user" aria-hidden="true"></span>
							{translate key="about.contact"}
						</h2>
						<dl class="riara-contact-list">
							{if $contactName}
								<div class="riara-contact-list__item">
									<dt>{translate key="common.name"}</dt>
									<dd>
										{if $contactTitle}{$contactTitle|escape} {/if}{$contactName|escape}
										{if $contactAffiliation}<span class="affiliation">{$contactAffiliation|escape}</span>{/if}
									</dd>
								</div>
							{/if}
							{if $contactPhone}
								<div class="riara-contact-list__item">
									<dt>{translate key="about.contact.phone"}</dt>
									<dd><a href="tel:{$contactPhone|escape}">{$contactPhone|escape}</a></dd>
								</div>
							{/if}
							{if $contactEmail}
								<div class="riara-contact-list__item">
									<dt>{translate key="about.contact.email"}</dt>
									<dd><a href="mailto:{$contactEmail|escape}">{$contactEmail|escape}</a></dd>
								</div>
							{/if}
						</dl>
					</section>
				{/if}

				{if $supportName || $supportPhone || $supportEmail}
					<section class="riara-page__panel riara-contact-card">
						<h2 class="riara-contact-card__title">
							<span class="fa fa-life-ring" aria-hidden="true"></span>
							{translate key="about.contact.supportContact"}
						</h2>
						<dl class="riara-contact-list">
							{if $supportName}
								<div class="riara-contact-list__item">
									<dt>{translate key="common.name"}</dt>
									<dd>{$supportName|escape}</dd>
								</div>
							{/if}
							{if $supportPhone}
								<div class="riara-contact-list__item">
									<dt>{translate key="about.contact.phone"}</dt>
									<dd><a href="tel:{$supportPhone|escape}">{$supportPhone|escape}</a></dd>
								</div>
							{/if}
							{if $supportEmail}
								<div class="riara-contact-list__item">
									<dt>{translate key="about.contact.email"}</dt>
									<dd><a href="mailto:{$supportEmail|escape}">{$supportEmail|escape}</a></dd>
								</div>
							{/if}
						</dl>
					</section>
				{/if}
			</div>
		</div>
	</div>
</div>

{include file="frontend/components/footer.tpl"}
