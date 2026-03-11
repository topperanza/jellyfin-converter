# pre-release-truth-audit

## Purpose
Run a release-facing truth audit before release cut or release candidate sign-off.

## Recommended cadence
Before each release or RC handoff.

## Target scope
- Release-facing docs and operator flows:
  - `README.md`
  - `docs/codex/RUNBOOK.md`
  - config/examples under `config/` and `examples/`
  - conversion/output behavior docs (`docs/architecture.md`, `docs/user-guide.md`, `docs/subtitles.md`)
- Required exports only when `docs/codex/DOC_SYNC_MATRIX.md` marks them as blocking

## Skill usage
Call: `$mtt-repo-milestone-review` (release-facing focus)

## Paste-ready automation prompt body
```text
Run $mtt-repo-milestone-review with a release-facing focus.

Goal:
- Gate release readiness against repository truth and DOC_SYNC_MATRIX blocking rules.
- Explicitly verify alignment for README, RUNBOOK, config examples, conversion/output docs, and operator-facing docs.
- Require docs/project-files updates only when DOC_SYNC_MATRIX marks them as blocking for this change type.

Output requirements:
- BLOCKING vs NON-BLOCKING FOLLOW-UP classification.
- Explicit verdict: RELEASE TRUTH AUDIT PASS or FAIL.
- If pass, include SAFE TO MOVE ON.
- Concise evidence list with key files/validation references.
```

## Suggested operator review checklist
- Are all release-facing docs aligned with runtime behavior?
- Are safety/determinism expectations explicit and unchanged (or properly documented)?
- Are required blocking exports/docs completed per DOC_SYNC_MATRIX?
- Are any remaining issues clearly non-blocking with follow-up ownership?
