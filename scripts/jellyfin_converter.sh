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

# Supported video formats (excluding mkv since that's our target)
VIDEO_FORMATS="avi|mp4|mov|wmv|flv|m4v|mpg|mpeg|vob|ts|m2ts|webm|asf|divx|3gp|ogv"

# Configuration
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
VERSION_FILE="$PROJECT_ROOT/VERSION"
SCRIPT_VERSION="0.0.0-dev"
if [[ -f "$VERSION_FILE" ]]; then
  read -r SCRIPT_VERSION <"$VERSION_FILE"
  SCRIPT_VERSION="${SCRIPT_VERSION:-0.0.0-dev}"
fi

source "$SCRIPT_DIR/lib/compat.sh"
source "$SCRIPT_DIR/lib/ffmpeg.sh"
source "$SCRIPT_DIR/lib/media_filters.sh"
source "$SCRIPT_DIR/lib/io.sh"

SCAN_DIR=""
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

ENV_KEYS=(CRF PRESET CODEC HW_ACCEL OVERWRITE DELETE PARALLEL DRY_RUN SKIP_DELETE_CONFIRM OUTROOT LOG_DIR)
ENV_DEFAULTS=("$DEFAULT_CRF" "$DEFAULT_PRESET" "$DEFAULT_CODEC" "$DEFAULT_HW_ACCEL" "$DEFAULT_OVERWRITE" "$DEFAULT_DELETE" "$DEFAULT_PARALLEL" "$DEFAULT_DRY_RUN" "$DEFAULT_SKIP_DELETE_CONFIRM" "$DEFAULT_OUTROOT" "$DEFAULT_LOG_DIR")

print_usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS] [DIRECTORY]

Convert videos under DIRECTORY into Jellyfin-friendly MKV files.

Options:
  --preflight[=info|strict]  Run environment checks before processing
  --dry-run                  Preview actions without writing outputs (default)
  --version                  Show script version and exit
  -h, --help                 Show this help message and exit

Defaults:
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

