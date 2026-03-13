Review-only task.

Goal:  
Determine whether the currently listed blockers have been fixed and whether the repository can now advance.

This is a blocker-closure check, not a fresh milestone gate and not a full repo audit.

Hard rules:  
\- Do NOT implement changes.  
\- Do NOT revisit unrelated milestone history.  
\- Check only the named blockers plus protected regression areas.  
\- Use docs/codex/DOC_SYNC_MATRIX.md to distinguish blocking vs non-blocking documentation items.  
\- docs/project-files should only be checked if the blocker list or DOC_SYNC_MATRIX.md makes it relevant.

Inspect:  
\- prior blocker list  
\- docs/codex/DOC_SYNC_MATRIX.md  
\- exact files changed to fix blockers  
\- relevant tests/check results  
\- required docs/exports tied to those blockers

Output:  
A) Blocker closure matrix  
B) Regression check  
C) Decision  
D) Remaining blockers only  
E) If passed: confirm repo is ready for next step  
F) Next suggested prompt

Decision values:  
\- SAFE TO MOVE ON  
\- STILL BLOCKED

Next suggested prompt rules:  
\- If SAFE TO MOVE ON and local verification is needed:  
  \`06-final-local-verification.md\`  
\- If SAFE TO MOVE ON and no local verification is needed:  
  \`07-commit-and-push-after-pass.md\`  
\- If STILL BLOCKED:  
  \`04-blocker-patch.md\`