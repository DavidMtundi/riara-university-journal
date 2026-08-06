<?php

/**
 * @file plugins/generic/riaraworkflownotifications/RiaraWorkflowNotificationsPlugin.php
 *
 * @brief Automatically notify authors by email on submission and editorial decisions.
 */

namespace APP\plugins\generic\riaraworkflownotifications;

use APP\core\Application;
use APP\plugins\generic\riaraworkflownotifications\classes\AutoNotifyAuthorsListener;
use Illuminate\Support\Facades\Event;
use PKP\observers\events\DecisionAdded;
use PKP\plugins\GenericPlugin;
use PKP\plugins\PluginRegistry;

class RiaraWorkflowNotificationsPlugin extends GenericPlugin
{
    public function getDisplayName()
    {
        return __('plugins.generic.riaraworkflownotifications.displayName');
    }

    public function getDescription()
    {
        return __('plugins.generic.riaraworkflownotifications.description');
    }

    public function register($category, $path, $mainContextId = null)
    {
        if (!parent::register($category, $path, $mainContextId)) {
            return false;
        }

        if (Application::isUnderMaintenance()) {
            return true;
        }

        static $listenerRegistered = false;
        if (!$listenerRegistered) {
            Event::listen(DecisionAdded::class, function (DecisionAdded $event) {
                $plugin = PluginRegistry::getPlugin('generic', 'riaraworkflownotificationsplugin');
                if (!$plugin instanceof self || !$plugin->getEnabled($event->context->getId())) {
                    return;
                }
                (new AutoNotifyAuthorsListener())->handle($event);
            });
            $listenerRegistered = true;
        }

        return true;
    }
}
