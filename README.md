# Jellyfin Converter (alpha)

![CI](https://github.com/mt/jellyfin-converter/actions/workflows/ci.yml/badge.svg)

Converts common video files into Jellyfin-friendly MKV containers with conservative defaults and safety checks.
Current version: see `VERSION` or run `./run.sh --version`.

## Documentation

- [User Guide](docs/user-guide.md)
- [Subtitle Policy & Configuration](docs/subtitles.md)

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

## Subtitles
The converter implements a smart subtitle selection strategy:
- **Internal & External**: Merges internal subtitles with external sidecar files.
- **Sidecar Discovery**: Automatically finds `.srt` files matching the video filename (e.g., `Movie.mkv` matches `Movie.en.srt`).
- **Preferences**: Prioritizes English and Italian, forced subtitles, and text-based formats (SRT) over bitmaps (PGS/DVD).
- **See [docs/subtitles.md](docs/subtitles.md)** for naming rules and detailed logic.

## Debugging
- **--print-subtitles**: Run with this flag to see exactly which subtitles (internal and external) are detected and how they will be mapped, without performing any conversion.
  ```bash
  ./run.sh --print-subtitles /path/to/video.mkv
  ```

## Development & CI
- **CI**: GitHub Actions workflow checks Bash syntax, runs ShellCheck, and executes the full test suite on every push.
- **Tests**: Run `./tests/run.sh` locally to execute the test harness.

## Reporting bugs
Open an issue on GitHub with:
- macOS version
- `./run.sh --version` output
- Command used and console logs (with `DRY_RUN=1` preferred)
