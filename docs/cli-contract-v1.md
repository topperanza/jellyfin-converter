# CLI Contract v1

This document defines the stable Jellyfin Converter v1 command contract.

## Entrypoints
- `./run.sh` (preferred local entrypoint)
- `./scripts/jellyfin_converter.sh` (canonical implementation)
- Installed binary: `jellyfin-converter`

## Stable flags
- `--help`
- `--version`
- `--self-check`
- `--dry-run` / `--no-dry-run`
- `--preflight`, `--preflight=info`, `--preflight=strict`
- `--profile <jellyfin-1080p|jellyfin-720p|archive|auto>`
- `--force-transcode` / `--no-force-transcode`
- `--max-video-bitrate-kbps <N>`
- `--max-filesize-mb <N>`
- `--target-height <N>`
- `--allow-und-audio`
- `--print-subtitles`

No v1 flag removals are allowed without a major version bump.

## Stable environment variables
- Processing policy: `PROFILE`, `FORCE_TRANSCODE`, `MAX_VIDEO_BITRATE_KBPS`, `MAX_FILESIZE_MB`, `REMUX_MAX_GB`, `TARGET_HEIGHT`
- Encoding/runtime: `CRF`, `PRESET`, `CODEC`, `HW_ACCEL`, `PARALLEL`
- Safety controls: `DRY_RUN`, `DELETE`, `DELETE_SIDECARS`, `OVERWRITE`, `SKIP_DELETE_CONFIRM`, `ALLOW_UND_AUDIO`
- I/O: `OUTROOT`, `LOG_DIR`, `INCLUDE_HIDDEN`, `PRINT_SUBTITLES`

## Exit code contract
- `0`: success
- `1`: usage/config/dependency error
- `2`: user-cancelled destructive operation
- `3`: filesystem permission/output/log path error
- `4`: strict preflight validation failed

## Stability policy
- Stable: commands, flags, environment variables, exit code mapping, installer entrypoint, release asset names.
- Experimental: none currently exposed by default.

