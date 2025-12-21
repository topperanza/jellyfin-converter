# User & Operator Guide

## Running the converter

```bash
DRY_RUN=1 DELETE=0 ./scripts/jellyfin_converter.sh /path/to/videos
```

Key notes:
- The script lives in `scripts/jellyfin_converter.sh`.
- Logs default to `logs/` at the project root.
- Converted files land in `converted/` inside the scanned directory.

## Logs and artifacts
- Conversion log: `logs/conversion.log`
- Processed marker: `logs/.processed`
- Keep `logs/` writable; override the location with `LOG_DIR=/custom/path`.

## Recovery & safety
- Start with `DRY_RUN=1` until confident.
- Originals delete only when `DELETE=1` **and** the output validates.
- Set `SKIP_DELETE_CONFIRM=1` only for fully automated pipelines.
