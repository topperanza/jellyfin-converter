\# 00 — Repo starter.md

Implementation task.

Repo:  
\[REPO_NAME\]

Goal:  
Initialize this repository with a hardened, minimal, deterministic, dual-agent-ready workflow baseline that is reviewable, repo-native, and safe for both normal milestone work and later maintenance.

This is a repository-creation / Day-0 scaffolding task.  
Inspect first.  
Infer the stack and conventions from the repository itself.  
Then create or improve the smallest robust control plane for this specific codebase.

Primary objectives:  
1\. Create or improve \`\[REPO_ROOT\]/.codex/config.toml\`  
2\. Create or improve \`\[REPO_ROOT\]/scripts/codex/setup.sh\`  
3\. Create or improve \`\[REPO_ROOT\]/scripts/codex/maintenance.sh\`  
4\. Create or improve \`\[REPO_ROOT\]/scripts/codex/check-workflow-conformance.sh\`  
5\. Create or improve \`\[REPO_ROOT\]/AGENTS.md\` as a thin Codex adapter  
6\. Create or improve \`\[REPO_ROOT\]/CLAUDE.md\` as a thin Claude adapter if Claude Code is intended for this repo  
7\. Create a canonical shared workflow layer under \`\[REPO_ROOT\]/docs/agent-workflow/\` when justified  
8\. Create stable validation entrypoints the agent can call without guessing  
9\. Create long-task / milestone scaffolding under \`\[CODEX_DOCS_DIR\]\`  
10\. Create a canonical Codex prompt pack under \`\[PROMPTS_DIR\]\`  
11\. Create a small curated \`docs/project-files/\` export surface  
12\. Keep everything minimal, repo-native, deterministic, and reviewable

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
  1. code/tests/runtime/config  
  2. \`docs/agent-workflow/\*\` if present  
  3. \`docs/codex/\*\`  
  4. README / architecture / release docs  
  5. \`docs/project-files/\*\`  
\- \`AGENTS.md\` and \`CLAUDE.md\` are adapters, not the primary source of truth  
\- \`docs/project-files/\*\` is downstream/export-only by default  
\- milestone gate is contract-scoped  
\- blocker-closure is narrow  
\- full repo audit is recovery-only  
\- canonical validation order:  
  1. milestone-specific validation  
  2. \`bash scripts/check-fast.sh\`  
  3. \`bash scripts/check-changed.sh\` if present and relevant  
  4. \`bash scripts/check-full.sh\` only if justified  
\- local vs remote routing model remains intact  
\- automations remain app-managed, not repo-managed

Path discovery / creation rules:  
1\. Set \`\[CODEX_DOCS_DIR\]\`:  
   - Prefer \`\[REPO_ROOT\]/docs/codex\`  
   - If a different existing Codex docs location is clearly established, reuse it  
   - Otherwise create \`\[REPO_ROOT\]/docs/codex\`  
2\. Set \`\[PROMPTS_DIR\]\`:  
   - Prefer an existing directory in this order:  
     a. \`\[REPO_ROOT\]/docs/codex/usage-prompts\`  
     b. \`\[REPO_ROOT\]/prompts/usage\`  
     c. \`\[REPO_ROOT\]/docs/prompts/usage\`  
   - If none exists, create \`\[REPO_ROOT\]/docs/codex/usage-prompts\`  
3\. Set \`\[PROJECT_FILES_DIR\]\`:  
   - Use \`\[REPO_ROOT\]/docs/project-files\`  
4\. Set \`\[SHARED_WORKFLOW_DIR\]\`:  
   - Prefer \`\[REPO_ROOT\]/docs/agent-workflow\`  
   - If no shared workflow layer exists and dual-agent use is expected, create it

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
\- Adapt setup, maintenance, validation, adapters, docs paths, and prompt-pack creation to that detected context.  
\- If monorepo, scope work to the relevant app/package if the repository structure clearly supports that, and avoid forcing a one-size-fits-all root workflow.  
\- If the repository already contains Codex files, patch and improve them instead of replacing useful work.  
\- If Claude-facing files already exist, patch and improve them instead of replacing useful work.  
\- If an item in this prompt is not appropriate for the repository, skip it and explain why in the summary.

Required deliverables:  
\- \`\[REPO_ROOT\]/.codex/config.toml\`  
\- \`\[REPO_ROOT\]/scripts/codex/setup.sh\`  
\- \`\[REPO_ROOT\]/scripts/codex/maintenance.sh\`  
\- \`\[REPO_ROOT\]/scripts/codex/check-workflow-conformance.sh\`  
\- \`\[REPO_ROOT\]/AGENTS.md\`  
\- \`\[REPO_ROOT\]/scripts/check-fast.sh\`  
\- \`\[REPO_ROOT\]/scripts/check-full.sh\`  
\- \`\[CODEX_DOCS_DIR\]/PLAN.md\`  
\- \`\[CODEX_DOCS_DIR\]/STATUS.md\`  
\- \`\[CODEX_DOCS_DIR\]/RUNBOOK.md\`  
\- \`\[CODEX_DOCS_DIR\]/REPO_OVERVIEW.md\`  
\- \`\[CODEX_DOCS_DIR\]/DOC_SYNC_MATRIX.md\`  
\- \`\[CODEX_DOCS_DIR\]/CLOUD_ENV_CHECKLIST.md\`  
\- \`\[CODEX_DOCS_DIR\]/WORKFLOW_VERSION.md\`  
\- \`\[PROJECT_FILES_DIR\]/\`  
\- \`\[PROMPTS_DIR\]/0000 — README _ usage order.md\`  
\- \`\[PROMPTS_DIR\]/08 — Release prep.md\`  
\- \`\[PROMPTS_DIR\]/09 — Tag&Releaase.md\`

Required when dual-agent use is expected:  
\- \`\[REPO_ROOT\]/CLAUDE.md\`  
\- \`\[SHARED_WORKFLOW_DIR\]/README.md\`  
\- \`\[SHARED_WORKFLOW_DIR\]/SOURCE_OF_TRUTH.md\`  
\- \`\[SHARED_WORKFLOW_DIR\]/WORKFLOW_ORDER.md\`  
\- \`\[SHARED_WORKFLOW_DIR\]/NON_NEGOTIABLES.md\`

Optional when justified:  
\- \`\[REPO_ROOT\]/scripts/check-changed.sh\`  
\- nested \`AGENTS.md\` in specialized subtrees  
\- \`.claude/rules/\*\`  
\- \`agent-skills/\*\`  
\- \`CHANGELOG.md\`  
\- \`CONTRIBUTING.md\` if clearly useful

Validation requirements:  
\- Verify all new scripts are executable  
\- Run \`bash \[REPO_ROOT\]/scripts/codex/check-workflow-conformance.sh\` if present  
\- Run \`bash \[REPO_ROOT\]/scripts/check-fast.sh\`  
\- Run \`bash \[REPO_ROOT\]/scripts/check-full.sh\` if feasible  
\- If \`check-full\` is too heavy, run the narrowest meaningful substitute and say so explicitly  
\- Verify all referenced paths exist  
\- Verify \`\[PROMPTS_DIR\]\` exists and contains the release prompts  
\- Verify adapter files point at canonical shared docs if those docs exist  
\- State exactly what was and was not validated

Output format:  
\- Return unified diffs only  
\- After the diffs, provide:  
  1. very short summary of what was added/changed  
  2. exact validation commands run  
  3. assumptions made  
  4. items intentionally skipped and why  
  5. Next suggested prompt

Next suggested prompt rules:  
\- If repo initialization succeeded and milestone work can begin:  
  \`01 — Next milestone planner.md\`  
\- If setup/control-plane blockers remain:  
  \`04 — Blocker patch.md\`  
\- If the repo is not ready for either:  
  \`No next prompt needed.\`