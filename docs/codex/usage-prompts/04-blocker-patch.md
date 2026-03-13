Implementation task for the current repository.

Goal:  
Fix only the current blocking issues that prevent advancement.

This is a blocker-patch task, not a new milestone.

Hard rules:  
\- Do NOT expand scope beyond the listed blockers.  
\- Do NOT reopen unrelated repo areas.  
\- Do NOT do opportunistic cleanup.  
\- Keep diffs minimal and directly tied to the blockers.  
\- Use docs/codex/DOC_SYNC_MATRIX.md only for blocker-relevant documentation changes.

Inspect first:  
\- blocker list from the latest review  
\- docs/codex/DOC_SYNC_MATRIX.md  
\- exact files implicated by the blockers  
\- relevant validation failures

Required procedure:  
1\. Restate blockers  
2\. Patch only those blockers  
3\. Run the narrowest meaningful validation  
4\. Update only blocker-relevant docs  
5\. Return concise blocker-fix summary

Output:  
A) Blockers addressed  
B) Files changed  
C) Validation performed  
D) Remaining blocker risk  
E) Status  
F) Next suggested prompt

Next suggested prompt:  
\- \`05-blocker-closure-check.md\`