<?php

/**
 * @file plugins/generic/googleOAuth/classes/GoogleOAuthService.php
 *
 * @brief Google OAuth token exchange, user provisioning, and group assignment.
 */

namespace APP\plugins\generic\googleOAuth\classes;

use APP\core\Application;
use APP\facades\Repo;
use APP\plugins\generic\googleOAuth\GoogleOAuthPlugin;
use Exception;
use Illuminate\Support\Facades\Http;
use PKP\core\Core;
use PKP\core\PKPApplication;
use PKP\facades\Locale;
use PKP\security\Role;
use PKP\security\Validation;
use PKP\user\User;

class GoogleOAuthService
{
    private const AUTH_URL = 'https://accounts.google.com/o/oauth2/v2/auth';
    private const TOKEN_URL = 'https://oauth2.googleapis.com/token';
    private const USERINFO_URL = 'https://www.googleapis.com/oauth2/v3/userinfo';

    public function __construct(private GoogleOAuthPlugin $plugin)
    {
    }

    public function getAuthorizationUrl(int $contextId, string $state): string
    {
        $redirectUri = $this->getRedirectUri($contextId);
        $params = [
            'client_id' => $this->plugin->getSetting($contextId, 'clientId'),
            'redirect_uri' => $redirectUri,
            'response_type' => 'code',
            'scope' => 'openid email profile',
            'state' => $state,
            'prompt' => 'select_account',
            'access_type' => 'online',
        ];

        return self::AUTH_URL . '?' . http_build_query($params);
    }

    public function getRedirectUri(int $contextId): string
    {
        $request = Application::get()->getRequest();
        $context = $request->getContext();
        if (!$context || (int) $context->getId() !== $contextId) {
            $context = app('context')->get($contextId);
        }

        return $request->getDispatcher()->url(
            $request,
            PKPApplication::ROUTE_PAGE,
            $context?->getPath(),
            'googleoauth',
            'callback'
        );
    }

    /**
     * @return array{user: User, created: bool}
     */
    public function authenticateCallback(int $contextId, string $code): array
    {
        $token = $this->exchangeCode($contextId, $code);
        $profile = $this->fetchUserInfo($token['access_token'] ?? '');

        if (empty($profile['email_verified'])) {
            throw new Exception(__('plugins.generic.googleOAuth.error.emailNotVerified'));
        }

        $email = DomainRoleResolver::normalizeEmail((string) ($profile['email'] ?? ''));
        if ($email === '') {
            throw new Exception(__('plugins.generic.googleOAuth.error.missingEmail'));
        }

        $existing = Repo::user()->getByEmail($email, true);
        if ($existing) {
            $this->assignDomainGroups($existing, $contextId, $email);
            return ['user' => $existing, 'created' => false];
        }

        $user = $this->createUserFromProfile($profile, $email);
        $this->assignDomainGroups($user, $contextId, $email);

        return ['user' => $user, 'created' => true];
    }

    public function loginUser(User $user): bool
    {
        $reason = null;
        $loggedIn = Validation::registerUserSession($user, $reason);
        if ($loggedIn === false) {
            throw new Exception($reason ?: __('plugins.generic.googleOAuth.error.loginFailed'));
        }

        return true;
    }

    private function exchangeCode(int $contextId, string $code): array
    {
        $response = Http::asForm()->post(self::TOKEN_URL, [
            'code' => $code,
            'client_id' => $this->plugin->getSetting($contextId, 'clientId'),
            'client_secret' => $this->plugin->getSetting($contextId, 'clientSecret'),
            'redirect_uri' => $this->getRedirectUri($contextId),
            'grant_type' => 'authorization_code',
        ]);

        if (!$response->successful()) {
            throw new Exception(__('plugins.generic.googleOAuth.error.tokenExchange'));
        }

        $body = $response->json();
        if (!is_array($body) || empty($body['access_token'])) {
            throw new Exception(__('plugins.generic.googleOAuth.error.tokenExchange'));
        }

        return $body;
    }

    private function fetchUserInfo(string $accessToken): array
    {
        $response = Http::withToken($accessToken)->get(self::USERINFO_URL);
        if (!$response->successful()) {
            throw new Exception(__('plugins.generic.googleOAuth.error.userinfo'));
        }

        $body = $response->json();
        return is_array($body) ? $body : [];
    }

    private function createUserFromProfile(array $profile, string $email): User
    {
        $user = Repo::user()->newDataObject();
        $username = $this->generateUsername($email);
        $locale = Locale::getLocale() ?: 'en';
        $givenName = (string) ($profile['given_name'] ?? '');
        $familyName = (string) ($profile['family_name'] ?? '');

        if ($givenName === '' && $familyName === '') {
            $localPart = strstr($email, '@', true) ?: 'user';
            $givenName = ucfirst(str_replace(['.', '_', '-'], ' ', $localPart));
        }

        $user->setUsername($username);
        $user->setEmail($email);
        $user->setGivenName($givenName, $locale);
        $user->setFamilyName($familyName, $locale);
        $user->setDateRegistered(Core::getCurrentDate());
        $user->setInlineHelp(1);
        $user->setPassword(Validation::encryptCredentials($username, bin2hex(random_bytes(16))));

        Repo::user()->add($user);

        return Repo::user()->get($user->getId());
    }

    private function generateUsername(string $email): string
    {
        $base = preg_replace('/[^a-z0-9]/', '', strtolower(strstr($email, '@', true) ?: 'user'));
        if ($base === '') {
            $base = 'user';
        }

        $username = substr($base, 0, 32);
        $suffix = 0;
        while (Repo::user()->getByUsername($username, true)) {
            $suffix++;
            $username = substr($base, 0, max(1, 32 - strlen((string) $suffix))) . $suffix;
        }

        return $username;
    }

    private function assignDomainGroups(User $user, int $contextId, string $email): void
    {
        $roleType = DomainRoleResolver::resolveRoleType($email);
        $settingKey = DomainRoleResolver::userGroupSettingKey($roleType);

        if ($settingKey) {
            $groupId = (int) $this->plugin->getSetting($contextId, $settingKey);
            if ($groupId > 0 && !Repo::userGroup()->userInGroup($user->getId(), $groupId)) {
                Repo::userGroup()->assignUserToGroup($user->getId(), $groupId);
            }
            return;
        }

        $defaultReader = Repo::userGroup()->getByRoleIds([Role::ROLE_ID_READER], $contextId, true)->first();
        if ($defaultReader && !Repo::userGroup()->userInGroup($user->getId(), $defaultReader->id)) {
            Repo::userGroup()->assignUserToGroup($user->getId(), $defaultReader->id);
        }
    }
}
