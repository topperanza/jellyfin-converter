## Prioritized Roadmap & Timeline
1) Fix ffprobe audio/subtitle parsing to avoid language loss — **1 day** — Risk: silent misclassification; Mitigation: add fixtures and CI coverage.
2) Prune output and hidden paths from scans to stop recursive reprocessing — **0.5 day** — Risk: accidental deletes; Mitigation: add find-prune tests.
3) Add ffmpeg/ffprobe install steps in CI (Ubuntu/macOS binary fetch) — **0.5 day** — Risk: CI red without binaries; Mitigation: cache/verify binaries.
4) Sidecar deletion safety toggle (`DELETE_SIDECARS`) and uniqueness check — **1 day** — Risk: shared sidecars removed; Mitigation: require explicit opt-in.
5) Preserve and surface subtitle default/commentary metadata — **0.5 day** — Risk: playback defaults lost; Mitigation: metadata tests for default/comm tracks.
6) Deterministic subtitle source tie-break (prefer external only when configured) — **0.5 day** — Risk: locale-dependent ordering; Mitigation: explicit score field + tests.
7) Bash 3.2 compatibility gate in CI — **0.5 day** — Risk: regressions in Bash<4 paths; Mitigation: dedicated job using system `/bin/bash`.
8) Broaden external subtitle support when bitmap retention is enabled (`.sup`, `.sub/.idx`) — **1 day** — Risk: unwanted imports; Mitigation: guard behind `KEEP_BITMAP_SUBS`.
9) Batch ffprobe queries to cut subprocess overhead on multi-track files — **1 day** — Risk: parsing drift; Mitigation: lock JSON schema and add perf sanity test.
10) Governance: issue/PR templates and branch protection guidance — **0.5 day** — Risk: inconsistent releases; Mitigation: document release/tag policy.

### Suggested Release Cadence
- Patch cadence: weekly for v1.0.x until cooldown ends and CI stabilizes.
- Minor cadence: monthly for v1.1 once hardening items 1–5 land and remain green for two weeks.
