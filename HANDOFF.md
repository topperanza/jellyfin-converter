# Handoff

## Status

The forced-subtitle fallback regression is fixed and verified locally on `fix/ffprobe-forced-subtitle-fallback`. The branch was created from a clean `main` at `a754a4d1605797bb2fbfe7da4f0d5e06c0f476e7`, which matched `origin/main` in a live `git ls-remote origin refs/heads/main` check.

## Files changed

- `scripts/lib/media_filters.sh` reuses the named flat-field parser for subtitle fallback and reads the absolute stream index from ffprobe.
- `scripts/jellyfin_converter.sh` loads the probe helpers through the media filters module.
- `tests/suite_ffmpeg.sh` generates a synthetic Matroska fixture in a temporary directory and tests both fallback entry paths with real ffprobe.
- `tests/test_internal_subtitles.sh`, `tests/test_phase4_mapping.sh`, `tests/test_subs_probe_parser.sh`, `tests/test_subtitle_config.sh`, and `tests/test_subtitle_mapping.sh` mock the named ffprobe output.
- `HANDOFF.md` and `docs/codex/STATUS.md` record the local evidence.

## Reproduction and verification

On macOS x86_64 with Bash 3.2.57 and FFmpeg/ffprobe 8.0.1, the fixture contains video at index 0, normal English SubRip at index 1, forced Russian SubRip at index 2, and normal Russian SubRip at index 3.

- **FAIL before the fix** — `./tests/run.sh tests/suite_ffmpeg.sh` with the new test and the old runtime. ffprobe reported `disposition.forced=1` for index 2. The fallback returned `2|subrip|0|1|0|rus`, placing disposition values in the tag columns, and the plan omitted the forced track.
- **PASS after the fix** — the fallback returns `2|subrip|rus||0|1|0`. Both empty and video-only batched input produce `int|1|eng|0|subrip|0` followed by `int|2|rus|1|subrip|0`. Index 3 is excluded.
- **PASS** — a real `./run.sh` conversion with a wrapper restricting only the initial `-show_streams` probe to video produced a 1.000-second Matroska file. ffmpeg mapped input 0:0 to output 0:0 (MPEG-4 to H.264), input 0:1 to output 0:1 (English SubRip copy), and input 0:2 to output 0:2 (Russian SubRip copy). Independent ffprobe inspection confirmed the language tags, order, and forced flag on output index 2.
- **PASS** — `./tests/run.sh tests/suite_selection.sh tests/suite_ffmpeg.sh tests/test_subs_probe_parser.sh tests/test_subtitle_mapping.sh tests/test_phase4_mapping.sh tests/test_internal_subtitles.sh tests/test_subtitle_config.sh tests/test_deterministic_subs.sh` (8 entries, 0 failures).
- **PASS** — `bash scripts/check-fast.sh`, `bash scripts/check-changed.sh main`, and `bash scripts/check-full.sh` (including `./tests/run.sh`, 4 suites, 0 failures).
- **PASS** — `./tests/run.sh 'tests/suite_*.sh tests/test_*.sh'` (30 entries, 0 failures).
- **PASS** — `find . -type f -name '*.sh' -not -path './.git/*' -not -path './.venv/*' -print0 | xargs -0 shellcheck -x -S error`.
- **PASS** — `bash scripts/codex/check-workflow-conformance.sh` and `git diff --check`.
- **PASS** — `KEEP_BITMAP_SUBS=1 bash -c 'source tests/test_internal_subtitles.sh; test_internal_logic'` explicitly exercised the legacy test body and verified `-map 0:3` with `-disposition:s:1 forced`.
- **FAIL on baseline and task branch** — the same legacy invocation with the default bitmap policy expects a PGS track that the policy filters out. The default harness loads the script without calling that function.
- **SKIP** — none reported in the local harness. The real-tool test skips when either binary is absent.
- **NOT RUN** — remote CI and a cross-platform FFmpeg version matrix. The real-tool fixture covers Matroska and SubRip.

## Publication handoff

The verified topic branch is ready for review. The branch has no upstream. The repository's [07A commit/push prompt](docs/codex/usage-prompts/07A-commit-push.md) specifies this command for an authorized publication.

```bash
git push -u origin fix/ffprobe-forced-subtitle-fallback
```
