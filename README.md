# Jellyfin Video Converter (Safe MKV Pipeline)

A beginner-friendly, safety-focused Bash script to convert or remux video files into **Jellyfin-friendly MKV containers**.

This project is intentionally conservative: it prioritizes **data safety, clarity, and reproducibility** over speed or cleverness.

---

## Repository Layout

- `scripts/` — main entrypoint `jellyfin_converter.sh`
- `docs/` — user/operator guides and architecture notes
- `examples/` — sample env files and minimal invocations
- `config/` — default encoding and language profiles
- `logs/` — centralized conversion log + processed marker

---

## What This Script Does

At a high level, the script:

- Recursively scans a directory for common video formats
- Converts everything into `.mkv`
  - **Remuxes** when codecs are already compatible
  - **Transcodes** only when necessary
- Preserves:
  - video quality (CRF-based)
  - multi-channel audio
  - embedded subtitles
  - external subtitle files
  - chapters and container metadata
- Filters audio and subtitles to prefer:
  - English (ENG)
  - Italian (ITA)
  - Commentary tracks (always kept)
- Optionally deletes originals **only after successful validation**
- Supports:
  - dry-run mode
  - hardware acceleration (NVENC / QSV / VAAPI)
  - parallel processing via GNU Parallel

The output is designed to work cleanly with **Jellyfin**.

---

## What This Script Does *Not* Do

This script does **not**:

- scrape movie metadata
- rename files based on titles
- manage posters or artwork
- modify Jellyfin libraries directly

Metadata, renaming, and artwork are intentionally handled **afterwards** using a dedicated tool such as **tinyMediaManager**.

This separation keeps the script simple, safe, and debuggable.

---

## Intended Workflow

Recommended pipeline:

```
Raw video files
   ↓
jellyfin_converter.sh
   ↓
Clean MKV files (safe containers)
   ↓
tinyMediaManager
   ↓
Renamed folders + .nfo + artwork
   ↓
Jellyfin library scan
```

Each tool does one job well.

---

## Safety First (Important)

This script is designed for learning and experimentation.

### Key Safety Features

- **DRY_RUN mode**  
  Test everything without touching files.

- **Temporary output files**  
  Final MKVs are only written after validation.

- **ffprobe validation**  
  Outputs are checked before being accepted.

- **Explicit deletion flag**  
  Originals are deleted *only* if `DELETE=1`.

### Beginner Recommendation

Always start with:

```bash
DRY_RUN=1 DELETE=0
```

Do not enable deletion until you are confident and have backups.

---

## Requirements

- `ffmpeg`
- `ffprobe`
- `find`
- Optional: `gnu-parallel` (for faster processing)

Hardware acceleration requires proper drivers and configuration.

---

## Usage (Basic)

```bash
chmod +x scripts/jellyfin_converter.sh

# Dry run (safe)
DRY_RUN=1 DELETE=0 ./scripts/jellyfin_converter.sh /path/to/videos

# Real run, keep originals
DRY_RUN=0 DELETE=0 ./scripts/jellyfin_converter.sh /path/to/videos

# Real run, delete originals after success (advanced)
DELETE=1 ./scripts/jellyfin_converter.sh /path/to/videos
```

- Prepare env vars first: copy `examples/env.dry-run.example` or `examples/env.hw-accel.example` to `.env.local` (or export them inline).
- See the [usage guide with first run checklist](docs/usage.md) before disabling dry-run or enabling deletion.

---

## Environment Variables (Common)

| Variable | Purpose |
|--------|--------|
| `DRY_RUN` | Test without modifying files |
| `DELETE` | Delete originals after success |
| `OVERWRITE` | Replace existing outputs |
| `PARALLEL` | Number of parallel jobs |
| `CODEC` | `h264` or `hevc` |
| `CRF` | Video quality (lower = better) |

See script header for full list.

---

## About This Project

This repository is part of a learning process.

The script was written and improved using:
- experimentation
- reading real code
- incremental changes
- **AI assistance (ChatGPT / Codex)**

AI is used as a **pair-programming and review tool**, not as a replacement for understanding.

---

## Working With AI (Codex)

When improving this script with AI:

- changes should be incremental
- plans should be proposed before edits
- diffs should be reviewed carefully
- safety features should never be removed casually

This repository values **clarity over cleverness**.

---

## Disclaimer

This script manipulates large media files.

- Always keep backups
- Always test with `DRY_RUN=1`
- Always understand what a flag does before using it

Use at your own risk.

---

## License

Personal / educational use.  
Adapt freely for your own workflows.
