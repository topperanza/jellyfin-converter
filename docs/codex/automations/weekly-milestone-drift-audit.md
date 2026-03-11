# weekly-milestone-drift-audit

## Purpose
Detect drift between the active milestone contract and actual repository state, with emphasis on conversion/output truth and required blocking docs only.

## Recommended cadence
Weekly.

## Target scope
- `docs/codex/PLAN.md`, `docs/codex/STATUS.md`, `docs/codex/RUNBOOK.md`, `docs/codex/REPO_OVERVIEW.md`, `docs/codex/DOC_SYNC_MATRIX.md`
- Recent code/tests/docs changes affecting conversion pipeline, output naming/metadata, and validation evidence

## Skill usage
Call: `$mtt-repo-milestone-review`

## Paste-ready automation prompt body
```text
Run $mtt-repo-milestone-review.

Goal:
- Infer the true active milestone from PLAN/STATUS/RUNBOOK/REPO_OVERVIEW/DOC_SYNC_MATRIX and recent code/tests/docs changes.
- Gate milestone completion against the milestone contract plus DOC_SYNC_MATRIX blocking rules.
- Bias review toward conversion pipeline truth, originals safety, output naming/metadata correctness, and validation evidence.

Output requirements:
- Classify findings as BLOCKING or NON-BLOCKING FOLLOW-UP.
- Provide explicit verdict: MILESTONE GATE PASS or FAIL.
- If pass, include SAFE TO MOVE ON.
- Include concise evidence list (files/commands reviewed).
```

## Suggested operator review checklist
- Does the result identify the same active milestone as maintainers expect?
- Are all blocking DOC_SYNC_MATRIX obligations addressed?
- Are follow-ups clearly marked non-blocking?
- Is there explicit validation evidence for changed high-risk paths?
