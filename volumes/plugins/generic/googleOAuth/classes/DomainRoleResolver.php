<?php

/**
 * @file plugins/generic/googleOAuth/classes/DomainRoleResolver.php
 *
 * @brief Map Riara Google account email domains to internal role types.
 */

namespace APP\plugins\generic\googleOAuth\classes;

class DomainRoleResolver
{
    public const ROLE_STUDENT = 'student';
    public const ROLE_STAFF = 'staff';
    public const ROLE_EXTERNAL = 'external';

    public const STUDENT_DOMAIN = 'stu.riarauniversity.ac.ke';
    public const STAFF_DOMAIN = 'riarauniversity.ac.ke';

    public static function normalizeEmail(string $email): string
    {
        return strtolower(trim($email));
    }

    public static function resolveRoleType(string $email): string
    {
        $email = self::normalizeEmail($email);
        if (!str_contains($email, '@')) {
            return self::ROLE_EXTERNAL;
        }

        $domain = substr($email, strrpos($email, '@') + 1);

        if ($domain === self::STUDENT_DOMAIN) {
            return self::ROLE_STUDENT;
        }

        if ($domain === self::STAFF_DOMAIN) {
            return self::ROLE_STAFF;
        }

        return self::ROLE_EXTERNAL;
    }

    public static function isUniversityAffiliated(string $email): bool
    {
        $role = self::resolveRoleType($email);
        return $role === self::ROLE_STUDENT || $role === self::ROLE_STAFF;
    }

    public static function userGroupSettingKey(string $roleType): ?string
    {
        return match ($roleType) {
            self::ROLE_STUDENT => 'studentUserGroupId',
            self::ROLE_STAFF => 'staffUserGroupId',
            default => null,
        };
    }
}
