#!/usr/bin/env bash
# Jellyfin-optimized recursive video → MKV converter
# - Supports: AVI, MP4, MOV, WMV, FLV, M4V, MPG, MPEG, VOB, TS, M2TS, WEBM
# - Hardware acceleration support (NVENC/QSV/VAAPI)
# - English/Italian audio & subs filter (prefers any language over Russian)
# - Always keeps commentary tracks regardless of language
# - Smart remux/transcode with validation
# - Parallel processing support
# - Preserves multi-channel audio & all metadata
# Requires: ffmpeg, ffprobe, (optional: gnu-parallel)

set -euo pipefail
IFS=$'\n\t'

# Supported video formats
VIDEO_FORMATS="avi|mp4|mov|wmv|flv|m4v|mpg|mpeg|vob|ts|m2ts|webm|asf|divx|3gp|ogv|mkv"

# Configuration
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
VERSION_FILE="$PROJECT_ROOT/VERSION"
SCRIPT_VERSION="0.0.0-dev"
if [[ -f "$VERSION_FILE" ]]; then
  read -r SCRIPT_VERSION <"$VERSION_FILE" || true
  SCRIPT_VERSION="${SCRIPT_VERSION:-0.0.0-dev}"
fi

# shellcheck source=scripts/lib/compat.sh
source "$SCRIPT_DIR/lib/compat.sh"
# shellcheck source=scripts/lib/ffmpeg.sh
source "$SCRIPT_DIR/lib/ffmpeg.sh"
# shellcheck source=scripts/lib/media_filters.sh
source "$SCRIPT_DIR/lib/media_filters.sh"
# shellcheck source=scripts/lib/io.sh
source "$SCRIPT_DIR/lib/io.sh"
# shellcheck source=scripts/lib/process.sh
source "$SCRIPT_DIR/lib/process.sh"

SCAN_DIR="${SCAN_DIR:-}"
DEFAULT_OUTROOT="converted"
DEFAULT_LOG_DIR="$PROJECT_ROOT/logs"
DEFAULT_CRF=20
DEFAULT_PRESET="medium"
DEFAULT_CODEC="h264"
DEFAULT_HW_ACCEL="auto"
DEFAULT_OVERWRITE=0
DEFAULT_DELETE=0
DEFAULT_PARALLEL=1
DEFAULT_DRY_RUN=1
DEFAULT_SKIP_DELETE_CONFIRM=0
DEFAULT_PROFILE="jellyfin-1080p"
DEFAULT_PRINT_SUBTITLES=0
DEFAULT_INCLUDE_HIDDEN=0

PROFILE="${PROFILE:-$DEFAULT_PROFILE}"
FORCE_TRANSCODE="${FORCE_TRANSCODE:-}"
MAX_VIDEO_BITRATE_KBPS="${MAX_VIDEO_BITRATE_KBPS:-}"
MAX_FILESIZE_MB="${MAX_FILESIZE_MB:-}"
REMUX_MAX_GB="${REMUX_MAX_GB:-}"
TARGET_HEIGHT="${TARGET_HEIGHT:-}"

ENV_KEYS=(PROFILE FORCE_TRANSCODE MAX_VIDEO_BITRATE_KBPS MAX_FILESIZE_MB REMUX_MAX_GB TARGET_HEIGHT CRF PRESET CODEC HW_ACCEL OVERWRITE DELETE PARALLEL DRY_RUN SKIP_DELETE_CONFIRM OUTROOT LOG_DIR PRINT_SUBTITLES INCLUDE_HIDDEN)
ENV_DEFAULTS=()
PROFILE_FORCE_TRANSCODE=0
PROFILE_MAX_VIDEO_BITRATE_KBPS=0
PROFILE_MAX_FILESIZE_MB=0
PROFILE_TARGET_HEIGHT=0

