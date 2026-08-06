<?php



/**

 * End-to-end editorial workflow: author submission → reviewer → editor publish.

 *

 * Creates a fresh submission each run (unique title). Safe to run repeatedly.

 * Run inside app container: php /tmp/workflow-runner.php

 */



require __DIR__ . '/test-lib.php';

require __DIR__ . '/riara-ojs-lib.php';



use APP\decision\Decision;

use APP\facades\Repo;

use APP\submission\Submission;

use PKP\db\DAORegistry;

use PKP\security\Role;

use PKP\submission\PKPSubmission;

use PKP\submission\reviewAssignment\ReviewAssignment;

use PKP\submission\reviewRound\ReviewRound;



$config = require __DIR__ . '/test-config.php';

$pdo = riara_pdo($config);

$journalPath = $config['journalPath'];

$context = riara_bootstrap_ojs($journalPath);

$contextId = (int) $context->getId();

$journalId = riara_journal_id_from_path($pdo, $journalPath);

$sectionId = riara_default_section_id($pdo, $journalId);

$authorGroupId = riara_user_group_id($pdo, $contextId, Role::ROLE_ID_AUTHOR);

$editorGroupId = riara_user_group_id($pdo, $contextId, Role::ROLE_ID_MANAGER);



$runId = date('Ymd-His');

$title = "Mass Test $runId: Digital Learning in Kenyan Universities";



if (!$context) {

    fwrite(STDERR, "Journal context not loaded\n");

    exit(1);

}



if (getenv('OJS_CLEANUP_WORKFLOW') !== '0') {

    $removed = riara_cleanup_mass_test_submissions($context);

    if ($removed > 0) {

        echo "Cleaned up $removed prior Mass Test submission(s)\n";

    }

}



$authorId = (int) Repo::user()->getByUsername('author', true)?->getId();

$reviewerId = (int) Repo::user()->getByUsername('reviewer', true)?->getId();

$editorId = (int) Repo::user()->getByUsername('root', true)?->getId();



if (!$authorId || !$reviewerId || !$editorId) {

    fwrite(STDERR, "Missing test users. Run create-test-users.php first.\n");

    exit(1);

}



function record_decision(Submission $submission, int $decisionConst, int $editorId, ?int $reviewRoundId = null): void

{

    $decisionType = Repo::decision()->getDecisionType($decisionConst);

    if (!$decisionType) {

        throw new RuntimeException("Unknown decision type: $decisionConst");

    }



    $submission = Repo::submission()->get($submission->getId());

    $stageId = $decisionType->getStageId();

    if ($submission->getData('stageId') !== $stageId) {

        throw new RuntimeException(

            "Submission {$submission->getId()} at stage {$submission->getData('stageId')}, expected $stageId for decision $decisionConst"

        );

    }



    $params = [

        'submissionId' => $submission->getId(),

        'editorId' => $editorId,

        'decision' => $decisionConst,

        'stageId' => $stageId,

    ];

    if ($reviewRoundId) {

        $params['reviewRoundId'] = $reviewRoundId;

    }



    $decision = Repo::decision()->newDataObject($params);

    Repo::decision()->add($decision);

}



// --- Create submission ---

$submission = Repo::submission()->newDataObject();

$submission->setData('contextId', $contextId);

$submission->setData('status', PKPSubmission::STATUS_QUEUED);

$submission->setData('stageId', WORKFLOW_STAGE_ID_SUBMISSION);

$submission->setData('locale', 'en');



$publication = Repo::publication()->newDataObject();

$publication->setData('locale', 'en');

$publication->setData('title', ['en' => $title]);

$publication->setData('abstract', ['en' => 'Automated mass-test submission for Riara University Journal workflow validation.']);

$publication->setData('sectionId', $sectionId);



$submissionId = Repo::submission()->add($submission, $publication, $context);

$submission = Repo::submission()->get($submissionId);

$publication = Repo::publication()->get($submission->getData('currentPublicationId'));



// Author on publication + stage assignment

$authorUser = Repo::user()->get($authorId);

$author = Repo::author()->newDataObject();

$author->setData('publicationId', $publication->getId());

$author->setData('email', $authorUser->getEmail());

$author->setData('userGroupId', $authorGroupId);

$author->setData('includeInBrowse', true);

$author->setData('givenName', ['en' => 'Jane']);

$author->setData('familyName', ['en' => 'Author']);

$authorIdDb = Repo::author()->add($author);

Repo::publication()->edit($publication, ['primaryContactId' => $authorIdDb]);



Repo::stageAssignment()->build($submissionId, $authorGroupId, $authorId);

Repo::stageAssignment()->build($submissionId, $editorGroupId, $editorId);

$authorGroupStmt = $pdo->prepare('SELECT user_group_id FROM user_groups WHERE context_id = ? AND role_id = ?');
$authorGroupStmt->execute([$contextId, Role::ROLE_ID_AUTHOR]);
foreach ($authorGroupStmt->fetchAll(PDO::FETCH_COLUMN) as $groupId) {
    Repo::stageAssignment()->build($submissionId, (int) $groupId, $authorId);
}

