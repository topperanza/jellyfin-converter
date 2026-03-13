Review-only task.

Goal:  
Evaluate the just-completed milestone against its stated completion contract and determine whether the repository can advance.

This is a milestone gate, not a full-repo truth audit.

Hard rules:  
\- Do NOT implement changes.  
\- Do NOT edit docs in this task.  
\- Do NOT reopen unrelated completed milestones unless there is direct regression evidence.  
\- Focus on the current milestone contract first.  
\- Use docs/codex/DOC_SYNC_MATRIX.md to determine which documentation updates are BLOCKING vs NON-BLOCKING.  
\- Non-blocking documentation hygiene items must be recorded as follow-ups and must not prevent SAFE TO MOVE ON.  
\- docs/project-files is a downstream export layer, not a primary source of truth for milestone decisions.

Inspect first:  
\- docs/codex/PLAN.md  
\- docs/codex/STATUS.md  
\- docs/codex/RUNBOOK.md  
\- docs/codex/DOC_SYNC_MATRIX.md  
\- exact files changed for the milestone  
\- relevant tests/check results

Required procedure:  
1\. Restate milestone contract  
2\. Check implementation against contract  
3\. Check blocking docs only  
4\. Check validation evidence  
5\. Decide if repo can advance

Output:  
A) Milestone contract  
B) Gate findings  
C) Blocking issues only  
D) Non-blocking follow-ups  
E) Decision  
F) Next suggested prompt

Decision values:  
\- SAFE TO MOVE ON  
\- BLOCKED

Next suggested prompt rules:  
\- If SAFE TO MOVE ON and local verification is needed:  
  \`06-final-local-verification.md\`  
\- If SAFE TO MOVE ON and no local verification is needed:  
  \`07-commit-and-push-after-pass.md\`  
\- If BLOCKED:  
  \`04-blocker-patch.md\`