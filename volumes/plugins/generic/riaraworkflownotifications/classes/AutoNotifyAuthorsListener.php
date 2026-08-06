<?php

/**
 * @file plugins/generic/riaraworkflownotifications/classes/AutoNotifyAuthorsListener.php
 *
 * @brief Send author notification emails when an editorial decision is recorded.
 */

namespace APP\plugins\generic\riaraworkflownotifications\classes;

use APP\decision\Decision;
use APP\facades\Repo;
use APP\submission\Submission;
use PKP\context\Context;
use PKP\db\DAORegistry;
use PKP\decision\DecisionType;
use PKP\decision\steps\Email as EmailStep;
use PKP\decision\Steps;
use PKP\decision\types\traits\NotifyAuthors;
use PKP\mail\EmailData;
use PKP\mail\Mailable;
use PKP\observers\events\DecisionAdded;
use PKP\submission\reviewRound\ReviewRound;
use ReflectionClass;
use ReflectionMethod;
use ReflectionNamedType;
use ReflectionProperty;

class AutoNotifyAuthorsListener
{
    public function handle(DecisionAdded $event): void
    {
        foreach ($event->actions as $action) {
            if (($action['id'] ?? '') === 'notifyAuthors') {
                return;
            }
        }

        $decisionType = $event->decisionType;
        if (!in_array(NotifyAuthors::class, class_uses_recursive($decisionType), true)) {
            return;
        }

        $reviewRound = $this->getReviewRound($event->decision);
        $steps = $decisionType->getSteps($event->submission, $event->context, $event->editor, $reviewRound);
        if (!$steps instanceof Steps) {
            return;
        }

        $emailStep = $this->findNotifyAuthorsStep($steps);
        if (!$emailStep) {
            return;
        }

        $mailable = $this->buildMailable($emailStep, $decisionType, $event);
        if (!$mailable) {
            return;
        }

        $emailData = $this->buildDefaultEmailData($mailable, $emailStep, $event);
        if (!$emailData) {
            return;
        }

        $method = new ReflectionMethod($decisionType, 'sendAuthorEmail');
        $method->setAccessible(true);
        $method->invoke(
            $decisionType,
            $mailable,
            $emailData,
            $event->editor,
            $event->submission,
            $event->context
        );
    }

    private function getReviewRound(Decision $decision): ?ReviewRound
    {
        $reviewRoundId = $decision->getData('reviewRoundId');
        if (!$reviewRoundId) {
            return null;
        }

        $reviewRoundDao = DAORegistry::getDAO('ReviewRoundDAO');
        $reviewRound = $reviewRoundDao->getById($reviewRoundId);

        return $reviewRound instanceof ReviewRound ? $reviewRound : null;
    }

    private function findNotifyAuthorsStep(Steps $steps): ?EmailStep
    {
        $property = new ReflectionProperty($steps, 'steps');
        $property->setAccessible(true);
        $stepList = $property->getValue($steps);

        foreach ($stepList as $step) {
            if ($step instanceof EmailStep && $step->id === 'notifyAuthors') {
                return $step;
            }
        }

        return null;
    }

    private function buildMailable(
        EmailStep $emailStep,
        DecisionType $decisionType,
        DecisionAdded $event
    ): ?Mailable {
        $prototype = $this->getStepProperty($emailStep, 'mailable');
        if (!$prototype instanceof Mailable) {
            return null;
        }

        $class = get_class($prototype);
        $constructor = new ReflectionMethod($class, '__construct');
        $args = [];

        foreach ($constructor->getParameters() as $parameter) {
            $type = $parameter->getType();
            if (!$type instanceof ReflectionNamedType) {
                continue;
            }

            $typeName = $type->getName();
            if ($typeName === 'array') {
                $args[] = $this->getReviewAssignments($decisionType, $event);
            } elseif (is_a($event->context, $typeName, true)) {
                $args[] = $event->context;
            } elseif (is_a($event->submission, $typeName, true)) {
                $args[] = $event->submission;
            } elseif (is_a($event->decision, $typeName, true)) {
                $args[] = $event->decision;
            }
        }

        return new $class(...$args);
    }

    private function getReviewAssignments(DecisionType $decisionType, DecisionAdded $event): array
    {
        $reviewRoundId = $event->decision->getData('reviewRoundId');
        if (!$reviewRoundId || !method_exists($decisionType, 'getReviewAssignments')) {
            return [];
        }

        $method = new ReflectionMethod($decisionType, 'getReviewAssignments');
        $method->setAccessible(true);

        return $method->invoke(
            $decisionType,
            $event->submission->getId(),
            $reviewRoundId,
            DecisionType::REVIEW_ASSIGNMENT_COMPLETED
        );
    }

    private function buildDefaultEmailData(
        Mailable $mailable,
        EmailStep $emailStep,
        DecisionAdded $event
    ): ?EmailData {
        $templateKey = $mailable::getEmailTemplateKey();
        if (!$templateKey) {
            return null;
        }

        $template = Repo::emailTemplate()->getByKey($event->context->getId(), $templateKey);
        if (!$template) {
            return null;
        }

        $locale = $event->submission->getData('locale') ?: $event->context->getPrimaryLocale();
        $recipients = $this->getStepProperty($emailStep, 'recipients');
        if (!is_array($recipients)) {
            return null;
        }

        return new EmailData([
            'subject' => (string) $template->getLocalizedData('subject', $locale),
            'body' => (string) $template->getLocalizedData('body', $locale),
            'recipients' => array_map(fn ($user) => $user->getId(), $recipients),
            'locale' => $locale,
        ]);
    }

    private function getStepProperty(EmailStep $step, string $name): mixed
    {
        $property = new ReflectionProperty($step, $name);
        $property->setAccessible(true);

        return $property->getValue($step);
    }
}
