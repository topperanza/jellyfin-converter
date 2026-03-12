Final local verification task for the current repository.

Goal:  
Perform a final local verification pass to confirm that the completed work is operationally sound on the real local environment and remains aligned with the repo control plane.

This is a verification task, not a new implementation task.

Hard rules:  
\- Do NOT do broad new implementation work.  
\- Do NOT reopen milestone history unless there is direct regression evidence.  
\- Prefer verification and only the smallest corrective patch if a last-mile issue is found.  
\- Use docs/codex/DOC_SYNC_MATRIX.md for required tracking surfaces.  
\- Treat docs/project-files as downstream export only.

Inspect first:  
\- docs/codex/PLAN.md  
\- docs/codex/STATUS.md  
\- docs/codex/RUNBOOK.md  
\- docs/codex/REPO_OVERVIEW.md  
\- docs/codex/DOC_SYNC_MATRIX.md  
\- scripts/codex/setup.sh  
\- scripts/codex/maintenance.sh  
\- scripts/check-fast.sh  
\- scripts/check-changed.sh  
\- scripts/check-full.sh  
\- relevant build/runtime/config files  
\- relevant test directories

Required procedure:  
1\. Verify control-plane coherence  
2\. Verify repo-specific environment/bootstrap scripts if relevant  
3\. Verify repo-specific validation scripts if relevant  
4\. Run final local validation:  
   - narrow milestone-specific checks first  
   - bash scripts/check-fast.sh  
   - bash scripts/check-changed.sh if present and relevant  
   - bash scripts/check-full.sh if justified  
5\. Decide:  
   - READY FOR COMMIT/PUSH  
   - ONE LAST PATCH NEEDED

Output:  
A) Verification verdict  
B) Verification matrix  
C) Validation performed  
D) Remaining blocker if any  
E) Final recommendation  
F) Short summary