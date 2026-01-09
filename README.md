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
# Deletes source video after successful conversion
DRY_RUN=0 DELETE=1 ./run.sh /path/to/videos

# Also delete sidecar files (only if uniquely anchored to the video)
DRY_RUN=0 DELETE=1 DELETE_SIDECARS=1 ./run.sh /path/to/videos
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

## CI & Linting
- **CI**: Uses `shellcheck-py` (pip-installed ShellCheck) for linting and `setup-ffmpeg` for ffmpeg/ffprobe.
- **Bash 3.2**: Enforces compatibility with macOS system bash (3.2). A guard script (`scripts/check_bash32.sh`) runs in CI to catch Bash 4+ features (e.g. `local -n`, `declare -A`, `mapfile`).
- **No Homebrew**: Homebrew is intentionally NOT used to avoid large dependency chains on older macOS (e.g. Catalina).
- **Tests**: Run `./tests/run.sh` locally to execute the test harness.

### Local Development Setup
```bash
python3 -m venv .venv
. .venv/bin/activate
pip install shellcheck-py
shellcheck --version
```

### ShellCheck (no Homebrew)
- Installer: `./scripts/install_shellcheck.sh` prefers an active Python venv, otherwise creates `.venv-shellcheck` locally and installs `shellcheck-py`.
- Mirrors: set `PIP_INDEX_URL` (optionally `PIP_EXTRA_INDEX_URL`) to your mirror. Use URLs ending with `/simple`.
- Proxies: set `HTTP_PROXY` / `HTTPS_PROXY` if required.
- Verification: `shellcheck --version` after running the installer.
- CI: secrets `PIP_INDEX_URL` and `PIP_EXTRA_INDEX_URL` are passed to the installer; no mirror URLs are committed to the repo.

## Reporting bugs
Open an issue on GitHub with:
- macOS version
- `./run.sh --version` output
- Command used and console logs (with `DRY_RUN=1` preferred)
