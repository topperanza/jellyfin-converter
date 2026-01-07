## 48–72h Post-Release Checklist (v1.0.0)
- Monitor CI on `main` and the `v1.0.0` tag for red/flake signals; rerun failing jobs before triage.
- Centralize issue intake using a consistent repro template (command, environment, logs, sample file hints).
- Safe hotfix protocol: branch from `main`, add targeted fix + test, cherry-pick to `v1.0.x`, tag `v1.0.x+1` after green CI.
- Backlog regression tests for any issues reported during cooldown; prioritize subtitle selection, deletion safety, and scan exclusions.
- Doc drift check: ensure README, subtitle policy, and release notes still match observed behavior.
