# weekly-project-files-sync-audit

## Purpose
Assess whether `docs/project-files/` summaries are ready for ChatGPT Project sync as a downstream export layer.

## Recommended cadence
Weekly (or after documentation-heavy milestones).

## Target scope
- `docs/project-files/*.md`
- Canonical references in code/tests/config and `docs/codex/*` for drift comparison

## Skill usage
Call: `$mtt-project-files-sync-audit`

## Paste-ready automation prompt body
```text
Run $mtt-project-files-sync-audit.

Goal:
- Audit docs/project-files as downstream exports only.
- Classify each file as current, stale, incomplete, or missing.
- Decide READY TO SYNC or NOT READY TO SYNC.

Output requirements:
- Per-file classification table.
- Minimal update list required before next sync (if not ready).
- Final recommendation for operator action.
```

## Suggested operator review checklist
- Are classifications grounded in current repo truth (not assumptions)?
- Is downstream-only status of docs/project-files preserved?
- Is the sync recommendation actionable without extra interpretation?
