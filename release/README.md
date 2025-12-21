# Jellyfin Converter Release Notes

This release bundles the Jellyfin-safe converter script with quick-start usage to keep first runs safe.

## Quick Usage

```bash
# Safe preview (recommended)
DRY_RUN=1 DELETE=0 ./scripts/jellyfin_converter.sh /path/to/videos

# Real run, keep originals
DRY_RUN=0 DELETE=0 ./scripts/jellyfin_converter.sh /path/to/videos

# Enable deletion only after validation confidence
DRY_RUN=0 DELETE=1 ./scripts/jellyfin_converter.sh /path/to/videos
```

### Tips
- Ensure `ffmpeg` and `ffprobe` are installed and on `PATH`.
- Start with small sample files before full libraries.
- Hardware acceleration (NVENC/QSV/VAAPI) requires proper GPU drivers; set `HW_ACCEL=auto` to auto-detect.
