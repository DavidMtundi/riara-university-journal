<?php

/**
 * @file plugins/generic/googleOAuth/GoogleOAuthPlugin.php
 */

namespace APP\plugins\generic\googleOAuth;

use APP\core\Application;
use APP\plugins\generic\googleOAuth\classes\DomainRoleResolver;
use APP\plugins\generic\googleOAuth\classes\GoogleOAuthService;
use APP\template\TemplateManager;
use PKP\core\JSONMessage;
use PKP\core\PKPApplication;
use PKP\linkAction\LinkAction;
use PKP\linkAction\request\AjaxModal;
use PKP\plugins\GenericPlugin;
use PKP\plugins\Hook;

class GoogleOAuthPlugin extends GenericPlugin
{
    public function getDisplayName()
    {
        return __('plugins.generic.googleOAuth.displayName');
    }

    public function getDescription()
    {
        return __('plugins.generic.googleOAuth.description');
    }

    public function register($category, $path, $mainContextId = null)
    {
        if (!parent::register($category, $path, $mainContextId)) {
            return false;
        }

        if (Application::isUnderMaintenance()) {
            return true;
        }

        if ($this->getEnabled($mainContextId)) {
            Hook::add('LoadHandler', $this->handleLoadHandler(...));
            Hook::add('TemplateManager::display', $this->assignAuthTemplateVars(...));
            Hook::add('LoadHandler', $this->enforceSubmissionAccess(...), Hook::SEQUENCE_LATE);
        }

        return true;
    }

    public function getActions($request, $verb)
    {
        $router = $request->getRouter();
        return array_merge(
            $this->getEnabled() ? [
                new LinkAction(
                    'settings',
                    new AjaxModal(
                        $router->url($request, null, null, 'manage', null, ['verb' => 'settings', 'plugin' => $this->getName(), 'category' => 'generic']),
                        $this->getDisplayName()
                    ),
                    __('manager.plugins.settings'),
                    null
                ),
            ] : [],
            parent::getActions($request, $verb)
        );
    }

    public function manage($args, $request)
    {
        switch ($request->getUserVar('verb')) {
            case 'settings':
                $context = $request->getContext();
                if (!$context) {
                    return new JSONMessage(false);
                }

                $templateMgr = TemplateManager::getManager($request);
                $templateMgr->registerPlugin('function', 'plugin_url', $this->smartyPluginUrl(...));

                $form = new GoogleOAuthSettingsForm($this, $context->getId());
                if ($request->getUserVar('save')) {
                    $form->readInputData();
                    if ($form->validate()) {
                        $form->execute();
                        return new JSONMessage(true);
                    }
                } else {
                    $form->initData();
                }

                return new JSONMessage(true, $form->fetch($request));
        }

        return parent::manage($args, $request);
    }

    public function isConfigured(int $contextId): bool
    {
        return $this->getEnabled($contextId)
            && (string) $this->getSetting($contextId, 'clientId') !== ''
            && (string) $this->getSetting($contextId, 'clientSecret') !== '';
    }

    public function handleLoadHandler(string $hookName, array $args): bool
    {
        $page = &$args[0];
        $handler = &$args[3];

        if ($page !== 'googleoauth') {
            return Hook::CONTINUE;
        }

        $handler = new GoogleOAuthHandler($this);
        return Hook::ABORT;
    }

    public function assignAuthTemplateVars(string $hookName, array $args): bool
    {
        $templateMgr = $args[0];
        $template = $args[1];
        if (!is_string($template) || !preg_match('/userLogin\.tpl$|userRegister\.tpl$/', $template)) {
            return Hook::CONTINUE;
        }

        $request = Application::get()->getRequest();
        $context = $request->getContext();
        if (!$context || !$this->isConfigured($context->getId())) {
            return Hook::CONTINUE;
        }

        $service = new GoogleOAuthService($this);
        $source = $request->getUserVar('source');
        $authorizeUrl = $request->getDispatcher()->url(
            $request,
            PKPApplication::ROUTE_PAGE,
            $context->getPath(),
            'googleoauth',
            'connect',
            null,
            $source ? ['source' => $source] : []
        );

        $templateMgr->assign([
            'googleOAuthEnabled' => true,
            'googleOAuthAuthorizeUrl' => $authorizeUrl,
            'googleOAuthRedirectUri' => $service->getRedirectUri($context->getId()),
        ]);

        return Hook::CONTINUE;
    }

    public function enforceSubmissionAccess(string $hookName, array $args): bool
    {
        $page = $args[0] ?? '';
        if ($page !== 'submission') {
            return Hook::CONTINUE;
        }

        $request = Application::get()->getRequest();
        $context = $request->getContext();
        if (!$context || !$this->getSetting($context->getId(), 'restrictSubmissionsToUniversity')) {
            return Hook::CONTINUE;
        }

        $user = $request->getUser();
        if (!$user || DomainRoleResolver::isUniversityAffiliated($user->getEmail())) {
            return Hook::CONTINUE;
        }

        $request->redirect($context->getPath(), 'login', 'index', null, [
            'loginMessage' => 'plugins.generic.googleOAuth.error.submissionRestricted',
        ]);

        return Hook::ABORT;
    }
}
