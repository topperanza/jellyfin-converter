# Compatibility Matrix

## Supported platforms (release-blocking)
- macOS: current `macos-latest` GitHub runner baseline.
- Linux: current `ubuntu-latest` GitHub runner baseline.
- Shell: Bash 3.2+ (explicitly compatibility-checked in CI).

## Required tools
- `ffmpeg` and `ffprobe` on `PATH`
- `find` and `df` on `PATH`

## ffmpeg/ffprobe baseline
- Minimum tested baseline: versions available on current `ubuntu-latest` and `macos-latest` CI runners.
- The release process executes `--self-check` and the full test suite on both OSes.

## Codec/container support
- Input containers scanned by default: `avi`, `mp4`, `mov`, `wmv`, `flv`, `m4v`, `mpg`, `mpeg`, `vob`, `ts`, `m2ts`, `webm`, `asf`, `divx`, `3gp`, `ogv`, `mkv`.
- Output container: `mkv`.
- Video compatibility for remux: `h264`, `hevc`, `av1`.
- Audio compatibility for remux: `aac`, `ac3`, `eac3`, `mp3`, `flac`, `opus`, `dts`.

## Known limitations
- ffmpeg binaries are not bundled; installation is environment-managed.
- Hardware acceleration depends on host drivers/encoder availability.
- Sidecar subtitle deletion is intentionally conservative and may keep files when ambiguity exists.
