# Jellyfin Converter (alpha)

Converts common video files into Jellyfin-friendly MKV containers with conservative defaults and safety checks.
Current version: see `VERSION` or run `./run.sh --version`.

## Requirements
- macOS (tested with recent releases)
- `ffmpeg`, `ffprobe`, `find`, `df` on `PATH`
- Optional: `gnu-parallel` for faster runs

## How to run
```bash
git clone <repo>
cd jellyfin-converter
chmod +x run.sh
./run.sh --dry-run /path/to/videos
```
Dry-run is **on by default**. Outputs land in `./converted`.

## Real conversion (keep originals)
```bash
DRY_RUN=0 DELETE=0 ./run.sh /path/to/videos
```

## Enable deletion (advanced)
```bash
DRY_RUN=0 DELETE=1 ./run.sh /path/to/videos
```

## Help, version, and dry-run confirmation
```bash
./run.sh --help
./run.sh --version
```

## Reporting bugs
Open an issue on GitHub with:
- macOS version
- `./run.sh --version` output
- Command used and console logs (with `DRY_RUN=1` preferred)
