<?php

/**
 * OJS Riara helpers for maintenance and workflow scripts.
 */

use APP\core\Application;
use APP\facades\Repo;
use APP\submission\Submission;
use PKP\context\Context;
use PKP\submission\PKPSubmission;
use PKP\submissionFile\SubmissionFile;

function riara_journal_id_from_path(PDO $pdo, string $path): int
{
    $stmt = $pdo->prepare('SELECT journal_id FROM journals WHERE path = ?');
    $stmt->execute([$path]);
    $id = (int) $stmt->fetchColumn();
    if ($id < 1) {
        throw new RuntimeException("Journal not found: $path");
    }
    return $id;
}

function riara_user_group_id(PDO $pdo, int $contextId, int $roleId): int
{
    $stmt = $pdo->prepare(
        'SELECT user_group_id FROM user_groups WHERE context_id = ? AND role_id = ? ORDER BY user_group_id LIMIT 1'
    );
    $stmt->execute([$contextId, $roleId]);
    $id = (int) $stmt->fetchColumn();
    if ($id < 1) {
        throw new RuntimeException("No user group for context $contextId role $roleId");
    }
    return $id;
}

function riara_default_section_id(PDO $pdo, int $journalId): int
{
    $stmt = $pdo->prepare(
        'SELECT section_id FROM sections WHERE journal_id = ? AND is_inactive = 0 ORDER BY seq LIMIT 1'
    );
    $stmt->execute([$journalId]);
    $id = (int) $stmt->fetchColumn();
    if ($id < 1) {
        throw new RuntimeException("No active section for journal $journalId");
    }
    return $id;
}

function riara_proof_genre_id(PDO $pdo, int $contextId): int
{
    $stmt = $pdo->prepare('SELECT genre_id FROM genres WHERE context_id = ? ORDER BY seq LIMIT 1');
    $stmt->execute([$contextId]);
    $id = (int) $stmt->fetchColumn();
    if ($id < 1) {
        throw new RuntimeException("No genre for context $contextId");
    }
    return $id;
}

function riara_cleanup_mass_test_submissions(Context $context, string $titlePrefix = 'Mass Test'): int
{
    $removed = 0;
    $submissions = Repo::submission()->getCollector()
        ->filterByContextIds([$context->getId()])
        ->getMany();

    foreach ($submissions as $submission) {
        /** @var Submission $submission */
        $publication = Repo::publication()->get($submission->getData('currentPublicationId'));
        if (!$publication) {
            continue;
        }
        $title = $publication->getLocalizedTitle();
        if (!str_starts_with((string) $title, $titlePrefix)) {
            continue;
        }
        Repo::submission()->delete($submission);
        $removed++;
    }

    return $removed;
}

function riara_attach_pdf_galley(
    Submission $submission,
    $publication,
    Context $context,
    int $uploaderUserId,
    string $label = 'PDF'
): int {
    $galleyId = Repo::galley()->add(Repo::galley()->newDataObject([
        'publicationId' => $publication->getId(),
        'label' => $label,
        'locale' => $publication->getData('locale') ?: 'en',
    ]));

    $tmpFile = tempnam(sys_get_temp_dir(), 'riara');
    $pdf = "%PDF-1.4\n1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj\n"
        . "2 0 obj<</Type/Pages/Kids[]/Count 0>>endobj\n"
        . "xref\n0 3\ntrailer<</Root 1 0 R>>\nstartxref\n%%EOF\n";
    file_put_contents($tmpFile, $pdf);

    $submissionDir = Repo::submissionFile()->getSubmissionDir($context->getId(), $submission->getId());
    $destPath = $submissionDir . '/' . uniqid('galley-', true) . '.pdf';
    $fileId = app()->get('file')->add($tmpFile, $destPath);
    @unlink($tmpFile);

    $config = require __DIR__ . '/test-config.php';
    $pdo = riara_pdo($config);
    $genreId = riara_proof_genre_id($pdo, $context->getId());

    $submissionFileId = Repo::submissionFile()->add(Repo::submissionFile()->newDataObject([
        'submissionId' => $submission->getId(),
        'fileStage' => SubmissionFile::SUBMISSION_FILE_PROOF,
        'fileId' => $fileId,
        'genreId' => $genreId,
        'assocType' => Application::ASSOC_TYPE_REPRESENTATION,
        'assocId' => $galleyId,
        'uploaderUserId' => $uploaderUserId,
        'name' => ['en' => $label . '.pdf'],
    ]));

    $galley = Repo::galley()->get($galleyId);
    Repo::galley()->edit($galley, ['submissionFileId' => $submissionFileId]);

    return $galleyId;
}

function riara_published_galley_count(PDO $pdo, int $submissionId): int
{
    $stmt = $pdo->prepare(
        'SELECT COUNT(*)
         FROM publication_galleys pg
         JOIN submissions s ON s.current_publication_id = pg.publication_id
         WHERE s.submission_id = ?'
    );
    $stmt->execute([$submissionId]);
    return (int) $stmt->fetchColumn();
}

/** Submission assoc type in email_log (PKPApplication::ASSOC_TYPE_SUBMISSION). */
function riara_submission_email_log_count(PDO $pdo, int $submissionId, ?int $eventType = null): int
{
    $sql = 'SELECT COUNT(*) FROM email_log WHERE assoc_type = ? AND assoc_id = ?';
    $params = [0x0100009, $submissionId];
    if ($eventType !== null) {
        $sql .= ' AND event_type = ?';
        $params[] = $eventType;
    }
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    return (int) $stmt->fetchColumn();
}
