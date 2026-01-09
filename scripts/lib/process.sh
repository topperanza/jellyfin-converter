#!/usr/bin/env bash
# Core processing logic for single file conversion

# Check if a sidecar file is safe to delete
# Returns 0 if safe, 1 if unsafe (ambiguous or claimed by others)
is_sidecar_safe_to_delete() {
  local sidecar="$1"
  local current_video="$2"
  
  # 1. Global toggle check
  if [[ "${DELETE_SIDECARS:-0}" != "1" ]]; then
    return 1
  fi
  
  local dir; dir="$(dirname "$sidecar")"
  
  # 2. Check for ambiguity/uniqueness
  # Iterate over all other video files in the same directory
  local other_video
  local found_other_claimant=0
  
  local old_nullglob
  shopt -q nullglob && old_nullglob=1 || old_nullglob=0
  shopt -s nullglob
  
  for other_video in "$dir"/*; do
    [[ -f "$other_video" ]] || continue
    [[ "$other_video" == "$current_video" ]] && continue
    
    # Check if it's a video file
    local ext; ext="$(to_lower "${other_video##*.}")"
    if [[ ! "$VIDEO_FORMATS" =~ $ext ]]; then
        continue
    fi
    
    if is_sidecar_match "$other_video" "$sidecar"; then
      echo "  ⚠ Sidecar ambiguous: matches other video $(basename "$other_video")"
      found_other_claimant=1
      break
    fi
  done
  
  [[ "$old_nullglob" -eq 0 ]] && shopt -u nullglob
  
  if [[ "$found_other_claimant" -eq 1 ]]; then
    return 1
  fi
  
  return 0
}

process_one() {
  local src="$1"
  # shellcheck disable=SC2034
  local -a sub_inputs=()
  local -a sub_files=()
  local -a subtitle_map_args=()
  local -a audio_map_args=()
  # shellcheck disable=SC2034
  local -a russian_tracks=()
  local has_eng_or_ita=0
  local has_non_russian=0
  local -a sub_inputs=() sub_files=()
  local rel="${src#"$SCAN_DIR"/}"
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
  
  local height; height=$(ffprobe -v error -select_streams v:0 \
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
      lang="$(normalize_lang "$lang")"
      title=$(ffprobe -v error -select_streams "0:$idx" -show_entries stream=tags:title -of csv=p=0 "$src" < /dev/null 2>/dev/null || echo "")
      # Construct CSV line: index,lang,title
      audio_info+="${idx},${lang},${title}"$'\n'
    done
  fi

  build_audio_map_args "$audio_info" audio_map_args russian_tracks has_eng_or_ita has_non_russian
  finalize_audio_selection audio_map_args russian_tracks "$has_eng_or_ita" "$has_non_russian"

  # Subtitle Selection (Phase 3: Unified Plan)
  local plan_lines
  plan_lines="$(build_subtitle_plan "$src")"

  # Debug: Print Subtitles if requested
  if [[ "${PRINT_SUBTITLES:-0}" -eq 1 ]]; then
    echo "========================================"
    echo "DEBUG: Subtitle Inventory & Plan"
    echo "Source: $src"
    echo "----------------------------------------"
    echo "Internal Subtitles (Raw Probe):"
    probe_internal_subs "$src" | sed 's/^/  /'
    echo "----------------------------------------"
    echo "External Subtitles (Discovered):"
    discover_external_subs "$src" | sed 's/^/  /'
    echo "----------------------------------------"
    echo "Selection Plan:"
    if [[ -n "$plan_lines" ]]; then
       # Plan format: source|id|lang|forced|codec|default
       # shellcheck disable=SC2001
       echo "$plan_lines" | sed 's/^/  /'
    else
       echo "  (No subtitles selected)"
    fi
    echo "========================================"
  fi
  
  local output_sub_idx=0
  local ext_input_idx=1  # 0 is video
  local -a meta_args=()
  
  if [[ -n "$plan_lines" ]]; then
    while IFS='|' read -r source id lang forced codec is_default; do
      [[ -z "$source" ]] && continue
      
      local is_forced=0; [[ "$forced" -eq 1 ]] && is_forced=1
      local is_def=0; [[ "$is_default" -eq 1 ]] && is_def=1
      local display_lang="${lang:-und}"
      
      if [[ "$source" == "int" ]]; then
        # Internal: id is stream index
        subtitle_map_args+=("-map" "0:$id")
        echo "  → Keeping internal subtitle $id: $display_lang ($codec) [forced=$is_forced default=$is_def]"
        
      elif [[ "$source" == "ext" ]]; then
        # External: id is file path
        sub_inputs+=("-i" "$id")
        sub_files+=("$id")
        subtitle_map_args+=("-map" "${ext_input_idx}:s:0")
        echo "  → Keeping external subtitle: $(basename "$id") [$display_lang] ($codec) [forced=$is_forced default=$is_def]"
        ((ext_input_idx+=1))
      fi
      
      # Metadata for output stream
      # We apply metadata to the corresponding output stream index
      meta_args+=("-metadata:s:s:$output_sub_idx" "language=$display_lang")
      meta_args+=("-metadata:s:s:$output_sub_idx" "title=Subtitle ($display_lang)")
      if [[ "$is_def" -eq 1 ]]; then
        meta_args+=("-disposition:s:$output_sub_idx" "default")
      elif [[ "$is_forced" -eq 1 ]]; then
        meta_args+=("-disposition:s:$output_sub_idx" "forced")
      else
        meta_args+=("-disposition:s:$output_sub_idx" "0")
      fi
      
      ((output_sub_idx+=1))
    done <<< "$plan_lines"
  else
    echo "  → No subtitles selected"
  fi

  local -a map_args=("-map" "0:v:0")
  if [[ ${#audio_map_args[@]} -gt 0 ]]; then
    map_args+=("${audio_map_args[@]}")
  fi
  if [[ ${#subtitle_map_args[@]} -gt 0 ]]; then
    map_args+=("${subtitle_map_args[@]}")
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
          local -a files_to_delete=("$src")
          
          if [[ ${#sub_files[@]} -gt 0 ]]; then
            for sub in "${sub_files[@]}"; do
              if is_sidecar_safe_to_delete "$sub" "$src"; then
                files_to_delete+=("$sub")
              else
                 echo "  ⚠ Keeping sidecar (safety check): $(basename "$sub")"
              fi
            done
          fi
          
          rm -f "${files_to_delete[@]}"
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
  local hw; hw=$(detect_hw_accel)
  local -a encode_args=()
  local optimal_crf; optimal_crf=$(get_optimal_crf "$src")
  local use_crf="${CRF:-$optimal_crf}"
  
  case "$hw" in
    nvenc)
      if [[ "${CODEC:-}" == "hevc" ]]; then
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
      if [[ "${CODEC:-}" == "hevc" ]]; then
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
  # local best_acodec="unknown"

  # Scan all selected audio tracks to find max channels
  if [[ ${#audio_map_args[@]} -gt 0 ]]; then
    local i
    # Iterate skipping "-map" entries
    for ((i=1; i<${#audio_map_args[@]}; i+=2)); do
      local map_val="${audio_map_args[$i]}"
      local idx="${map_val#0:}"
      # Support both old relative "a:0" and new absolute "1" indices
      local spec="0:$idx"

      local ch
      ch=$(ffprobe -v error -select_streams "$spec" -show_entries stream=channels -of csv=p=0 "$src" 2>/dev/null || echo "2")
      local codec
      codec=$(ffprobe -v error -select_streams "$spec" -show_entries stream=codec_name -of default=nw=1:nk=1 "$src" 2>/dev/null || echo "unknown")
      
      # Sanitize channel count
      [[ -z "$ch" || ! "$ch" =~ ^[0-9]+$ ]] && ch=2
      
      # Debug logging
      echo "  → [Debug] Checking stream $spec: channels=$ch codec=$codec"

      if [[ "$ch" -gt "$max_channels" ]]; then
        max_channels="$ch"
        # best_acodec="$codec"
      fi
    done
  fi

  local channels="$max_channels"
  # local selected_acodec="$best_acodec"

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
        local -a files_to_delete=("$src")
        
        if [[ ${#sub_files[@]} -gt 0 ]]; then
          for sub in "${sub_files[@]}"; do
            if is_sidecar_safe_to_delete "$sub" "$src"; then
              files_to_delete+=("$sub")
            else
               echo "  ⚠ Keeping sidecar (safety check): $(basename "$sub")"
            fi
          done
        fi
        
        rm -f "${files_to_delete[@]}"
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
