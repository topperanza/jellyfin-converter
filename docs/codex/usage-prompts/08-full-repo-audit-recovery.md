# 08 Full Repo Audit Recovery

When to use: Use only when broad drift/contradiction is suspected and normal milestone flow cannot proceed safely.
Run in: Codex Cloud

```text
Task: perform recovery-only full repo audit and propose minimal recovery milestones.

Read:
- AGENTS.md
- docs/codex/PLAN.md
- docs/codex/STATUS.md
- docs/codex/RUNBOOK.md
- docs/codex/REPO_OVERVIEW.md
- docs/codex/DOC_SYNC_MATRIX.md
- recent checkpoints

Audit focus:
- control-plane consistency
- PLAN vs STATUS milestone alignment
- validation order consistency
- gate semantics (blocking vs non-blocking)
- source-of-truth ordering adherence

Rules:
- This is recovery-only, not normal milestone gate behavior.
- Produce small, sequenced repair milestones.
- Keep findings evidence-based with exact file paths.

Output required:
- findings (with severity)
- minimal recovery plan
- validation approach per recovery milestone
- stop condition to return to standard flow
```