process_one() {
  local src="$1"
  local rel="${src#$SCAN_DIR/}"
  local srcdir; srcdir="$(dirname "$rel")"
  local filename; filename="$(basename "$rel")"
  local base="${filename%.*}"
  local ext="${filename##*.}"
  local outdir="$OUTROOT_PATH/$srcdir"
  local out="$outdir/$base.mkv"

  mkdir -p "$outdir"
  
  # Skip if already MKV
  ext="$(to_lower "$ext")"
  local ext_upper; ext_upper="$(to_upper "$ext")"
  if [[ "$ext" == "mkv" ]]; then
    echo "Skip (already MKV): $src"
    return 0
  fi

  # Skip if already processed
  if grep -Fxq "$src" "$DONE_FILE" 2>/dev/null; then
    echo "Skip (already processed): $src"
    return 0
  fi

  # Skip if exists and not overwriting
  if [[ -f "$out" && "$OVERWRITE" != "1" ]]; then
    echo "Skip (exists): $out"
    return 0
  fi

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Source: $src [$ext_upper]"
  echo "Output: $out"

  # Probe video/audio codecs
  local vcodec acodec
  vcodec=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name \
           -of default=nw=1:nk=1 "$src" 2>/dev/null || echo "unknown")
  acodec=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name \
           -of default=nw=1:nk=1 "$src" 2>/dev/null || echo "none")
  
  local height=$(ffprobe -v error -select_streams v:0 \
    -show_entries stream=height -of csv=p=0 "$src" 2>/dev/null || echo "?")
  
  echo "Video: $vcodec (${height}p) | Audio: $acodec"

  local audio_info=$(ffprobe -v error -select_streams a -show_entries \
    stream=index:stream_tags=language,title -of csv=p=0 "$src" 2>/dev/null || echo "")

  local -a audio_map_args=()
  local -a russian_tracks=()
  local has_eng_or_ita=0
  local has_non_russian=0

  build_audio_map_args "$audio_info" audio_map_args russian_tracks has_eng_or_ita has_non_russian
  finalize_audio_selection audio_map_args russian_tracks "$has_eng_or_ita" "$has_non_russian"

  # Initialize subtitle inputs to avoid set -u failures when none are found
  local -a sub_inputs=() sub_langs=() sub_forced=() sub_files=()
  local sub_idx=0

  # Get source directory for finding subtitles
  local src_full_dir; src_full_dir="$(dirname "$src")"

  # Collect external subtitles (English/Italian only)
  (
    shopt -s nullglob
    for ext in srt ass sub; do
      for s in "$src_full_dir/$base".*."$ext" "$src_full_dir/$base"."$ext"; do
        [[ -f "$s" ]] && collect_subtitle "$s" "$base" sub_inputs sub_langs sub_forced sub_files sub_idx
      done
    done
  ) || true

  # Build mapping args
  local -a map_args=("-map" "0:v:0")
  map_args+=("${audio_map_args[@]}")
  
  if (( sub_idx > 0 )); then
    for ((i=1; i<=sub_idx; i++)); do 
      map_args+=("-map" "$i:0")
    done
  fi

  # Build metadata args for subtitles
  local -a meta_args=()
  if (( sub_idx > 0 )); then
    for ((i=0; i<sub_idx; i++)); do
      local lang="${sub_langs[$i]}" forced="${sub_forced[$i]}"
      [[ -n "$lang" ]] && meta_args+=("-metadata:s:s:$i" "language=$lang")
      [[ -n "$lang" ]] && meta_args+=("-metadata:s:s:$i" "title=Subtitle ($lang)")
      [[ "$forced" -eq 1 ]] && meta_args+=("-disposition:s:$i" "forced")
    done
  fi

  # Container metadata
  meta_args+=("-metadata" "title=$base")

  # Determine if remux is possible
  local do_remux=0
  if is_codec_compatible_video "$vcodec" && is_codec_compatible_audio "$acodec"; then
    do_remux=1
  fi

  # Subtitle codec (copy ASS/SSA, convert SUB to SRT)
  local -a sub_codec_args=()
  if (( sub_idx > 0 )); then
    sub_codec_args=("-c:s" "copy")
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    echo "[DRY RUN] Would process: $src → $out (method: $([ $do_remux -eq 1 ] && echo remux || echo transcode))"
    return 0
  fi

  # Try REMUX first if possible
  if [[ "$do_remux" -eq 1 ]]; then
    echo "→ Attempting remux (no re-encoding)..."
    if ffmpeg -hide_banner -y -i "$src" "${sub_inputs[@]}" \
      "${map_args[@]}" -c copy "${sub_codec_args[@]}" "${meta_args[@]}" \
      "$out" 2>&1 | grep -v "Timestamps are unset"; then
      
      # Validate output
      if ffprobe -v error "$out" >/dev/null 2>&1; then
        touch -r "$src" "$out"
        echo "✓ Remux successful → $out"
        log_conversion "$src" "$out" "remux"
        
        if [[ "$DELETE" == "1" ]]; then
          rm -f "$src" "${sub_files[@]}"
          echo "✓ Deleted originals"
        fi
        
        echo "$src" >> "$DONE_FILE"
        return 0
      else
        echo "✗ Output validation failed, removing bad file"
        rm -f "$out"
      fi
    else
      echo "✗ Remux failed → will transcode"
      rm -f "$out"
    fi
  else
    echo "→ Transcoding required (incompatible codecs)"
  fi

  # TRANSCODE
  local hw=$(detect_hw_accel)
  local -a encode_args=()
  local optimal_crf=$(get_optimal_crf "$src")
  local use_crf="${CRF:-$optimal_crf}"
  
  case "$hw" in
    nvenc)
      if [[ "$CODEC" == "hevc" ]]; then
        encode_args=(-c:v hevc_nvenc -preset p4 -cq "$use_crf" -b:v 0 -spatial_aq 1 -temporal_aq 1)
        echo "→ Using NVIDIA NVENC (HEVC)"
      else
        encode_args=(-c:v h264_nvenc -preset p4 -cq "$use_crf" -b:v 0 -spatial_aq 1 -temporal_aq 1)
        echo "→ Using NVIDIA NVENC (H.264)"
      fi
      ;;
    qsv)
      if [[ "$CODEC" == "hevc" ]]; then
        encode_args=(-c:v hevc_qsv -preset "$PRESET" -global_quality "$use_crf" -look_ahead 1)
        echo "→ Using Intel QuickSync (HEVC)"
      else
        encode_args=(-c:v h264_qsv -preset "$PRESET" -global_quality "$use_crf" -look_ahead 1)
        echo "→ Using Intel QuickSync (H.264)"
      fi
      ;;
    vaapi)
      if [[ "$CODEC" == "hevc" ]]; then
        encode_args=(-vaapi_device /dev/dri/renderD128 -c:v hevc_vaapi -qp "$use_crf")
        echo "→ Using VA-API (HEVC)"
      else
        encode_args=(-vaapi_device /dev/dri/renderD128 -c:v h264_vaapi -qp "$use_crf")
        echo "→ Using VA-API (H.264)"
      fi
      ;;
    *)
      if [[ "$CODEC" == "hevc" ]]; then
        encode_args=(-c:v libx265 -preset "$PRESET" -crf "$use_crf" -x265-params log-level=error)
        echo "→ Using software encoding (HEVC) - this will be slow"
      else
        encode_args=(-c:v libx264 -preset "$PRESET" -crf "$use_crf")
        echo "→ Using software encoding (H.264) - this will be slow"
      fi
      ;;
  esac

  # Audio encoding strategy
  local channels=$(ffprobe -v error -select_streams a:0 \
    -show_entries stream=channels -of csv=p=0 "$src" 2>/dev/null || echo "2")
  
  local -a audio_encode_args=()
  if [[ "$channels" -gt 2 ]] && is_codec_compatible_audio "$acodec"; then
    audio_encode_args=(-c:a copy)
    echo "→ Preserving multi-channel audio ($channels ch)"
  elif [[ "$channels" -gt 2 ]]; then
    audio_encode_args=(-c:a ac3 -b:a 640k)
    echo "→ Encoding multi-channel to AC3 ($channels ch)"
  else
    audio_encode_args=(-c:a aac -b:a 128k)
    echo "→ Encoding stereo to AAC"
  fi

  # Execute transcode
  if ffmpeg -hide_banner -y -i "$src" "${sub_inputs[@]}" \
    "${map_args[@]}" "${encode_args[@]}" "${audio_encode_args[@]}" \
    "${sub_codec_args[@]}" "${meta_args[@]}" "$out"; then
    
    # Validate output
    if ffprobe -v error "$out" >/dev/null 2>&1; then
      touch -r "$src" "$out"
      echo "✓ Transcode successful → $out"
      log_conversion "$src" "$out" "transcode"
      
      if [[ "$DELETE" == "1" ]]; then
        rm -f "$src" "${sub_files[@]}"
        echo "✓ Deleted originals"
      fi
      
      echo "$src" >> "$DONE_FILE"
      return 0
    else
      echo "✗ Output validation failed!"
      rm -f "$out"
      return 1
    fi
  else
    echo "✗ Transcode failed!"
    rm -f "$out"
    return 1
  fi
}

