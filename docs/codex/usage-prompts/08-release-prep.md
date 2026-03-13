Review-only task.

Repo:  
\[REPO_NAME\]

Goal:  
Prepare the repository for a release/tag by verifying release-facing truth, required docs, required exports, validation evidence, and release readiness without broadening scope into unrelated cleanup.

This is a release-prep task, not a general milestone implementation task.

Hard rules:  
\- Do NOT implement unrelated features.  
\- Do NOT reopen old milestone history unless it directly affects release truth.  
\- Use docs/codex/DOC_SYNC_MATRIX.md to determine which docs/exports are required for release-facing changes.  
\- Treat docs/project-files as downstream export only; require export refresh only when DOC_SYNC_MATRIX.md makes it relevant.  
\- Be strict about operator-facing truth.  
\- Prefer a narrow release-readiness patch over broad cleanup.

Inspect first:  
\- README.md  
\- AGENTS.md  
\- docs/codex/PLAN.md  
\- docs/codex/STATUS.md  
\- docs/codex/RUNBOOK.md  
\- docs/codex/REPO_OVERVIEW.md  
\- docs/codex/DOC_SYNC_MATRIX.md  
\- docs/project-files/  
\- config examples / sample config files  
\- release/process docs if present  
\- relevant source/test files for the release scope  
\- scripts/check-fast.sh  
\- scripts/check-changed.sh  
\- scripts/check-full.sh

Required procedure:  
1\. Identify the release scope  
2\. Verify release-facing implementation truth  
3\. Verify release-facing documentation truth  
4\. Verify required exports only if DOC_SYNC_MATRIX.md says they matter  
5\. Run the lightest sufficient release validation:  
   - narrow release-specific validation first  
   - bash scripts/check-fast.sh  
   - bash scripts/check-changed.sh if present and relevant  
   - bash scripts/check-full.sh if justified by release risk  
6\. Classify unresolved items as:  
   - RELEASE BLOCKER  
   - NON-BLOCKING FOLLOW-UP  
7\. Decide:  
   - READY FOR RELEASE  
   - FIX RELEASE BLOCKERS FIRST

Output:  
A) Release scope  
B) Release-facing truth check  
C) Validation performed  
D) Release blockers  
E) Non-blocking follow-ups  
F) Release readiness decision  
G) If blocked: exact pre-release fix list  
H) If passed: concise release checklist  
I) Final short summary  
J) Next suggested prompt

Next suggested prompt rules:  
\- If READY FOR RELEASE and no additional changes were required:  
  \`09-tag-and-release.md\`  
\- If READY FOR RELEASE but release-prep fixes were made and still need commit/push:  
  \`07-commit-and-push-after-pass.md\`  
\- If FIX RELEASE BLOCKERS FIRST:  
  \`04-blocker-patch.md\`