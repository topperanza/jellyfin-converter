\# 07 — Commit / push after pass.md

Commit / push task for the current repository.

Run this with a local-capable agent only.

Goal:  
Commit and push the completed work safely, with milestone-aware tracking, explicit validation evidence, and no history rewriting.

Precondition:  
\- the milestone gate has passed, or blocker closure has confirmed \`SAFE TO MOVE ON\`  
\- if local verification was needed, it has already passed

Hard rules:  
\- Do NOT force-push.  
\- Do NOT rewrite history.  
\- Do NOT amend old commits unless explicitly required and clearly reported.  
\- Do NOT create vague commit messages.  
\- Do NOT commit unrelated generated junk.  
\- Do NOT commit unvalidated work.  
\- Use canonical workflow docs first:  
  1. \`docs/agent-workflow/\*\` if present  
  2. \`docs/codex/\*\`  
\- Use \`DOC_SYNC_MATRIX.md\` to determine which tracking surfaces were required.  
\- Non-blocking documentation hygiene may remain as explicit follow-ups.  
\- \`docs/project-files/\*\` is export-only and only required if \`DOC_SYNC_MATRIX.md\` says so.

Inspect first:  
\- \`git status --porcelain=v1 -b\`  
\- \`git diff --stat\`  
\- \`git diff --summary\`  
\- \`docs/agent-workflow/\*\` if present  
\- \`docs/codex/PLAN.md\`  
\- \`docs/codex/STATUS.md\`  
\- \`docs/codex/RUNBOOK.md\`  
\- \`docs/codex/DOC_SYNC_MATRIX.md\`  
\- \`docs/project-files/\` if relevant  
\- relevant changed source files  
\- relevant changed tests

Required procedure:  
1\. Inspect branch and working tree  
2\. Verify required tracking surfaces  
3\. Run the lightest sufficient validation:  
   - narrow checks first  
   - \`bash scripts/check-fast.sh\`  
   - \`bash scripts/check-changed.sh\` if present and relevant  
   - \`bash scripts/check-full.sh\` only if justified  
4\. Prepare commit grouping  
5\. Write proper commit message(s):  
   \`&lt;area/scope&gt;: &lt;imperative summary&gt;\`  
6\. Stage intentionally and commit  
7\. Push safely:  
   - push current branch  
   - if no upstream: \`git push -u origin &lt;branch&gt;\`  
8\. Return a concise final summary

Output:  
A) Target  
B) Artifacts  
C) Verification  
D) Tracking surfaces  
E) Leftovers  
F) Follow-ups  
G) Next suggested prompt

Next suggested prompt rules:  
\- If this push completes normal milestone work:  
  \`No next prompt needed.\`  
\- If this push completes release-ready changes and release-prep already passed:  
  \`09 — Tag&Releaase.md\`