apply_profile_settings() {
  local name="$1"
  case "$name" in
    jellyfin-1080p)
      PROFILE_FORCE_TRANSCODE=1
      PROFILE_MAX_VIDEO_BITRATE_KBPS=8000
      PROFILE_MAX_FILESIZE_MB=12000
      PROFILE_TARGET_HEIGHT=1080
      ;;
    jellyfin-720p)
      PROFILE_FORCE_TRANSCODE=1
      PROFILE_MAX_VIDEO_BITRATE_KBPS=4500
      PROFILE_MAX_FILESIZE_MB=8000
      PROFILE_TARGET_HEIGHT=720
      ;;
    archive|auto)
      PROFILE_FORCE_TRANSCODE=0
      PROFILE_MAX_VIDEO_BITRATE_KBPS=0
      PROFILE_MAX_FILESIZE_MB=0
      PROFILE_TARGET_HEIGHT=0
      ;;
    *)
      echo "ERROR: Unsupported profile: $name"
      exit 1
      ;;
  esac
}

normalize_int_or_zero() {
  local val="$1"
  if [[ -z "$val" || ! "$val" =~ ^[0-9]+$ ]]; then
    echo 0
  else
    echo "$val"
  fi
}

configure_policy_defaults() {
  PROFILE="$(to_lower "$PROFILE")"
  apply_profile_settings "$PROFILE"

  local remux_max_gb
  remux_max_gb="$(normalize_int_or_zero "${REMUX_MAX_GB:-0}")"
  local remux_default_gb
  remux_default_gb=$(awk "BEGIN {printf \"%.1f\", $PROFILE_MAX_FILESIZE_MB/1024}")

  FORCE_TRANSCODE="$(normalize_int_or_zero "${FORCE_TRANSCODE:-$PROFILE_FORCE_TRANSCODE}")"
  MAX_VIDEO_BITRATE_KBPS="$(normalize_int_or_zero "${MAX_VIDEO_BITRATE_KBPS:-$PROFILE_MAX_VIDEO_BITRATE_KBPS}")"
  MAX_FILESIZE_MB="$(normalize_int_or_zero "${MAX_FILESIZE_MB:-$PROFILE_MAX_FILESIZE_MB}")"
  if [[ "$remux_max_gb" -gt 0 ]]; then
    MAX_FILESIZE_MB=$((remux_max_gb * 1024))
    REMUX_MAX_GB="$remux_max_gb"
  else
    REMUX_MAX_GB="$remux_default_gb"
  fi
  TARGET_HEIGHT="$(normalize_int_or_zero "${TARGET_HEIGHT:-$PROFILE_TARGET_HEIGHT}")"

  ENV_DEFAULTS=(
    "$DEFAULT_PROFILE"
    "$PROFILE_FORCE_TRANSCODE"
    "$PROFILE_MAX_VIDEO_BITRATE_KBPS"
    "$PROFILE_MAX_FILESIZE_MB"
    "$remux_default_gb"
    "$PROFILE_TARGET_HEIGHT"
    "$DEFAULT_CRF"
    "$DEFAULT_PRESET"
    "$DEFAULT_CODEC"
    "$DEFAULT_HW_ACCEL"
    "$DEFAULT_OVERWRITE"
    "$DEFAULT_DELETE"
    "$DEFAULT_PARALLEL"
    "$DEFAULT_DRY_RUN"
    "$DEFAULT_SKIP_DELETE_CONFIRM"
    "$DEFAULT_OUTROOT"
    "$DEFAULT_LOG_DIR"
    "$DEFAULT_PRINT_SUBTITLES"
    "$DEFAULT_INCLUDE_HIDDEN"
  )
}

print_usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS] [DIRECTORY]

Convert videos under DIRECTORY into Jellyfin-friendly MKV files.

