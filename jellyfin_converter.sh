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
SCAN_DIR=""
OUTROOT="converted"
CRF="${CRF:-20}"              # Video quality (lower=better, 18-28 recommended)
PRESET="${PRESET:-medium}"    # x264 preset: ultrafast|fast|medium|slow|veryslow
CODEC="${CODEC:-h264}"        # h264 or hevc (hevc saves ~40% space)
HW_ACCEL="${HW_ACCEL:-auto}"  # auto|nvenc|qsv|vaapi|none
OVERWRITE="${OVERWRITE:-0}"   # 1 to overwrite existing outputs
DELETE="${DELETE:-1}"         # 1 to delete originals after success
PARALLEL="${PARALLEL:-1}"     # Number of simultaneous conversions
DRY_RUN="${DRY_RUN:-0}"       # 1 to test without converting
SKIP_DELETE_CONFIRM="${SKIP_DELETE_CONFIRM:-0}"  # 1 to skip delete confirmation (for automation)

# Dependency checks
need_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "ERROR: Missing required command: $1 ($2)" >&2; exit 1; }; }
need_cmd ffmpeg "install ffmpeg via your package manager"
need_cmd ffprobe "install ffprobe via your package manager (often bundled with ffmpeg)"
need_cmd find "install findutils/coreutils via your package manager"
echo "INFO: Hardware acceleration (nvenc/qsv/vaapi) requires appropriate GPU drivers"

# Codec compatibility checks
is_codec_compatible_video() { case "$1" in h264|hevc|av1) return 0 ;; *) return 1 ;; esac; }
is_codec_compatible_audio() { case "$1" in aac|ac3|eac3|mp3|flac|opus|dts) return 0 ;; *) return 1 ;; esac; }

# Language mapping with English/Italian focus
map_lang() {
  local t="${1,,}"
  case "$t" in
    en|eng|english) echo "eng" ;;
    it|ita|italian) echo "ita" ;;
    de|deu|ger|german) echo "deu" ;;
    fr|fra|fre|french) echo "fra" ;;
    es|spa|spanish) echo "spa" ;;
    pt|por|portuguese|br|ptbr|pt-br) echo "por" ;;
    nl|nld|dut|dutch) echo "nld" ;;
    pl|pol|polish) echo "pol" ;;
    tr|tur|turkish) echo "tur" ;;
    ru|rus|russian) echo "rus" ;;
    ar|ara|arabic) echo "ara" ;;
    ja|jpn|jp|japanese) echo "jpn" ;;
    ko|kor|korean) echo "kor" ;;
    zh|zho|chi|chinese|cn) echo "zho" ;;
    *) echo "" ;;
  esac
}

is_eng_or_ita() {
  local lang="$1"
  [[ "$lang" == "eng" || "$lang" == "ita" ]]
}

# Hardware acceleration detection
encoder_present() { ffmpeg -hide_banner -encoders 2>/dev/null | grep -q "$1"; }

detect_hw_accel() {
  if [[ -n "${RESOLVED_HW:-}" ]]; then
    echo "$RESOLVED_HW"
    return
  fi

  if [[ "$HW_ACCEL" == "auto" ]]; then
    if encoder_present "h264_nvenc"; then
      RESOLVED_HW="nvenc"
    elif encoder_present "h264_qsv"; then
      RESOLVED_HW="qsv"
    elif encoder_present "h264_vaapi"; then
      RESOLVED_HW="vaapi"
    else
      RESOLVED_HW="none"
    fi
  else
    RESOLVED_HW="$HW_ACCEL"
  fi

  echo "$RESOLVED_HW"
}

preflight_hw_encoder() {
  # Only verify when user explicitly selected a hardware accelerator
  if [[ "$HW_ACCEL" == "auto" || "$HW_ACCEL" == "none" ]]; then
    return
  fi

  local accel; accel=$(detect_hw_accel)
  local -a candidates=()

  case "$accel" in
    nvenc)
      if [[ "$CODEC" == "hevc" ]]; then
        candidates=("hevc_nvenc")
      else
        candidates=("h264_nvenc")
      fi
      ;;
    qsv)
      if [[ "$CODEC" == "hevc" ]]; then
        candidates=("hevc_qsv")
      else
        candidates=("h264_qsv")
      fi
      ;;
    vaapi)
      if [[ "$CODEC" == "hevc" ]]; then
        candidates=("hevc_vaapi" "h264_vaapi")
      else
        candidates=("h264_vaapi")
      fi
      ;;
    *)
      return
      ;;
  esac

  local encoder_found=0
  for enc in "${candidates[@]}"; do
    if encoder_present "$enc"; then
      encoder_found=1
      break
    fi
  done

  if [[ "$encoder_found" -eq 0 ]]; then
    echo "WARNING: HW_ACCEL=$HW_ACCEL requested, but encoders (${candidates[*]}) are unavailable. Falling back to software (HW_ACCEL=none)."
    RESOLVED_HW="none"
  else
    RESOLVED_HW="$accel"
  fi
}

