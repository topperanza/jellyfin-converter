# User & Operator Guide

## Running the converter

```bash
DRY_RUN=1 DELETE=0 ./scripts/jellyfin_converter.sh /path/to/videos
```

Key notes:
- The script lives in `scripts/jellyfin_converter.sh`.
- Logs default to `logs/` at the project root.
- Converted files land in `converted/` inside the scanned directory.
- Use `--self-check` to validate dependencies and writable paths without scanning media.

## Deterministic output contract
- Subtitle/audio selection is deterministic for identical inputs and configuration.
- The same source path is tracked in `logs/.processed` after successful completion.
- `.processed` is append-only and lock-protected via `logs/.processed.lock` for parallel safety.
- Output files are written under `OUTROOT` preserving relative source structure.
- Existing outputs are skipped unless `OVERWRITE=1`.

## Scanning rules
- **Output exclusion**: The `converted/` folder (or configured `OUTROOT`) is automatically excluded from scanning if it lies within the scan path.
- **Hidden exclusion**: Hidden files/folders (starting with `.`) and common generated directories are skipped by default.
- **Override**: Set `INCLUDE_HIDDEN=1` to force scanning of hidden paths.

## Logs and artifacts
- Conversion log: `logs/conversion.log`
- Processed marker: `logs/.processed`
- Keep `logs/` writable; override the location with `LOG_DIR=/custom/path`.
- Each log record includes timestamp, method (`remux` or `transcode`), source, output, and size savings.

## Recovery & safety
- Start with `DRY_RUN=1` until confident.
- Originals delete only when `DELETE=1` **and** the output validates.
- Set `SKIP_DELETE_CONFIRM=1` only for fully automated pipelines.
- For interrupted runs, keep `DELETE=0`, rerun, and rely on `.processed` to skip completed sources.
