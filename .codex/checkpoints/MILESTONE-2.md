# Milestone 2: Subtitle/discovery safety coverage expansion
- Date: 2026-03-10
- Goal: add focused tests around highest-risk media-selection edges before feature work.
- Completion criteria: new tests cover identified edge cases and pass consistently on Bash 3.2-compatible shell.

## Gap analysis (explicit map)
### Discovery suite (`tests/suite_discovery.sh`)
- Already covered before this milestone:
  - basic eng/ita/rus sidecar parsing
  - dot-token parsing (`en.sdh`, commentary)
  - complex token parsing with parentheses/brackets
  - strict-anchoring negative case (`Movie - Sequel.srt`)
  - bitmap sidecar keep/drop policy (`sup`, `idx+.sub` pairing)
- Missing before this milestone:
  - forced sidecar without language token should remain selectable as `und|forced`
  - prefix-collision guard (`MovieX.eng.srt` must not match `Movie.mkv`)
- Added now:
  - `test_discovery_strict_anchoring` assertions for:
    - `Movie.forced.srt|und|1|0|0|srt` (positive)
    - `MovieX.eng.srt` exclusion (negative)

### Selection suite (`tests/suite_selection.sh`)
- Already covered before this milestone:
  - basic eng/ita selection
  - multi-language pruning to wanted langs
  - forced retention across languages
  - commentary always-kept behavior
- Missing before this milestone:
  - default-vs-nondefault winner for same language/slot
  - text-vs-bitmap winner for same language/slot
  - deterministic fallback when no wanted/forced subtitles are present
- Added now:
  - `test_selection_prefers_default_normal_track`
  - `test_selection_prefers_text_over_bitmap_for_same_slot`
  - `test_selection_fallback_when_no_wanted_or_forced`

## Files changed
- `tests/suite_discovery.sh`
- `tests/suite_selection.sh`
- `tests/fixtures/discovery/strict_anchoring/Movie.forced.srt`
- `tests/fixtures/discovery/strict_anchoring/MovieX.eng.srt`
- `tests/fixtures/eng_default_vs_nondefault.txt`
- `tests/fixtures/eng_text_vs_bitmap.txt`
- `tests/fixtures/fallback_non_wanted.txt`
- `.codex/checkpoints/MILESTONE-2.md`
- `docs/codex/STATUS.md`

## Commands run
- `bash scripts/check-fast.sh`
- `bash scripts/check-changed.sh HEAD~1`
- `bash scripts/check-full.sh`

## Results
- Pass: `bash scripts/check-fast.sh`
- Pass: `bash scripts/check-changed.sh HEAD~1`
- Pass: `bash scripts/check-full.sh`
- MILESTONE-2 completion criteria met with focused additions only in discovery/selection suites.

## Risks / next step
- Risk: subtitle selection behavior spans both `select_internal_subtitles` and `build_subtitle_plan`; policy drift between them remains possible without dual-layer assertions.
- Next step: execute MILESTONE-3 (operator-facing runbook + resume reliability) with doc-only scope and checkpoint evidence.