Repo::submission()->submit($submission, $context);
$submission = Repo::submission()->get($submissionId);

echo "Created submission $submissionId: $title\n";



// Send to external review

record_decision($submission, Decision::EXTERNAL_REVIEW, $editorId);

$submission = Repo::submission()->get($submissionId);

echo "Stage after send to review: {$submission->getData('stageId')}\n";



// Review round + reviewer

$reviewRoundDao = DAORegistry::getDAO('ReviewRoundDAO');

$reviewRound = $reviewRoundDao->getLastReviewRoundBySubmissionId($submissionId, WORKFLOW_STAGE_ID_EXTERNAL_REVIEW);

if (!$reviewRound) {

    $reviewRound = $reviewRoundDao->newDataObject();

    $reviewRound->setSubmissionId($submissionId);

    $reviewRound->setStageId(WORKFLOW_STAGE_ID_EXTERNAL_REVIEW);

    $reviewRound->setRound(1);

    $reviewRound->setStatus(ReviewRound::REVIEW_ROUND_STATUS_PENDING_REVIEWERS);

    $reviewRoundId = $reviewRoundDao->insert($reviewRound);

    $reviewRound = $reviewRoundDao->getById($reviewRoundId);

}



$assignment = Repo::reviewAssignment()->newDataObject([

    'submissionId' => $submissionId,

    'reviewerId' => $reviewerId,

    'reviewRoundId' => $reviewRound->getId(),

    'stageId' => WORKFLOW_STAGE_ID_EXTERNAL_REVIEW,

    'dateAssigned' => date('Y-m-d H:i:s'),

    'dateNotified' => date('Y-m-d H:i:s'),

    'dateDue' => date('Y-m-d H:i:s', strtotime('+2 weeks')),

    'dateResponseDue' => date('Y-m-d H:i:s', strtotime('+1 week')),

]);

$assignmentId = Repo::reviewAssignment()->add($assignment);

$assignment = Repo::reviewAssignment()->get($assignmentId);

echo "Reviewer assigned\n";



Repo::reviewAssignment()->edit($assignment, [

    'dateConfirmed' => date('Y-m-d H:i:s'),

    'dateCompleted' => date('Y-m-d H:i:s'),

    'recommendation' => ReviewAssignment::SUBMISSION_REVIEWER_RECOMMENDATION_ACCEPT,

    'considered' => ReviewAssignment::SUBMISSION_REVIEWER_RECOMMENDATION_ACCEPT,

]);

$reviewRoundDao->updateStatus($reviewRound, ReviewRound::REVIEW_ROUND_STATUS_REVIEWS_READY);

echo "Reviewer completed with accept recommendation\n";



// Editor accepts

record_decision($submission, Decision::ACCEPT, $editorId, $reviewRound->getId());

$submission = Repo::submission()->get($submissionId);

echo "Stage after accept: {$submission->getData('stageId')}\n";



// Send to production

record_decision($submission, Decision::SEND_TO_PRODUCTION, $editorId);

$submission = Repo::submission()->get($submissionId);

echo "Stage after production: {$submission->getData('stageId')}\n";



// Attach PDF galley before publish

$publication = Repo::publication()->get($submission->getData('currentPublicationId'));

$galleyId = riara_attach_pdf_galley($submission, $publication, $context, $editorId);

echo "Attached PDF galley $galleyId\n";



// Publish publication (attach to current published issue if available)

$issue = Repo::issue()->getCollector()->filterByContextIds([$contextId])->filterByPublished(true)->getMany()->first();

if ($issue) {

    Repo::publication()->edit($publication, ['issueId' => $issue->getId()]);

    $publication = Repo::publication()->get($publication->getId());

}

Repo::publication()->publish($publication);

$submission = Repo::submission()->get($submissionId);

$publication = Repo::publication()->get($submission->getData('currentPublicationId'));



echo "Submission status: {$submission->getData('status')}\n";

echo "Publication status: {$publication->getData('status')}\n";

echo "Article URL: /index.php/$journalPath/article/view/$submissionId\n";



if ($submission->getData('status') !== PKPSubmission::STATUS_PUBLISHED) {

    fwrite(STDERR, "Workflow failed: submission not published\n");

    exit(1);

}



$galleyCount = riara_published_galley_count($pdo, $submissionId);

if ($galleyCount < 1) {

    fwrite(STDERR, "Workflow failed: no galleys on published submission\n");

    exit(1);

}



echo json_encode([

    'ok' => true,

    'submissionId' => $submissionId,

    'galleyId' => $galleyId,

    'galleyCount' => $galleyCount,

    'title' => $title,

    'status' => $submission->getData('status'),

], JSON_PRETTY_PRINT) . "\n";

