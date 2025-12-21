# Architecture & Safety Notes

## Safety model
- Validation-first: outputs are probed before originals delete.
- Conservative defaults: software encode, `DELETE=1` guarded by confirmation, language filters prefer ENG/ITA.
- Idempotence: processed sources recorded in `logs/.processed`.

## Hardware acceleration matrix

| HW_ACCEL | Codec | Encoder flag      | Notes                      |
|----------|-------|-------------------|----------------------------|
| auto     | h264  | h264_nvenc/qsv/vaapi | Picks the first available |
| auto     | hevc  | hevc_nvenc/qsv/vaapi | Picks the first available |
| nvenc    | h264  | h264_nvenc        | Requires NVIDIA driver     |
| nvenc    | hevc  | hevc_nvenc        | Requires NVIDIA driver     |
| qsv      | h264  | h264_qsv          | Intel Quick Sync           |
| qsv      | hevc  | hevc_qsv          | Intel Quick Sync           |
| vaapi    | h264  | h264_vaapi        | Needs `/dev/dri/renderD128`|
| vaapi    | hevc  | hevc_vaapi        | Needs `/dev/dri/renderD128`|
| none     | any   | libx264/libx265   | Software encode fallback   |

## Default paths
- Script: `scripts/jellyfin_converter.sh`
- Logs: `logs/`
- Converted outputs: `converted/` under the scan root
- Config presets: `config/default_profiles.env`
- Examples: `examples/`
