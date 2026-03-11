# 07 Commit Push After Pass

When to use: Use only after Prompt 06 returns READY FOR COMMIT/PUSH.
Run in: Codex Local app

```text
Task: perform safe, milestone-aware commit/push.

Steps:
1) inspect git state (status, branch, staged/unstaged diff)
2) verify required tracking surfaces are updated (STATUS, checkpoint, required docs per DOC_SYNC_MATRIX)
3) run the lightest sufficient validation for confidence on final diff
4) stage only milestone-scoped files
5) commit with coherent milestone-aware message
6) push safely (no force push)

Rules:
- no unrelated churn
- no amend/rewrite unless explicitly requested
- docs/project-files changes are only included when required by DOC_SYNC_MATRIX/material handoff impact

Output required:
- files committed
- commit message
- commit hash
- push target
- residual non-blocking follow-ups
```
