<?php

/**
 * @file plugins/generic/googleOAuth/GoogleOAuthSettingsForm.php
 */

namespace APP\plugins\generic\googleOAuth;

use APP\template\TemplateManager;
use PKP\form\Form;
use PKP\form\validation\FormValidator;
use PKP\form\validation\FormValidatorCSRF;
use PKP\form\validation\FormValidatorPost;
use PKP\security\Role;
use PKP\userGroup\UserGroup;

class GoogleOAuthSettingsForm extends Form
{
    public function __construct(private GoogleOAuthPlugin $plugin, private int $contextId)
    {
        parent::__construct($plugin->getTemplateResource('settingsForm.tpl'));

        $this->addCheck(new FormValidator($this, 'clientId', 'required', 'plugins.generic.googleOAuth.settings.clientIdRequired'));
        $this->addCheck(new FormValidator($this, 'clientSecret', 'required', 'plugins.generic.googleOAuth.settings.clientSecretRequired'));
        $this->addCheck(new FormValidatorPost($this));
        $this->addCheck(new FormValidatorCSRF($this));
    }

    public function initData(): void
    {
        $this->_data = [
            'clientId' => $this->plugin->getSetting($this->contextId, 'clientId'),
            'clientSecret' => $this->plugin->getSetting($this->contextId, 'clientSecret'),
            'restrictSubmissionsToUniversity' => (bool) $this->plugin->getSetting($this->contextId, 'restrictSubmissionsToUniversity'),
            'studentUserGroupId' => (int) $this->plugin->getSetting($this->contextId, 'studentUserGroupId'),
            'staffUserGroupId' => (int) $this->plugin->getSetting($this->contextId, 'staffUserGroupId'),
        ];
    }

    public function readInputData(): void
    {
        $this->readUserVars([
            'clientId',
            'clientSecret',
            'restrictSubmissionsToUniversity',
            'studentUserGroupId',
            'staffUserGroupId',
        ]);
    }

    public function fetch($request, $template = null, $display = false)
    {
        $templateMgr = TemplateManager::getManager($request);
        $service = new classes\GoogleOAuthService($this->plugin);
        $groupOptions = UserGroup::withContextIds([$this->contextId])
            ->withRoleIds([Role::ROLE_ID_READER])
            ->get()
            ->map(fn (UserGroup $group) => [
                'value' => $group->id,
                'label' => $group->getLocalizedData('name'),
            ])
            ->values()
            ->all();

        $templateMgr->assign([
            'pluginName' => $this->plugin->getName(),
            'redirectUri' => $service->getRedirectUri($this->contextId),
            'clientId' => $this->getData('clientId'),
            'clientSecret' => $this->getData('clientSecret'),
            'studentUserGroupId' => $this->getData('studentUserGroupId'),
            'staffUserGroupId' => $this->getData('staffUserGroupId'),
            'studentUserGroupOptions' => $groupOptions,
            'staffUserGroupOptions' => $groupOptions,
            'restrictSubmissionsToUniversity' => (bool) $this->getData('restrictSubmissionsToUniversity'),
        ]);

        return parent::fetch($request, $template, $display);
    }

    public function execute(...$functionArgs)
    {
        $this->plugin->updateSetting($this->contextId, 'clientId', trim((string) $this->getData('clientId')), 'string');
        $this->plugin->updateSetting($this->contextId, 'clientSecret', trim((string) $this->getData('clientSecret')), 'string');
        $this->plugin->updateSetting(
            $this->contextId,
            'restrictSubmissionsToUniversity',
            $this->getData('restrictSubmissionsToUniversity') ? '1' : '0',
            'bool'
        );
        $this->plugin->updateSetting($this->contextId, 'studentUserGroupId', (int) $this->getData('studentUserGroupId'), 'int');
        $this->plugin->updateSetting($this->contextId, 'staffUserGroupId', (int) $this->getData('staffUserGroupId'), 'int');

        parent::execute(...$functionArgs);
    }
}
