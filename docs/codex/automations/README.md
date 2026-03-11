# Codex Automation Prompt Templates

These files are **prompt templates and operator setup notes** for creating automations in the Codex app.

## Important model
- Automations are created and scheduled in the Codex app.
- This repository does **not** auto-load schedules from markdown files.
- Use these templates as copy/paste starting points, then configure cadence and notifications in the app.

## Recommended cadence
- Weekly: milestone drift audit
- Weekly: project-files sync audit
- Before release or release-candidate handoff: pre-release truth audit

## Skill invocation
Use explicit skill calls in prompt bodies:
- `$mtt-repo-milestone-review`
- `$mtt-project-files-sync-audit`

(These skills are installed in `.agents/skills/` and require explicit invocation.)

## Operator setup flow
1. Open Codex app automations.
2. Create automation from relevant template in this folder.
3. Paste prompt body and set schedule.
4. Manually test the prompt once before enabling schedule.
5. Confirm output routes to your review process.

## Git repository execution note
For git repos, Codex app automations run in background worktrees. Review generated changes before merge/push.
