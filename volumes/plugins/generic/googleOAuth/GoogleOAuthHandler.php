<?php

/**
 * @file plugins/generic/googleOAuth/GoogleOAuthHandler.php
 */

namespace APP\plugins\generic\googleOAuth;

use APP\facades\Repo;
use APP\handler\Handler;
use APP\plugins\generic\googleOAuth\classes\GoogleOAuthService;
use Exception;
use PKP\core\PKPRequest;
use PKP\security\Role;

class GoogleOAuthHandler extends Handler
{
    public function __construct(private GoogleOAuthPlugin $plugin)
    {
        parent::__construct();
    }

    /**
     * Start Google OAuth (named "connect" to avoid clashing with PKPHandler::authorize()).
     *
     * @param array $args
     * @param PKPRequest $request
     */
    public function connect($args, $request)
    {
        $context = $request->getContext();
        if (!$context || !$this->plugin->isConfigured($context->getId())) {
            $request->redirect(null, 'login');
            return;
        }

        $state = bin2hex(random_bytes(16));
        $source = (string) $request->getUserVar('source');
        $session = $request->getSession();
        $session->put('googleoauth_state', $state);
        $session->put('googleoauth_context_id', $context->getId());
        $session->put('googleoauth_source', $source);

        $service = new GoogleOAuthService($this->plugin);
        $request->redirectUrl($service->getAuthorizationUrl($context->getId(), $state));
    }

    /**
     * @param array $args
     * @param PKPRequest $request
     */
    public function callback($args, $request)
    {
        $context = $request->getContext();
        $session = $request->getSession();
        $expectedState = (string) $session->get('googleoauth_state');
        $contextId = (int) $session->get('googleoauth_context_id');
        $source = (string) $session->get('googleoauth_source');

        $session->remove('googleoauth_state');
        $session->remove('googleoauth_context_id');
        $session->remove('googleoauth_source');

        $error = $request->getUserVar('error');
        if ($error) {
            $this->redirectLoginWithError($request, $context, 'plugins.generic.googleOAuth.error.denied');
            return;
        }

        $state = (string) $request->getUserVar('state');
        if (!$expectedState || !hash_equals($expectedState, $state)) {
            $this->redirectLoginWithError($request, $context, 'plugins.generic.googleOAuth.error.invalidState');
            return;
        }

        if (!$context || (int) $context->getId() !== $contextId || !$this->plugin->isConfigured($contextId)) {
            $this->redirectLoginWithError($request, $context, 'plugins.generic.googleOAuth.error.misconfigured');
            return;
        }

        $code = (string) $request->getUserVar('code');
        if ($code === '') {
            $this->redirectLoginWithError($request, $context, 'plugins.generic.googleOAuth.error.missingCode');
            return;
        }

        try {
            $service = new GoogleOAuthService($this->plugin);
            $result = $service->authenticateCallback($contextId, $code);
            $service->loginUser($result['user']);
        } catch (Exception $e) {
            $message = $e->getMessage();
            $this->redirectLoginWithError(
                $request,
                $context,
                str_starts_with($message, 'plugins.') ? $message : 'plugins.generic.googleOAuth.error.loginFailed',
                $message
            );
            return;
        }

        if ($source !== '') {
            $request->redirectUrl($source);
            return;
        }

        $user = $request->getUser();
        $roles = Repo::userGroup()->userUserGroups((int) $user->getId(), $contextId)
            ->map(fn ($group) => $group->roleId)
            ->unique()
            ->all();

        if (array_intersect(
            [Role::ROLE_ID_SITE_ADMIN, Role::ROLE_ID_MANAGER, Role::ROLE_ID_SUB_EDITOR, Role::ROLE_ID_AUTHOR, Role::ROLE_ID_REVIEWER, Role::ROLE_ID_ASSISTANT],
            $roles
        )) {
            $request->redirect($context->getPath(), 'dashboard');
            return;
        }

        $request->getRouter()->redirectHome($request);
    }

    /**
     * @param array $args
     * @param PKPRequest $request
     */
    public function index($args, $request)
    {
        $request->redirect(null, 'googleoauth', 'connect', $args);
    }

    private function redirectLoginWithError(PKPRequest $request, $context, string $messageKey, ?string $reason = null): void
    {
        $params = ['loginMessage' => $messageKey];
        if ($reason) {
            $params['reason'] = $reason;
        }

        if ($context) {
            $request->redirect($context->getPath(), 'login', null, null, $params);
            return;
        }

        $request->redirect(null, 'login', null, null, $params);
    }
}
