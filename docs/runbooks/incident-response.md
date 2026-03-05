# Incident Runbook

## Conversion failures
1. Re-run with `DRY_RUN=1` and `--print-subtitles` for a single sample file.
2. Capture `logs/conversion.log` and the failing ffmpeg command output.
3. Classify failure:
   - dependency/runtime (`ffmpeg`/`ffprobe` missing)
   - media-specific parsing or transcode failure
   - filesystem/output path permissions
4. For release-impacting regressions, block release and open a hotfix branch.

## Corrupted or invalid output
1. Stop destructive runs (`DELETE=0`).
2. Validate suspect file with `ffprobe -v error <file>`.
3. Remove invalid output and rerun with dry-run first.
4. If reproducible on CI, treat as release blocker.

## Rollback
1. Keep previous release install directory (installer uses versioned paths).
2. Repoint symlink to prior versioned `run.sh` when needed.
3. Publish patch release notes with rollback reason and mitigation.
