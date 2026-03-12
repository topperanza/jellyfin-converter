\# Codex Prompt Pack v1.2.0 — Usage Order

This folder contains the canonical Codex workflow prompts for this repository.

\## Core rules

\- Treat repository contents as primary truth.  
\- Source-of-truth order:  
  1. code / tests / runtime behavior / schemas / config  
  2. docs/codex/\*  
  3. README / architecture / release docs  
  4. docs/project-files/\*  
\- \`docs/project-files/\` is a downstream sync/export surface, not the primary source of truth for milestone decisions.  
\- Milestone gate is contract-scoped.  
\- Blocker-closure check is narrow.  
\- Full repo audit is recovery-only.  
\- Canonical validation order:  
  1. milestone-specific validation  
  2. \`bash scripts/check-fast.sh\`  
  3. \`bash scripts/check-changed.sh\` if present and relevant  
  4. \`bash scripts/check-full.sh\` if justified  
\- Automations are app-managed, not repo-managed.

\## Standard milestone flow

1\. \`01-next-milestone-planner.md\`  
2\. \`02-milestone-implementation.md\`  
3\. \`03-milestone-gate.md\`

If blocked:  
4\. \`04-blocker-patch.md\`  
5\. \`05-blocker-closure-check.md\`

If local verification is needed:  
6\. \`06-final-local-verification.md\`

Then:  
7\. \`07-commit-and-push-after-pass.md\`

\## Release flow

Use only after milestone work is complete and committed state is ready.

1\. \`08-release-prep.md\`  
2\. \`07-commit-and-push-after-pass.md\` if final release-prep fixes were made  
3\. \`09-tag-and-release.md\`

Release order is always:  
\- release-prep review  
\- final commit/push  
\- tag + release

\## Recovery flow

If repository state is unclear, drifted, or the control plane is untrustworthy:

1\. \`000-full-repo-audit-recovery-only.md\`

Then return to the standard flow.

\## Day-0 / initialization flow

For a new repo or a repo that does not yet have a proper Codex control plane:

1\. \`00-repo-starter.md\`

\## Cloud vs Local guidance

Use Codex Cloud for:  
\- planning  
\- milestone implementation  
\- milestone gate  
\- blocker-closure checks  
\- release-prep review  
\- repo audits  
\- control-plane doc work  
\- prompt-pack maintenance

Use Codex Local for:  
\- environment-sensitive fixes  
\- local verification  
\- setup/maintenance validation  
\- commit/push  
\- tag/release

\## Anti-loop rule

Do not use:  
\- full repo audit as a normal milestone gate  
\- blocker-closure as a broad repo re-review  
\- release-prep as a general cleanup prompt

Keep scope tight.
