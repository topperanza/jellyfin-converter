# Jellyfin Converter

![CI](https://github.com/mt/jellyfin-converter/actions/workflows/ci.yml/badge.svg)

Stable local CLI for converting common video files into Jellyfin-friendly MKV containers with conservative defaults and safety controls.

## Documentation

- [CLI Contract v1](docs/cli-contract-v1.md)
- [Compatibility Matrix](docs/compatibility-matrix.md)
- [User Guide](docs/user-guide.md)
- [Subtitle Policy & Configuration](docs/subtitles.md)
- [Security Policy](SECURITY.md)

## Supported platforms
- macOS and Linux (both release-blocking in CI)
- Bash 3.2+
- `ffmpeg`, `ffprobe`, `find`, `df` on `PATH`
- Optional: `gnu-parallel` for faster runs

## Install (GitHub release assets)
```bash
curl -fsSL https://raw.githubusercontent.com/mt/jellyfin-converter/main/install.sh | \
  bash -s -- --version v1.1.0
```

By default installer chooses `/usr/local` when writable, otherwise user-local paths.

Installed binary:
```bash
jellyfin-converter --version
jellyfin-converter --self-check
```

## Local repo usage
```bash
./run.sh --dry-run /path/to/videos
```
Dry-run is on by default. Output root defaults to `converted/` under scan dir.

Real conversion (keep originals):
```bash
DRY_RUN=0 DELETE=0 ./run.sh /path/to/videos
```

Enable deletion only after validation confidence:
```bash
DRY_RUN=0 DELETE=1 DELETE_SIDECARS=1 ./run.sh /path/to/videos
```

## Release assets contract
- `release.tar.gz`
- `checksums.txt` (sha256)
- `install.sh`

## CI gates
- Bash syntax
- ShellCheck
- Bash 3.2 compatibility
- Full test suite on macOS + Linux
- Release dry-run packaging and installer validation
- Action pinning check and release-doc/version sync check

## Reporting bugs
Open an issue on GitHub with:
- OS version
- `jellyfin-converter --version` output
- Command used and console logs (with `DRY_RUN=1` preferred)
