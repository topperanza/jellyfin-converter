# Minimal command invocations

Convert in dry-run mode (recommended first pass):

```bash
DRY_RUN=1 DELETE=0 ./scripts/jellyfin_converter.sh /path/to/videos
```

Software encode with overwrite enabled:

```bash
OVERWRITE=1 CODEC=h264 CRF=20 ./scripts/jellyfin_converter.sh /path/to/videos
```

Hardware-accelerated HEVC (NVENC/QSV/VAAPI auto-detect):

```bash
CODEC=hevc HW_ACCEL=auto ./scripts/jellyfin_converter.sh /path/to/videos
```
