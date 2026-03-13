Implementation task.

Repo:  
\[REPO_NAME\]

Goal:  
Initialize this repository with a hardened, repo-agnostic Codex workflow baseline that is minimal, deterministic, reviewable, and ready for both normal milestone work and later downstream maintenance.

This is a repository-creation / Day-0 scaffolding task.  
Inspect first.  
Infer the stack and conventions from the repository itself.  
Then create or improve the smallest robust Codex environment and control plane for this specific codebase.

Primary objectives:  
1\. Create or improve \[REPO_ROOT\]/.codex/config.toml  
2\. Create or improve \[REPO_ROOT\]/scripts/codex/setup.sh  
3\. Create or improve \[REPO_ROOT\]/scripts/codex/maintenance.sh  
4\. Create or improve \[REPO_ROOT\]/scripts/codex/check-workflow-conformance.sh  
5\. Create or improve \[REPO_ROOT\]/AGENTS.md  
6\. Add stable validation entrypoints Codex can call without guessing  
7\. Create long-task / milestone scaffolding under \[CODEX_DOCS_DIR\]  
8\. Create a canonical prompt pack under \[PROMPTS_DIR\]  
9\. Create release-flow prompts in the prompt pack  
10\. Create a small curated docs/project-files export surface  
11\. Keep everything minimal, repo-native, deterministic, and reviewable

Operating rules:  
\- Inspect before editing.  
\- Infer the stack, package manager, test/build/lint commands, repo layout, and existing workflow conventions from the repository itself.  
\- Reuse existing commands, scripts, folders, and standards whenever possible.  
\- Do not do broad refactors.  
\- Do not add speculative infrastructure.  
\- Do not add secrets.  
\- Do not break local workflows.  
\- Do not add heavy tooling unless the repository already uses it or it is clearly justified by the existing stack.  
\- Prefer deterministic setup and repeatable validation.  
\- Ask questions only if truly blocked; otherwise state one short assumption and proceed.

Stable core to establish from Day 0:  
\- source-of-truth hierarchy:  
  1) code/tests/runtime/config  
  2) docs/codex/\*  
  3) README / architecture / release docs  
  4) docs/project-files/\*  
\- docs/project-files is downstream/export-only by default  
\- milestone gate is contract-scoped  
\- blocker-closure is narrow  
\- full repo audit is recovery-only  
\- canonical validation order:  
  1) milestone-specific validation  
  2) bash scripts/check-fast.sh  
  3) bash scripts/check-changed.sh if relevant  
  4) bash scripts/check-full.sh if justified  
\- local vs cloud routing model remains intact  
\- automations remain app-managed, not repo-managed

Path discovery / creation rules:  
1\. Set \[CODEX_DOCS_DIR\]:  
   - Prefer \[REPO_ROOT\]/docs/codex  
   - If a different existing Codex docs location is clearly established, reuse it  
   - Otherwise create \[REPO_ROOT\]/docs/codex  
2\. Set \[PROMPTS_DIR\]:  
   - Use \[REPO_ROOT\]/docs/codex/usage-prompts  
   - If it does not exist, create \[REPO_ROOT\]/docs/codex/usage-prompts  
3\. Set \[PROJECT_FILES_DIR\]:  
   - Use \[REPO_ROOT\]/docs/project-files

Context-awareness requirements:  
\- Detect whether this repository is primarily:  
  - Python  
  - JS/TS  
  - Rust  
  - Go  
  - Java/Kotlin  
  - C/C++  
  - mixed-stack  
  - CLI tool  
  - library  
  - service/backend  
  - desktop app  
  - GUI app  
  - media pipeline  
  - data-processing pipeline  
  - monorepo  
  - docs-first repo  
\- Adapt setup, maintenance, validation, AGENTS.md, \[CODEX_DOCS_DIR\], \[PROMPTS_DIR\], and \[PROJECT_FILES_DIR\] to that detected context.  
\- If monorepo, scope work to the relevant app/package if the repository structure clearly supports that, and avoid forcing a one-size-fits-all root workflow.  
\- If the repository already contains Codex files, patch and improve them instead of replacing useful work.  
\- If an item in this prompt is not appropriate for the repository, skip it and explain why in the summary.

Required deliverables:  
\- \[REPO_ROOT\]/.codex/config.toml  
\- \[REPO_ROOT\]/scripts/codex/setup.sh  
\- \[REPO_ROOT\]/scripts/codex/maintenance.sh  
\- \[REPO_ROOT\]/scripts/codex/check-workflow-conformance.sh  
\- \[REPO_ROOT\]/AGENTS.md  
\- \[REPO_ROOT\]/scripts/check-fast.sh  
\- \[REPO_ROOT\]/scripts/check-full.sh  
\- \[CODEX_DOCS_DIR\]/PLAN.md  
\- \[CODEX_DOCS_DIR\]/STATUS.md  
\- \[CODEX_DOCS_DIR\]/RUNBOOK.md  
\- \[CODEX_DOCS_DIR\]/REPO_OVERVIEW.md  
\- \[CODEX_DOCS_DIR\]/DOC_SYNC_MATRIX.md  
\- \[CODEX_DOCS_DIR\]/CLOUD_ENV_CHECKLIST.md  
\- \[CODEX_DOCS_DIR\]/WORKFLOW_VERSION.md  
\- \[PROJECT_FILES_DIR\]/  
\- \[PROMPTS_DIR\]/0000-README-usage-order.md  
\- \[PROMPTS_DIR\]/08-release-prep.md  
\- \[PROMPTS_DIR\]/09-tag-and-release.md

Optional when justified:  
\- \[REPO_ROOT\]/scripts/check-changed.sh  
\- nested AGENTS.md in specialized subtrees  
\- CHANGELOG.md  
\- CONTRIBUTING.md if clearly useful

Validation requirements:  
\- Verify all new scripts are executable  
\- Run bash \[REPO_ROOT\]/scripts/codex/check-workflow-conformance.sh  
\- Run bash \[REPO_ROOT\]/scripts/check-fast.sh  
\- Run bash \[REPO_ROOT\]/scripts/check-full.sh if feasible  
\- If check-full is too heavy, run the narrowest meaningful substitute and say so explicitly  
\- Verify all referenced paths exist  
\- Verify \[PROMPTS_DIR\] exists and contains the release prompts  
\- State exactly what was and was not validated

Output format:  
\- Return unified diffs only  
\- After the diffs, provide:  
  1) very short summary of what was added/changed  
  2) exact validation commands run  
  3) assumptions made  
  4) items intentionally skipped and why  
  5) Next suggested prompt

Next suggested prompt rules:  
\- If repo initialization succeeded and milestone work can begin:  
  \`01-next-milestone-planner.md\`  
\- If setup/control-plane blockers remain:  
  \`04-blocker-patch.md\`  
\- If the repo is not ready for either:  
  \`No next prompt needed.\`
