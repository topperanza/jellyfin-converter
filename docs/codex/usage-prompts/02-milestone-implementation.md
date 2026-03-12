Implementation task for the current repository.

Goal:  
Implement exactly one milestone-sized change according to the repository control plane and current milestone contract.

Hard rules:  
\- Do NOT redesign the repository.  
\- Do NOT broaden scope beyond the selected milestone.  
\- Do NOT reopen unrelated completed milestones without direct regression evidence.  
\- Keep diffs narrow and review-friendly.  
\- Use docs/codex/DOC_SYNC_MATRIX.md to update only the documentation that is required for this milestone.  
\- Treat docs/project-files as downstream export only unless explicitly required.

Inspect first:  
\- docs/codex/PLAN.md  
\- docs/codex/STATUS.md  
\- docs/codex/RUNBOOK.md  
\- docs/codex/REPO_OVERVIEW.md  
\- docs/codex/DOC_SYNC_MATRIX.md  
\- relevant source/test/config/build files

Required procedure:  
1\. Restate the milestone contract  
2\. Implement only that scope  
3\. Run milestone-specific validation first  
4\. Run bash scripts/check-fast.sh  
5\. Run bash scripts/check-changed.sh if present/relevant  
6\. Run bash scripts/check-full.sh only if justified  
7\. Update required docs according to DOC_SYNC_MATRIX  
8\. Return concise implementation summary

Output:  
A) Milestone contract  
B) Files changed  
C) Validation performed  
D) Docs updated  
E) Follow-ups  
F) Completion status