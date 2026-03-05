# Troubleshooting

## ffmpeg not found
- macOS: install via Homebrew (`brew install ffmpeg`).
- Linux (Debian/Ubuntu): `sudo apt-get install -y ffmpeg`.
- Confirm with: `ffmpeg -version` and `ffprobe -version`.

## Hardware acceleration mismatch
- Run `jellyfin-converter --self-check`.
- If requested encoder is unavailable, the tool falls back to software.
- Validate host drivers separately (NVENC/QSV/VAAPI).

## Permission errors
- Verify write access to both output and log directories.
- Use user-local locations when not running as root.

## Platform quirks
- macOS ships Bash 3.2; CI enforces Bash 3.2 compatibility.
- Path names with spaces are supported; keep shell quoting when scripting wrappers.
