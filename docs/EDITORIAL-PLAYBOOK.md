# Editorial playbook — Riara University Journal (OJS 3.5)

## Review workflow (stock OJS)

Riara uses **stock OJS editorial tools** — there is no custom inline PDF reviewer.

### Reviewer steps

1. Log in at `/index.php/riara/login`
2. Open **Submissions** from the dashboard
3. Open the assigned submission in the review round
4. **Download** the review file (manuscript)
5. Enter comments in the review form:
   - **Comments for the author** (shared when the editor includes them in a decision)
   - **Comments for the editor** (private)
6. Optionally upload an **annotated copy** as a review attachment
7. Submit recommendation (accept / revisions / decline)

### Editor steps

1. Monitor review round completion in the workflow
2. Record decision (e.g. **Request revisions**, **Accept**, **Decline**)
3. When accepting, send to **Production**
4. Upload or approve **galleys** (PDF/HTML) in the production stage
5. Assign to an issue and **Publish**

### Author visibility

Authors see reviewer comments only when the editor shares them via a decision (e.g. revision request). OJS does not provide native in-browser PDF annotation.

## Email notifications

Riara is configured to send **automatic feedback emails** at key workflow points:

| Event | Recipients | Mechanism |
|-------|------------|-----------|
| Manuscript submitted | Submitting author (+ all co-authors when configured) | OJS `SubmissionSubmitted` → submission acknowledgement template |
| New submission (no editor assigned) | Journal managers | OJS `AssignEditors` listener |
| Editorial decision (send to review, accept, production, revisions, decline, etc.) | Assigned author(s) | **Riara Workflow Email Notifications** plugin — auto-sends the default decision template when the editor records a decision |

Journal settings (applied by `bootstrap-email-notifications.php`):

- `submissionAcknowledgement = allAuthors`
- `notifyAllAuthors = 1` (co-authors receive a separate notice on decisions)
- `copySubmissionAckPrimaryContact = 1` (journal contact BCC on submission ack)
- Editor email alert on new submissions enabled

The generic plugin `riaraworkflownotifications` listens for `DecisionAdded` and sends the author notification **unless** the editor already sent a custom email in the decision wizard (avoids duplicates).

**Verify in dev:** Submission → Workflow → **History** → **Email Log**, or query the `email_log` table. Configure outbound mail via `OJS_SMTP_*` in `.env` (see `render-config.php`).

## Google Sign-In (Riara staff & students)

The `googleOAuth` plugin adds **Sign in with Google** on login and register pages.

| Email domain | User group |
|--------------|------------|
| `@stu.riarauniversity.ac.ke` | Student (Reader) |
| `@riarauniversity.ac.ke` | Staff (Reader) |
| Other Google accounts | Default Reader |

- Existing OJS accounts are **linked by email** on first Google sign-in.
- Optional journal setting: **Restrict new submissions to Riara University Google accounts only**.
- Bootstrap: `bootstrap-google-oauth.php` (see `docs/RIARA.md` for Google Cloud redirect URI).

## Test automation

| Script | Purpose |
|--------|---------|
| `workflow-runner.php` | End-to-end submit → review → publish with PDF galley |
| `cleanup-workflow-tests.php` | Remove `Mass Test*` submissions |
| `create-test-users.php` | Ensure `author` / `reviewer` test accounts |

Workflow runner cleans up prior `Mass Test` submissions by default. Set `OJS_CLEANUP_WORKFLOW=0` to keep them.

## Production notes

- Rotate default passwords (`root`, `author`, `reviewer`) before go-live
- Use HTTPS and `force_ssl = On` in OJS config
- See `docs/RIARA.md` for backup/restore and upgrade runbooks