Options:
  --profile <name>          Profile: jellyfin-1080p (default), jellyfin-720p, archive, auto
  --force-transcode         Force transcoding (overrides profile)
  --no-force-transcode      Disable forced transcoding (overrides profile)
  --max-video-bitrate-kbps N  Max video bitrate allowed for remux (0=ignore)
  --max-filesize-mb N       Max file size allowed for remux (0=ignore)
  --target-height N         Max video height allowed for remux (0=ignore)
  --preflight[=info|strict]  Run environment checks before processing
  --print-subtitles          Debug: Print subtitle inventory and selection plan
  --dry-run                  Preview actions without writing outputs (default)
  --version                  Show script version and exit
  -h, --help                 Show this help message and exit

Defaults:
  Profile=$DEFAULT_PROFILE (transcode-first)
  DRY_RUN=$DEFAULT_DRY_RUN DELETE=$DEFAULT_DELETE OUTROOT="$DEFAULT_OUTROOT" LOG_DIR="$DEFAULT_LOG_DIR"
EOF
}

OUTROOT="${OUTROOT:-$DEFAULT_OUTROOT}"
OUTROOT_PATH=""
LOG_DIR="${LOG_DIR:-$DEFAULT_LOG_DIR}"  # Centralized log location (override with LOG_DIR=/path)
CRF="${CRF:-$DEFAULT_CRF}"              # Video quality (lower=better, 18-28 recommended)
PRESET="${PRESET:-$DEFAULT_PRESET}"    # x264 preset: ultrafast|fast|medium|slow|veryslow
CODEC="${CODEC:-$DEFAULT_CODEC}"        # h264 or hevc (hevc saves ~40% space)
HW_ACCEL="${HW_ACCEL:-$DEFAULT_HW_ACCEL}"  # auto|nvenc|qsv|vaapi|none
OVERWRITE="${OVERWRITE:-$DEFAULT_OVERWRITE}"   # 1 to overwrite existing outputs
DELETE="${DELETE:-$DEFAULT_DELETE}"         # 1 to delete originals after success
PARALLEL="${PARALLEL:-$DEFAULT_PARALLEL}"     # Number of simultaneous conversions
DRY_RUN="${DRY_RUN:-$DEFAULT_DRY_RUN}"       # 1 to test without converting
SKIP_DELETE_CONFIRM="${SKIP_DELETE_CONFIRM:-$DEFAULT_SKIP_DELETE_CONFIRM}"  # 1 to skip delete confirmation (for automation)
PREFLIGHT_MODE="${PREFLIGHT_MODE:-off}" # off|info|strict
INCLUDE_HIDDEN="${INCLUDE_HIDDEN:-$DEFAULT_INCLUDE_HIDDEN}" # 1 to include hidden files/dirs

