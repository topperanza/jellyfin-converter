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

source "$SCRIPT_DIR/lib/compat.sh"
source "$SCRIPT_DIR/lib/ffmpeg.sh"
source "$SCRIPT_DIR/lib/media_filters.sh"
source "$SCRIPT_DIR/lib/io.sh"
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

PROFILE="${PROFILE:-$DEFAULT_PROFILE}"
FORCE_TRANSCODE="${FORCE_TRANSCODE:-}"
MAX_VIDEO_BITRATE_KBPS="${MAX_VIDEO_BITRATE_KBPS:-}"
MAX_FILESIZE_MB="${MAX_FILESIZE_MB:-}"
REMUX_MAX_GB="${REMUX_MAX_GB:-}"
TARGET_HEIGHT="${TARGET_HEIGHT:-}"

ENV_KEYS=(PROFILE FORCE_TRANSCODE MAX_VIDEO_BITRATE_KBPS MAX_FILESIZE_MB REMUX_MAX_GB TARGET_HEIGHT CRF PRESET CODEC HW_ACCEL OVERWRITE DELETE PARALLEL DRY_RUN SKIP_DELETE_CONFIRM OUTROOT LOG_DIR PRINT_SUBTITLES)
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

process_one_OLD_unused() {
  local src="$1"
  local src_full_dir; src_full_dir="$(dirname "$src")"
  local -a sub_inputs=()
  local -a sub_langs=()
  local -a sub_forced=()
  local -a sub_files=()
  local -a subtitle_map_args=()
  local -a audio_map_args=()
  local -a russian_tracks=()
  local -a SUBTITLE_SELECTION_MAP_ARGS=()
  local SUBTITLE_INTERNAL_COUNT=0
  local has_eng_or_ita=0
  local has_non_russian=0
  local sub_idx=0
  local -a sub_inputs=() sub_langs=() sub_forced=() sub_files=()
  local rel="${src#$SCAN_DIR/}"
  local srcdir; srcdir="$(dirname "$rel")"
  local filename; filename="$(basename "$rel")"
  local base="${filename%.*}"
  local ext="${filename##*.}"
  local ext_upper; ext_upper="$(to_upper "$ext")"
  local outdir="$OUTROOT_PATH/$srcdir"
  local out="$outdir/$base.mkv"

  mkdir -p "$outdir"
  
  # Skip if source and output are the same file
  if [[ "$src" == "$out" ]]; then
    echo "Skip (source is same as output): $src"
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
           -of default=nw=1:nk=1 "$src" < /dev/null 2>/dev/null || echo "unknown")
  acodec=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name \
           -of default=nw=1:nk=1 "$src" < /dev/null 2>/dev/null || echo "none")
  
  local height=$(ffprobe -v error -select_streams v:0 \
    -show_entries stream=height -of csv=p=0 "$src" < /dev/null 2>/dev/null || echo "?")
  
  echo "Video: $vcodec (${height}p) | Audio: $acodec"

  # 1. Get list of audio streams (index)
  local audio_indices
  audio_indices=$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$src" < /dev/null 2>/dev/null || echo "")
  
  # 2. Build audio info manually (reliable)
  local audio_info=""
  if [[ -n "$audio_indices" ]]; then
    for idx in $audio_indices; do
      local lang title
      lang=$(ffprobe -v error -select_streams "0:$idx" -show_entries stream=tags:language -of csv=p=0 "$src" < /dev/null 2>/dev/null || echo "und")
      title=$(ffprobe -v error -select_streams "0:$idx" -show_entries stream=tags:title -of csv=p=0 "$src" < /dev/null 2>/dev/null || echo "")
      # Construct CSV line: index,lang,title
      audio_info+="${idx},${lang:-und},${title}"$'\n'
    done
  fi

  build_audio_map_args "$audio_info" audio_map_args russian_tracks has_eng_or_ita has_non_russian
  finalize_audio_selection audio_map_args russian_tracks "$has_eng_or_ita" "$has_non_russian"

  # 3. Get list of subtitle streams (index,codec,disposition)
  local subtitle_indices_csv
  subtitle_indices_csv=$(ffprobe -v error -select_streams s \
    -show_entries stream=index,codec_name,disposition:default,forced \
    -of csv=p=0 "$src" < /dev/null 2>/dev/null || echo "")
    
  # 4. Build subtitle info manually (reliable)
  local subtitle_info=""
  if [[ -n "$subtitle_indices_csv" ]]; then
    while IFS=, read -r idx codec def forced; do
      local lang title
      lang=$(ffprobe -v error -select_streams "0:$idx" -show_entries stream=tags:language -of csv=p=0 "$src" < /dev/null 2>/dev/null || echo "und")
      title=$(ffprobe -v error -select_streams "0:$idx" -show_entries stream=tags:title -of csv=p=0 "$src" < /dev/null 2>/dev/null || echo "")
      # Construct CSV line: index,codec,lang,title,default,forced
      subtitle_info+="${idx},${codec},${lang:-und},${title},${def},${forced}"$'\n'
    done <<< "$subtitle_indices_csv"
  fi

  local internal_sub_count=0
  # Select internal subtitles to keep (populates SUBTITLE_SELECTION_MAP_ARGS)
  select_internal_subtitles "$subtitle_info"

  if [[ ${#SUBTITLE_SELECTION_MAP_ARGS[@]} -gt 0 ]]; then
    subtitle_map_args=("${SUBTITLE_SELECTION_MAP_ARGS[@]}")
  fi
  internal_sub_count="$SUBTITLE_INTERNAL_COUNT"

  # Subtitle discovery (check all supported extensions)
  local old_nullglob
  shopt -q nullglob && old_nullglob=1 || old_nullglob=0
  shopt -s nullglob

  for ext in srt ass sub; do
    # Match any file starting with the base name (e.g. "Movie.avi" -> "Movie*.srt")
    for s in "$src_full_dir/$base"*"$ext"; do
      [[ -f "$s" ]] && collect_subtitle "$s" "$base" sub_inputs sub_langs sub_forced sub_files sub_idx
    done
  done

  [[ "$old_nullglob" -eq 0 ]] && shopt -u nullglob

  # Build mapping args
  if (( sub_idx > 0 )); then
    for ((i=1; i<=sub_idx; i++)); do
      subtitle_map_args+=("-map" "$i:s:0")
      local lang="${sub_langs[$((i-1))]}"
      [[ -z "$lang" ]] && lang="unknown"
      local sub_file="${sub_files[$((i-1))]}"
      local codec_label; codec_label="$(basename "$sub_file")"
      codec_label="${codec_label##*.}"
      codec_label="$(to_lower "$codec_label")"
      [[ "$codec_label" == "srt" ]] && codec_label="subrip"
      [[ -z "$codec_label" ]] && codec_label="unknown"
      echo "  → Keeping subtitle track $i: $lang ($codec_label)"
    done
  fi

  if [[ "${#subtitle_map_args[@]}" -eq 0 ]]; then
    echo "  → No subtitles selected"
  fi

  local -a map_args=("-map" "0:v:0")
  if [[ ${#audio_map_args[@]} -gt 0 ]]; then
    map_args+=("${audio_map_args[@]}")
  fi
  if [[ ${#subtitle_map_args[@]} -gt 0 ]]; then
    map_args+=("${subtitle_map_args[@]}")
  fi

  # Build metadata args for subtitles
  local -a meta_args=()
  if (( sub_idx > 0 )); then
    for ((i=0; i<sub_idx; i++)); do
      local lang="${sub_langs[$i]}" forced="${sub_forced[$i]}"
      [[ -z "$forced" ]] && forced=0
      local sub_meta_index=$((internal_sub_count + i))
      [[ -n "$lang" ]] && meta_args+=("-metadata:s:s:${sub_meta_index}" "language=$lang")
      [[ -n "$lang" ]] && meta_args+=("-metadata:s:s:${sub_meta_index}" "title=Subtitle ($lang)")
      [[ "$forced" -eq 1 ]] && meta_args+=("-disposition:s:${sub_meta_index}" "forced")
    done
  fi

  # Container metadata
  meta_args+=("-metadata" "title=$base")

  # Remux vs transcode policy evaluation
  local video_bitrate_kbps filesize_mb height_num height_display
  video_bitrate_kbps=$(get_video_bitrate_kbps "$src")
  filesize_mb=$(get_filesize_mb "$src")
  height_num=0
  [[ "$height" =~ ^[0-9]+$ ]] && height_num="$height"
  if [[ "$height_num" -gt 0 ]]; then
    height_display="${height_num}p"
  else
    height_display="$height"
    [[ -z "$height_display" || "$height_display" == "?" ]] && height_display="unknown"
  fi

  local do_remux=1
  local -a transcode_reasons=()
  if ! is_codec_compatible_video "$vcodec" || ! is_codec_compatible_audio "$acodec"; then
    do_remux=0
    transcode_reasons+=("codec incompatibility (video=$vcodec audio=$acodec)")
  fi
  if [[ "$FORCE_TRANSCODE" -eq 1 ]]; then
    do_remux=0
    transcode_reasons+=("force-transcode enabled")
  fi
  if [[ "$MAX_VIDEO_BITRATE_KBPS" -gt 0 && "$video_bitrate_kbps" -gt "$MAX_VIDEO_BITRATE_KBPS" ]]; then
    do_remux=0
    transcode_reasons+=("bitrate threshold (${video_bitrate_kbps:-0} > $MAX_VIDEO_BITRATE_KBPS)")
  fi
  if [[ "$MAX_FILESIZE_MB" -gt 0 && "$filesize_mb" -gt "$MAX_FILESIZE_MB" ]]; then
    do_remux=0
    transcode_reasons+=("filesize threshold (${filesize_mb:-0} > $MAX_FILESIZE_MB)")
  fi
  if [[ "$TARGET_HEIGHT" -gt 0 && "$height_num" -gt "$TARGET_HEIGHT" ]]; then
    do_remux=0
    transcode_reasons+=("height threshold (${height_num:-0} > $TARGET_HEIGHT)")
  fi

  local profile_label="$PROFILE"
  [[ "$PROFILE" == "$DEFAULT_PROFILE" ]] && profile_label="$PROFILE (default)"
  echo "Profile: $profile_label"
  echo "Video bitrate: ${video_bitrate_kbps:-0} kbps | Filesize: ${filesize_mb:-0} MB | Height: $height_display"

  if [[ "$do_remux" -eq 1 ]]; then
    echo "→ Remuxing (all thresholds satisfied)"
  else
    local reason
    if [[ ${#transcode_reasons[@]} -gt 0 ]]; then
      for reason in "${transcode_reasons[@]}"; do
        echo "→ Transcoding due to $reason"
      done
    fi
  fi

  # Subtitle codec (copy ASS/SSA, convert SUB to SRT)
  local -a sub_codec_args=()
  if [[ "${#subtitle_map_args[@]}" -gt 0 ]]; then
    sub_codec_args=("-c:s" "copy")
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    echo "[DRY RUN] Would process: $src → $out (method: $([ $do_remux -eq 1 ] && echo remux || echo transcode))"
    return 0
  fi

  # Build base command safely for Bash 3
  local -a cmd_base=(ffmpeg -hide_banner -y -i "$src")
  if [[ ${#sub_inputs[@]} -gt 0 ]]; then
    cmd_base+=("${sub_inputs[@]}")
  fi
  cmd_base+=("${map_args[@]}")

  # Try REMUX first if possible
  if [[ "$do_remux" -eq 1 ]]; then
    echo "→ Attempting remux (no re-encoding)..."
    
    local -a remux_cmd=("${cmd_base[@]}")
    remux_cmd+=("-c" "copy")
    if [[ ${#sub_codec_args[@]} -gt 0 ]]; then
      remux_cmd+=("${sub_codec_args[@]}")
    fi
    remux_cmd+=("${meta_args[@]}" "$out")

    if run_ffmpeg "${remux_cmd[@]}"; then
      
      # Validate output
      if ffprobe -v error "$out" >/dev/null 2>&1; then
        touch -r "$src" "$out"
        echo "✓ Remux successful → $out"
        log_conversion "$src" "$out" "remux"
        
        if [[ "$DELETE" == "1" ]]; then
          if [[ ${#sub_files[@]} -gt 0 ]]; then
            rm -f "$src" "${sub_files[@]}"
          else
            rm -f "$src"
          fi
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
    echo "→ Transcoding per policy"
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
  local max_channels=2
  local best_acodec="unknown"

  # Scan all selected audio tracks to find max channels
  if [[ ${#audio_map_args[@]} -gt 0 ]]; then
    local i
    # Iterate skipping "-map" entries
    for ((i=1; i<${#audio_map_args[@]}; i+=2)); do
      local map_val="${audio_map_args[$i]}"
      local idx="${map_val#0:}"
      # Support both old relative "a:0" and new absolute "1" indices
      local spec="0:$idx"

      local ch=$(ffprobe -v error -select_streams "$spec" -show_entries stream=channels -of csv=p=0 "$src" 2>/dev/null || echo "2")
      local codec=$(ffprobe -v error -select_streams "$spec" -show_entries stream=codec_name -of default=nw=1:nk=1 "$src" 2>/dev/null || echo "unknown")
      
      # Sanitize channel count
      [[ -z "$ch" || ! "$ch" =~ ^[0-9]+$ ]] && ch=2
      
      # Debug logging
      echo "  → [Debug] Checking stream $spec: channels=$ch codec=$codec"

      if [[ "$ch" -gt "$max_channels" ]]; then
        max_channels="$ch"
        best_acodec="$codec"
      fi
    done
  fi

  local channels="$max_channels"
  local selected_acodec="$best_acodec"

  local -a audio_encode_args=()
  # Always downmix to stereo as requested
  if [[ "$channels" -gt 2 ]]; then
    echo "→ Downmixing multi-channel ($channels ch) to Stereo AAC (192k)"
  else
    echo "→ Encoding stereo to AAC (192k)"
  fi
  audio_encode_args=(-c:a aac -b:a 192k -ac 2)

  local -a filter_args=()
  if [[ "$TARGET_HEIGHT" -gt 0 && "$height_num" -gt "$TARGET_HEIGHT" ]]; then
    filter_args+=(-vf "scale=-2:${TARGET_HEIGHT}")
    echo "→ Scaling video to ${TARGET_HEIGHT}p maximum height"
  fi

  # Execute transcode
  local -a trans_cmd=("${cmd_base[@]}")
  trans_cmd+=("${encode_args[@]}")
  trans_cmd+=("${audio_encode_args[@]}")
  if [[ ${#filter_args[@]} -gt 0 ]]; then
    trans_cmd+=("${filter_args[@]}")
  fi
  if [[ ${#sub_codec_args[@]} -gt 0 ]]; then
    trans_cmd+=("${sub_codec_args[@]}")
  fi
  trans_cmd+=("${meta_args[@]}" "$out")

  if run_ffmpeg "${trans_cmd[@]}"; then
    
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
# shellcheck disable=SC2046
find_args=( $(build_find_pattern) )
set +f

if command -v parallel >/dev/null 2>&1 && [[ "$PARALLEL" -gt 1 ]]; then
  echo "Using GNU Parallel with $PARALLEL jobs"
  find "$SCAN_DIR" -type f \( "${find_args[@]}" \) -print0 | \
    parallel -0 -j "$PARALLEL" --bar process_one {}
else
  find "$SCAN_DIR" -type f \( "${find_args[@]}" \) -print0 | while IFS= read -r -d '' f; do
    process_one "$f" < /dev/null
  done
fi

echo ""
echo "════════════════════════════════════════"
echo "✓ All done! Output: $OUTROOT_PATH/"
exit 0
echo "  Log file: $LOGFILE"
echo "════════════════════════════════════════"
