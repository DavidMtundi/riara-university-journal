# Review viewer plugin — future specification

## Problem

OJS 3.5 reviewers **download** manuscripts and enter comments in forms. There is no native inline PDF annotation on the public or editorial UI.

## Proposed plugin (not implemented)

A `riarareviewviewer` generic plugin could:

1. Hook into the reviewer submission view
2. Embed PDF.js for in-browser reading
3. Store annotations as review attachments or structured JSON linked to `review_assignments`
4. Surface shared highlights to authors when editors include them in revision decisions

## Scope estimate

- **2–4 weeks** for MVP (read-only PDF + text comments sync)
- Requires PKP API hooks, file storage policy review, and accessibility testing

## Current recommendation

Use stock OJS workflow documented in `docs/EDITORIAL-PLAYBOOK.md` until editorial staff confirm a need for inline annotation.