# Export functions for parallel processing
export -f process_one map_lang is_eng_or_ita is_codec_compatible_video is_codec_compatible_audio
export -f detect_hw_accel get_optimal_crf log_conversion encoder_present
export -f build_audio_map_args finalize_audio_selection collect_subtitle is_commentary_title
export SCAN_DIR OUTROOT OUTROOT_PATH LOG_DIR CRF PRESET CODEC HW_ACCEL RESOLVED_HW OVERWRITE DELETE DRY_RUN LOGFILE DONE_FILE

# Argument parsing for preflight flag + optional path
while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h)
      print_usage
      exit 0
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
if command -v parallel >/dev/null 2>&1 && [[ "$PARALLEL" -gt 1 ]]; then
  echo "Using GNU Parallel with $PARALLEL jobs"
  find "$SCAN_DIR" -type f \( $(build_find_pattern) \) -print0 | \
    parallel -0 -j "$PARALLEL" --bar process_one {}
else
  find "$SCAN_DIR" -type f \( $(build_find_pattern) \) -print0 | while IFS= read -r -d '' f; do
    process_one "$f"
  done
fi

echo ""
echo "════════════════════════════════════════"
echo "✓ All done! Output: $OUTROOT_PATH/"
echo "  Log file: $LOGFILE"
echo "════════════════════════════════════════"