check_write_permissions() {
  local target="$SCAN_DIR/$OUTROOT"
  local tmp_file="$target/.perm_test.$$"
  local log_probe="${LOGFILE}.permcheck"

  mkdir -p "$target" || {
    echo "ERROR: Cannot create output directory: $target (check permissions or disk space)"
    exit 3
  }

  if ! touch "$tmp_file" "$log_probe" 2>/dev/null; then
    echo "ERROR: Cannot write to $target (check permissions or available space)"
    exit 3
  fi

  if ! rm -f "$tmp_file" "$log_probe" 2>/dev/null; then
    echo "ERROR: Cannot clean up temp files in $target (check permissions)"
    exit 3
  fi
}

# Get optimal CRF based on resolution
get_optimal_crf() {
  local src="$1"
  local height=$(ffprobe -v error -select_streams v:0 \
    -show_entries stream=height -of csv=p=0 "$src" 2>/dev/null || echo "720")
  
  if [[ "$height" -ge 2160 ]]; then
    echo 22  # 4K
  elif [[ "$height" -ge 1080 ]]; then
    echo 20  # 1080p
  elif [[ "$height" -ge 720 ]]; then
    echo 21  # 720p
  else
    echo 23  # SD
  fi
}

# Logging
log_conversion() {
  local src="$1" out="$2" method="$3"
  local size_before size_after savings
  size_before=$(stat -f%z "$src" 2>/dev/null || stat -c%s "$src" 2>/dev/null || echo 0)
  size_after=$(stat -f%z "$out" 2>/dev/null || stat -c%s "$out" 2>/dev/null || echo 0)
  
  if [[ "$size_before" -gt 0 ]]; then
    savings=$(( (size_before - size_after) * 100 / size_before ))
  else
    savings=0
  fi
  
  printf "%s | %s | %s → %s | %d%% savings\n" \
    "$(date '+%Y-%m-%d %H:%M:%S')" "$method" "$src" "$out" "$savings" >> "$LOGFILE"
}

