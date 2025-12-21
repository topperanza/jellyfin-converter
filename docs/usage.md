# Usage & First Run Checklist

## Preparing environment variables

- Copy one of the sample env files to a private local override:
  - `cp examples/env.dry-run.example .env.local` for the safest preview
  - `cp examples/env.hw-accel.example .env.local` when testing GPU encoders
- Alternatively, export variables inline before running:

```bash
export $(cat .env.local | xargs)   # or export DRY_RUN=1 DELETE=0 ...
```

## Running

```bash
chmod +x scripts/jellyfin_converter.sh
./scripts/jellyfin_converter.sh /path/to/videos
```

Environment variables from `.env.local` or your shell override script defaults (e.g., `DRY_RUN`, `DELETE`, `HW_ACCEL`, `CODEC`, `PARALLEL`).

## First run checklist

1. Install `ffmpeg` and `ffprobe`; ensure they’re on `PATH`.
2. Start with `DRY_RUN=1 DELETE=0` (use `examples/env.dry-run.example`).
3. Point to a test folder with small videos; confirm `logs/conversion.log` is writable.
4. Review console output to verify detected hardware encoder (if any) before disabling dry-run or enabling deletion.
