Planning task for the current repository.

Goal:  
Identify the next milestone-sized unit of work that moves the repository forward while preserving the current control plane, validation order, and anti-loop workflow.

Hard rules:  
\- Do NOT implement changes.  
\- Do NOT broaden into a full repo redesign.  
\- Do NOT reopen completed milestone history without direct regression evidence.  
\- Use docs/codex/DOC_SYNC_MATRIX.md to determine which documentation surfaces are likely to matter.  
\- Treat docs/project-files as downstream export only.

Inspect first:  
\- docs/codex/PLAN.md  
\- docs/codex/STATUS.md  
\- docs/codex/RUNBOOK.md  
\- docs/codex/REPO_OVERVIEW.md  
\- docs/codex/DOC_SYNC_MATRIX.md  
\- relevant source/test/config files  
\- recent commits / current branch state if helpful

Required procedure:  
1\. Determine actual current milestone position  
2\. Identify the highest-leverage next milestone  
3\. Keep milestone size narrow and reviewable  
4\. Define:  
   - objective  
   - constraints  
   - likely files/modules  
   - validation plan  
   - required docs per DOC_SYNC_MATRIX  
   - success criteria  
   - rollback notes if relevant

Output:  
A) Current state summary  
B) Recommended next milestone  
C) Why this milestone now  
D) Exact implementation scope  
E) Validation plan  
F) Required docs/exports  
G) Success criteria  
H) Risks / assumptions  
I) Next suggested prompt

Next suggested prompt:  
\- \`02-milestone-implementation.md\`