# Interactive folder selection
select_folder() {
  local default_path="${1:-.}"
  
  echo "════════════════════════════════════════"
  echo "  Folder Selection"
  echo "════════════════════════════════════════"
  echo ""
  echo "Current directory: $(pwd)"
  echo ""
  echo "Enter the folder to process:"
  echo "  - Full path (e.g., /media/videos)"
  echo "  - Relative path (e.g., ./movies)"
  echo "  - Press Enter to use current directory"
  echo ""
  read -r -p "Folder path: " input_path
  
  # Use current directory if empty
  if [[ -z "$input_path" ]]; then
    input_path="$default_path"
  fi
  
  # Expand ~ and resolve path
  input_path="${input_path/#\~/$HOME}"
  
  # Check if path exists
  if [[ ! -d "$input_path" ]]; then
    echo ""
    echo "ERROR: Directory does not exist: $input_path"
    echo ""
    read -r -p "Try again? (y/n): " retry
    if [[ "$retry" =~ ^[Yy] ]]; then
      select_folder "$default_path"
      return
    else
      exit 1
    fi
  fi
  
  # Convert to absolute path
  SCAN_DIR=$(cd "$input_path" && pwd)
  
  # Count video files
  local video_count=0
  local -a formats=(${VIDEO_FORMATS//|/ })
  for fmt in "${formats[@]}"; do
    video_count=$((video_count + $(find "$SCAN_DIR" -type f -iname "*.${fmt}" 2>/dev/null | wc -l)))
  done
  
  echo ""
  echo "Selected: $SCAN_DIR"
  echo "Found: $video_count video file(s)"
  echo ""
  
  if [[ "$video_count" -eq 0 ]]; then
    echo "WARNING: No supported video files found in this directory."
    echo "Supported formats: ${VIDEO_FORMATS//|/, }"
    echo ""
    read -r -p "Continue anyway? (y/n): " continue_empty
    if [[ ! "$continue_empty" =~ ^[Yy] ]]; then
      exit 0
    fi
  fi
  
  read -r -p "Proceed with this folder? (y/n): " confirm
  if [[ ! "$confirm" =~ ^[Yy] ]]; then
    echo "Cancelled."
    exit 0
  fi
  
  echo ""
}

process_one() {
  local src="$1"
  local rel="${src#$SCAN_DIR/}"
  local srcdir; srcdir="$(dirname "$rel")"
  local filename; filename="$(basename "$rel")"
  local base="${filename%.*}"
  local ext="${filename##*.}"
  local outdir="$OUTROOT/$srcdir"
  local out="$outdir/$base.mkv"

  mkdir -p "$outdir"
  
  # Skip if already MKV
  if [[ "${ext,,}" == "mkv" ]]; then
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
  echo "Source: $src [${ext^^}]"
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

  # Analyze audio streams for language filtering
  # Get both language and title info to detect commentary tracks
  local audio_info=$(ffprobe -v error -select_streams a -show_entries \
    stream=index:stream_tags=language,title -of csv=p=0 "$src" 2>/dev/null || echo "")
  
  local -a audio_map_args=()
  local -a russian_tracks=()  # Store Russian tracks as fallback
  local has_eng_or_ita=0
  local has_non_russian=0
  local audio_idx=0
  
  if [[ -n "$audio_info" ]]; then
    # First pass: identify what we have
    while IFS=, read -r idx lang title; do
      local mapped_lang=$(map_lang "$lang")
      local title_lower="${title,,}"
      
      # Check if this is a commentary track
      local is_commentary=0
      if [[ "$title_lower" =~ (commentary|commento|kommentar|comentario) ]]; then
        is_commentary=1
      fi
      
      if [[ "$is_commentary" -eq 1 ]]; then
        audio_map_args+=("-map" "0:a:$audio_idx")
        echo "  → Keeping audio track $audio_idx: commentary ($mapped_lang)"
      elif is_eng_or_ita "$mapped_lang"; then
        audio_map_args+=("-map" "0:a:$audio_idx")
        has_eng_or_ita=1
        has_non_russian=1
        echo "  → Keeping audio track $audio_idx: $mapped_lang"
      elif [[ "$mapped_lang" == "rus" ]]; then
        # Store Russian tracks for potential fallback
        russian_tracks+=("$audio_idx")
        echo "  ⚠ Russian track $audio_idx (will skip if other languages available)"
      elif [[ -n "$mapped_lang" ]]; then
        # Any other known language - prefer over Russian
        audio_map_args+=("-map" "0:a:$audio_idx")
        has_non_russian=1
        echo "  → Keeping audio track $audio_idx: $mapped_lang (non-Russian)"
      elif [[ -z "$mapped_lang" || "$lang" == "und" ]]; then
        # Unknown/undefined language - keep first one in case it's original
        if [[ "$audio_idx" -eq 0 ]]; then
          audio_map_args+=("-map" "0:a:$audio_idx")
          has_non_russian=1
          echo "  → Keeping audio track $audio_idx: unknown/original"
        fi
      fi
      ((audio_idx++))
    done <<< "$audio_info"
  fi
  
  # If no eng/ita and no other non-Russian languages found, use Russian as fallback
  if [[ "$has_eng_or_ita" -eq 0 && "$has_non_russian" -eq 0 && "${#russian_tracks[@]}" -gt 0 ]]; then
    echo "  → No non-Russian audio found, keeping Russian track(s) as fallback"
    for rus_idx in "${russian_tracks[@]}"; do
      audio_map_args+=("-map" "0:a:$rus_idx")
      echo "  → Keeping audio track $rus_idx: rus (fallback)"
    done
  elif [[ "${#russian_tracks[@]}" -gt 0 && "$has_non_russian" -eq 1 ]]; then
    for rus_idx in "${russian_tracks[@]}"; do
      echo "  × Skipping audio track $rus_idx: rus (other languages available)"
    done
  fi
  
  # If nothing was selected at all, keep all audio (safety fallback)
  if [[ "${#audio_map_args[@]}" -eq 0 ]]; then
    echo "  → No audio tracks selected, keeping all audio tracks"
    audio_map_args=("-map" "0:a?")
  fi

  # Get source directory for finding subtitles
  local src_full_dir; src_full_dir="$(dirname "$src")"

  # Collect external subtitles (English/Italian only)
  local -a sub_inputs=() sub_langs=() sub_forced=() sub_files=()
  local sub_idx=0
  
  add_sub() {
    local subfile="$1"
    local fname; fname="$(basename "$subfile")"
    local rest="${fname#${base}}"; rest="${rest#.}"; rest="${rest%.*}"
    local lang="" forced=0
    
    # Check for commentary in filename
    local rest_lower="${rest,,}"
    local is_commentary=0
    if [[ "$rest_lower" =~ (commentary|commento|kommentar|comentario) ]]; then
      is_commentary=1
    fi
    
    IFS='._- ' read -r -a tokens <<< "$rest"
    for tk in "${tokens[@]}"; do
      [[ -z "$lang" ]] && lang="$(map_lang "$tk")"
      [[ "$tk" =~ ^(forced|forzato|forzati|zwangs|obligatoire)$ ]] && forced=1
    done
    
    # Keep if commentary OR if English/Italian
    if [[ "$is_commentary" -eq 1 ]]; then
      echo "  + sub: $subfile  commentary lang=${lang:-unknown} forced=$forced"
      sub_inputs+=("-i" "$subfile")
      sub_langs+=("${lang:-und}")
      sub_forced+=("$forced")
      sub_files+=("$subfile")
      ((sub_idx++))
    elif is_eng_or_ita "$lang"; then
      echo "  + sub: $subfile  lang=$lang forced=$forced"
      sub_inputs+=("-i" "$subfile")
      sub_langs+=("$lang")
      sub_forced+=("$forced")
      sub_files+=("$subfile")
      ((sub_idx++))
    else
      echo "  × skipping sub: $subfile  lang=${lang:-unknown} (not eng/ita/commentary)"
    fi
  }
  
  (
    shopt -s nullglob
    for ext in srt ass sub; do
      for s in "$src_full_dir/$base".*."$ext" "$src_full_dir/$base"."$ext"; do
        [[ -f "$s" ]] && add_sub "$s"
      done
    done
  )

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
        encode_args=(-c:v hevc_qsv -preset medium -global_quality "$use_crf" -look_ahead 1)
        echo "→ Using Intel QuickSync (HEVC)"
      else
        encode_args=(-c:v h264_qsv -preset medium -global_quality "$use_crf" -look_ahead 1)
        echo "→ Using Intel QuickSync (H.264)"
      fi
      ;;
    vaapi)
      encode_args=(-vaapi_device /dev/dri/renderD128 -c:v h264_vaapi -qp "$use_crf")
      echo "→ Using VA-API (H.264)"
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
export -f detect_hw_accel get_optimal_crf log_conversion
export SCAN_DIR OUTROOT CRF PRESET CODEC HW_ACCEL RESOLVED_HW OVERWRITE DELETE DRY_RUN LOGFILE DONE_FILE

# Interactive folder selection (unless path provided as argument)
if [[ $# -gt 0 ]]; then
  SCAN_DIR="$1"
  if [[ ! -d "$SCAN_DIR" ]]; then
    echo "ERROR: Directory does not exist: $SCAN_DIR"
    exit 1
  fi
  SCAN_DIR=$(cd "$SCAN_DIR" && pwd)
else
  select_folder
fi

# Now set up log files after SCAN_DIR is determined
LOGFILE="$SCAN_DIR/$OUTROOT/conversion.log"
DONE_FILE="$SCAN_DIR/$OUTROOT/.processed"

mkdir -p "$SCAN_DIR/$OUTROOT"
[[ -f "$DONE_FILE" ]] || touch "$DONE_FILE"

check_write_permissions
touch "$LOGFILE"

preflight_hw_encoder

echo "════════════════════════════════════════"
echo "  Jellyfin Video → MKV Converter"
echo "════════════════════════════════════════"
echo "Scanning: $SCAN_DIR"
echo "Output: $SCAN_DIR/$OUTROOT/"
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
echo "Mode: dry=$DRY_RUN delete=$DELETE parallel=$PARALLEL"

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

# Build find command for all video formats
build_find_pattern() {
  local -a patterns=()
  IFS='|' read -ra formats <<< "$VIDEO_FORMATS"
  for fmt in "${formats[@]}"; do
    patterns+=("-iname" "*.${fmt}" "-o")
  done
  # Remove last -o
  unset 'patterns[-1]'
  echo "${patterns[@]}"
}

display_patterns() {
  local -a patterns=()
  IFS='|' read -ra formats <<< "$VIDEO_FORMATS"
  for fmt in "${formats[@]}"; do
    patterns+=("*.${fmt}")
  done
  echo "${patterns[*]}"
}

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
echo "✓ All done! Output: $SCAN_DIR/$OUTROOT/"
echo "  Log file: $LOGFILE"
echo "════════════════════════════════════════"