resolve_outroot() {
  local base="$OUTROOT"
  if [[ "$base" = /* ]]; then
    OUTROOT_PATH="$base"
  else
    OUTROOT_PATH="$SCAN_DIR/$base"
  fi
}

format_kb() {
  local kb="$1"
  if [[ -z "$kb" || ! "$kb" =~ ^[0-9]+$ ]]; then
    echo "unknown"
    return 1
  fi

  local mb=$((kb / 1024))
  if [[ "$mb" -ge 1024 ]]; then
    printf "%.1f GiB" "$(awk "BEGIN {print $mb/1024}")"
  else
    printf "%d MiB" "$mb"
  fi
}

report_env_overrides() {
  local -a overrides=()
  local idx=0
  local var expected current
  for var in "${ENV_KEYS[@]}"; do
    expected="${ENV_DEFAULTS[$idx]}"
    case "$var" in
      PROFILE) current="$PROFILE" ;;
      FORCE_TRANSCODE) current="$FORCE_TRANSCODE" ;;
      MAX_VIDEO_BITRATE_KBPS) current="$MAX_VIDEO_BITRATE_KBPS" ;;
      MAX_FILESIZE_MB) current="$MAX_FILESIZE_MB" ;;
      REMUX_MAX_GB) current="$REMUX_MAX_GB" ;;
      TARGET_HEIGHT) current="$TARGET_HEIGHT" ;;
      CRF) current="$CRF" ;;
      PRESET) current="$PRESET" ;;
      CODEC) current="$CODEC" ;;
      HW_ACCEL) current="$HW_ACCEL" ;;
      OVERWRITE) current="$OVERWRITE" ;;
      DELETE) current="$DELETE" ;;
      PARALLEL) current="$PARALLEL" ;;
      DRY_RUN) current="$DRY_RUN" ;;
      SKIP_DELETE_CONFIRM) current="$SKIP_DELETE_CONFIRM" ;;
      OUTROOT) current="$OUTROOT" ;;
      LOG_DIR) current="$LOG_DIR" ;;
      INCLUDE_HIDDEN) current="$INCLUDE_HIDDEN" ;;
      *) current="" ;;
    esac
    if [[ "$current" != "$expected" ]]; then
      overrides+=("$var=$current (default: $expected)")
    fi
    ((idx+=1))
  done

  if [[ "${#overrides[@]}" -eq 0 ]]; then
    echo "none (defaults in use)"
  else
    printf '%s\n' "${overrides[@]}"
  fi
}

preflight_checks() {
  local mode="$1"
  local status=0
  local resolved_hw
  resolved_hw="$(detect_hw_accel)"

  local target_path="$OUTROOT_PATH"
  local free_kb
  free_kb=$(df -Pk "$target_path" 2>/dev/null | awk 'NR==2 {print $4}')
  local free_pretty; free_pretty=$(format_kb "${free_kb:-}")

  echo "════════════════════════════════════════"
  echo "  Preflight (${mode})"
  echo "════════════════════════════════════════"
  echo "Free space: $free_pretty at $target_path"

  if [[ "$free_pretty" == "unknown" ]]; then
    echo "WARNING: Unable to determine free space (df failed for $target_path)"
    status=1
  fi

  echo "HW encoder: requested=$HW_ACCEL | resolved=${resolved_hw:-none}"
  if [[ "$resolved_hw" == "none" && "$HW_ACCEL" != "none" && "$HW_ACCEL" != "auto" ]]; then
    echo "WARNING: Requested HW_ACCEL=$HW_ACCEL but no matching encoder was found."
    status=1
  fi

  echo "Env overrides:"
  report_env_overrides | sed 's/^/  - /'
  echo "════════════════════════════════════════"

  if [[ "$mode" == "strict" && "$status" -ne 0 ]]; then
    echo "Preflight failed in strict mode; aborting before file discovery."
    exit 4
  fi
}

need_cmd ffmpeg "install ffmpeg via your package manager"
need_cmd ffprobe "install ffprobe via your package manager (often bundled with ffmpeg)"
need_cmd find "install findutils/coreutils via your package manager"
need_cmd df "install coreutils (df) via your package manager"
echo "INFO: Hardware acceleration (nvenc/qsv/vaapi) requires appropriate GPU drivers"



# Export functions for parallel processing
export -f process_one map_lang is_eng_or_ita is_codec_compatible_video is_codec_compatible_audio
export -f detect_hw_accel get_optimal_crf log_conversion encoder_present get_video_bitrate_kbps get_filesize_mb
export -f build_audio_map_args finalize_audio_selection collect_subtitle is_commentary_title select_internal_subtitles
export -f run_ffmpeg
export SCAN_DIR OUTROOT OUTROOT_PATH LOG_DIR CRF PRESET CODEC HW_ACCEL RESOLVED_HW OVERWRITE DELETE DRY_RUN LOGFILE DONE_FILE PRINT_SUBTITLES

# Argument parsing for preflight flag + optional path
while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h)
      print_usage
      exit 0
      ;;
    --profile)
      if [[ -z "${2:-}" ]]; then
        echo "ERROR: --profile requires a value"
        exit 1
      fi
      PROFILE="$2"
      shift 2
      ;;
    --profile=*)
      PROFILE="${1#*=}"
      shift
      ;;
    --force-transcode)
      FORCE_TRANSCODE=1
      shift
      ;;
    --no-force-transcode)
      FORCE_TRANSCODE=0
      shift
      ;;
    --max-video-bitrate-kbps)
      if [[ -z "${2:-}" ]]; then
        echo "ERROR: --max-video-bitrate-kbps requires a value"
        exit 1
      fi
      MAX_VIDEO_BITRATE_KBPS="$2"
      shift 2
      ;;
    --max-video-bitrate-kbps=*)
      MAX_VIDEO_BITRATE_KBPS="${1#*=}"
      shift
      ;;
    --max-filesize-mb)
      if [[ -z "${2:-}" ]]; then
        echo "ERROR: --max-filesize-mb requires a value"
        exit 1
      fi
      MAX_FILESIZE_MB="$2"
      shift 2
      ;;
    --max-filesize-mb=*)
      MAX_FILESIZE_MB="${1#*=}"
      shift
      ;;
    --target-height)
      if [[ -z "${2:-}" ]]; then
        echo "ERROR: --target-height requires a value"
        exit 1
      fi
      TARGET_HEIGHT="$2"
      shift 2
      ;;
    --target-height=*)
      TARGET_HEIGHT="${1#*=}"
      shift
      ;;
    --version)
      echo "jellyfin_converter v$SCRIPT_VERSION"
      exit 0
      ;;
    --preflight)
      PREFLIGHT_MODE="info"
      shift
      ;;
    --preflight=info)
      PREFLIGHT_MODE="info"
      shift
      ;;
    --preflight=strict|--preflight-strict)
      PREFLIGHT_MODE="strict"
      shift
      ;;
    --print-subtitles)
      PRINT_SUBTITLES=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --no-dry-run)
      DRY_RUN=0
      shift
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "ERROR: Unknown option: $1"
      exit 1
      ;;
    *)
      SCAN_DIR="$1"
      shift
      break
      ;;
  esac
done

if [[ -z "${SCAN_DIR:-}" && "$#" -gt 0 ]]; then
  SCAN_DIR="$1"
  shift
fi

if [[ -n "${SCAN_DIR:-}" ]]; then
  if [[ ! -d "$SCAN_DIR" ]]; then
    echo "ERROR: Directory does not exist: $SCAN_DIR"
    exit 1
  fi
  SCAN_DIR=$(cd "$SCAN_DIR" && pwd)
else
  select_folder
fi

configure_policy_defaults
resolve_outroot

# Now set up log files after SCAN_DIR is determined
LOGFILE="$LOG_DIR/conversion.log"
DONE_FILE="$LOG_DIR/.processed"

mkdir -p "$OUTROOT_PATH" "$LOG_DIR"
[[ -f "$DONE_FILE" ]] || touch "$DONE_FILE"

check_write_permissions
touch "$LOGFILE"

preflight_hw_encoder

echo "════════════════════════════════════════"
echo "  Jellyfin Video → MKV Converter (v$SCRIPT_VERSION)"
echo "════════════════════════════════════════"
echo "Scanning: $SCAN_DIR"
echo "Output: $OUTROOT_PATH/"
echo ""
echo "Supported formats: ${VIDEO_FORMATS//|/, }"
echo ""
echo "Settings:"
profile_label="$PROFILE"
[[ "$PROFILE" == "$DEFAULT_PROFILE" ]] && profile_label="$PROFILE (default)"
echo "  Profile: $profile_label"
echo "  Policy: force=$FORCE_TRANSCODE | Max bitrate: $MAX_VIDEO_BITRATE_KBPS kbps | Max size: $MAX_FILESIZE_MB MB | Target height: $TARGET_HEIGHT"
echo "  Codec: $CODEC | CRF: $CRF | Preset: $PRESET"
echo "  HW Accel: ${RESOLVED_HW:-$HW_ACCEL} | Parallel: $PARALLEL"
echo "  Delete originals: $DELETE | Dry run: $DRY_RUN"
echo "  Languages: English + Italian + Commentary (prefer any over Russian)"
echo "════════════════════════════════════════"
echo ""
if [[ "$DRY_RUN" == "0" ]]; then
  echo "Tip: For first-time runs, set DRY_RUN=1 to preview actions without converting."
  echo ""
fi
if [[ "$DRY_RUN" == "1" ]]; then
  echo "!!! DRY-RUN MODE: no files will be modified (DELETE=$DELETE) !!!"
else
  echo "!!! REAL RUN: outputs will be written (DELETE=$DELETE) !!!"
fi
echo "Mode: dry=$DRY_RUN delete=$DELETE parallel=$PARALLEL"

if [[ "$PREFLIGHT_MODE" != "off" ]]; then
  preflight_checks "$PREFLIGHT_MODE"
fi

# Confirm destructive delete when not a dry run (can bypass with SKIP_DELETE_CONFIRM=1)
if [[ "$DELETE" == "1" && "$DRY_RUN" == "0" && "$SKIP_DELETE_CONFIRM" != "1" ]]; then
  echo "WARNING: Originals will be deleted after successful conversion."
  echo "Set SKIP_DELETE_CONFIRM=1 to bypass this prompt for automated runs."
  read -r -p "Continue and delete originals? (y/N): " delete_confirm
  if [[ ! "$delete_confirm" =~ ^[Yy]$ ]]; then
    echo "Delete not confirmed. Exiting."
    exit 2
  fi
fi

# Process files
echo "Normalized scan root: $SCAN_DIR"
echo "Filename patterns: $(display_patterns)"

# Build find arguments safely (disable globbing to preserve * in patterns)
set -f
# shellcheck disable=SC2046,SC2207
find_args=( $(build_find_pattern) )
set +f

# Build prune arguments
prune_expr=()
if [[ "$INCLUDE_HIDDEN" != "1" ]]; then
  # Prune hidden directories (and files starting with .)
  prune_expr+=("-name" ".*")
fi

# Prune output directory if it is inside SCAN_DIR
if [[ "$OUTROOT_PATH" == "$SCAN_DIR"/* ]]; then
  if [[ ${#prune_expr[@]} -gt 0 ]]; then
    prune_expr+=("-o")
  fi
  prune_expr+=("-path" "$OUTROOT_PATH")
fi

# Prune log directory if it is inside SCAN_DIR
if [[ "$LOG_DIR" == "$SCAN_DIR"/* ]]; then
  if [[ ${#prune_expr[@]} -gt 0 ]]; then
    prune_expr+=("-o")
  fi
  prune_expr+=("-path" "$LOG_DIR")
fi

# Construct the full find command array
find_cmd=("find" "$SCAN_DIR")

if [[ ${#prune_expr[@]} -gt 0 ]]; then
  # -type d \( ... \) -prune -o
  find_cmd+=("-type" "d" "(" "${prune_expr[@]}" ")" "-prune" "-o")
fi

# Add the file search part
find_cmd+=("-type" "f" "(" "${find_args[@]}" ")" "-print0")

if command -v parallel >/dev/null 2>&1 && [[ "$PARALLEL" -gt 1 ]]; then
  echo "Using GNU Parallel with $PARALLEL jobs"
  "${find_cmd[@]}" | \
    parallel -0 -j "$PARALLEL" --bar process_one {}
else
  "${find_cmd[@]}" | while IFS= read -r -d '' f; do
    process_one "$f" < /dev/null
  done
fi

echo ""
echo "════════════════════════════════════════"
echo "✓ All done! Output: $OUTROOT_PATH/"
echo "  Log file: $LOGFILE"
echo "════════════════════════════════════════"
exit 0
