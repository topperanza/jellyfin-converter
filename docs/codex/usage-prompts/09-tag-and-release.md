Implementation task.

Repo:  
\[REPO_NAME\]

Goal:  
Create the final release tag and GitHub release for the already-approved, already-committed release state.

This task starts only after:  
\- release-prep review passed  
\- final release changes are already committed  
\- final release commit is already pushed to the intended branch

This is a tag-and-release task only.  
Do NOT make additional product/code/docs changes unless a small release-metadata correction is strictly required.  
Do NOT reopen release-prep review.  
Do NOT perform opportunistic cleanup.

Primary objective:  
1\. verify the repo is in a clean, releasable state  
2\. create the correct release tag  
3\. push the tag if needed  
4\. create the GitHub release  
5\. verify that the tag and release now exist remotely

Hard rules:  
\- Use the existing repo remote configuration; do not switch remotes from SSH to HTTPS.  
\- Do NOT create a release from a dirty working tree.  
\- Do NOT create a tag if version/changelog/release metadata are clearly inconsistent.  
\- Do NOT silently choose a version/tag if the intended one is already stated in repo docs; derive it from repo truth.  
\- Prefer annotated tags.  
\- Keep release notes concise and grounded in repo state.  
\- Do NOT modify workflow semantics, prompts, or control-plane content as part of this task.  
\- If a blocker exists, stop and report it instead of improvising.

Source of truth for release metadata:  
1\. code/tests/runtime/config  
2\. docs/codex/WORKFLOW_VERSION.md  
3\. CHANGELOG.md  
4\. README / release docs if relevant

Required method:  
A. Inspect release state  
B. Verify no blocking issues  
C. Create tag  
D. Push tag  
E. Create GitHub release  
F. Verify remote release state

Check at minimum:  
\- git status --short  
\- git branch --show-current  
\- git log --oneline -n 5  
\- git tag --list  
\- git ls-remote --tags origin  
\- gh release list  
\- gh release view \[TAG\] after creation  
\- docs/codex/WORKFLOW_VERSION.md  
\- CHANGELOG.md if present

Success criteria:  
\- release metadata is coherent  
\- annotated tag exists at the intended commit  
\- tag is pushed to remote  
\- GitHub release exists for that tag  
\- release title/notes match repo truth  
\- no unrelated repo changes were introduced

Output format (strict):  
1\. Release intent  
2\. Pre-release checks  
3\. Actions taken  
4\. Verification  
5\. Final status

Final status values:  
\- TAG AND RELEASE CREATED SUCCESSFULLY  
\- BLOCKED