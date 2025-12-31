#!/usr/bin/env bash

LIB_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/compat.sh
source "$LIB_DIR/compat.sh"

# Language mapping with English/Italian focus
map_lang() {
  local t="$1"
  t="$(to_lower "$t")"
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

is_wanted_lang() {
  local lang="$1"
  local target="${SUB_LANGS:-eng,ita}"
  # Check if lang is in the comma-separated list
  if [[ ",$target," == *",$lang,"* ]]; then
    return 0
  fi
  return 1
}

is_eng_or_ita() {
  # Deprecated: use is_wanted_lang
  is_wanted_lang "$1"
}

is_commentary_title() {
  local title_lower="$1"
  title_lower="$(to_lower "$title_lower")"
  [[ "$title_lower" =~ (commentary|commento|kommentar|comentario) ]]
}

probe_internal_subs() {
  local src="$1"
  ffprobe -v error -select_streams s \
    -show_entries stream=index,codec_name:stream_tags=language,title:stream_disposition=default,forced,hearing_impaired \
    -of csv=p=0:s='|' "$src" < /dev/null 2>/dev/null || echo ""
}

is_text_codec() {
  local c
  c="$(to_lower "$1")"
  case "$c" in
    subrip|ass|ssa|mov_text|webvtt|microdvd|sami|subviewer|realtext) return 0 ;;
    *) return 1 ;;
  esac
}

is_bitmap_codec() {
  local c
  c="$(to_lower "$1")"
  case "$c" in
    hdmv_pgs_subtitle|dvdsub|xsub|dvb_subtitle|pgssub) return 0 ;;
    *) return 1 ;;
  esac
}

if have_bash_ge_4; then
  build_audio_map_args() {
    local audio_info="$1"
    local -n out_map_args="$2"
    local -n out_russian_tracks="$3"
    local -n out_has_eng_or_ita="$4"
    local -n out_has_non_russian="$5"

    out_map_args=()
    out_russian_tracks=()
    out_has_eng_or_ita=0
    out_has_non_russian=0

    local audio_idx=0
    if [[ -n "$audio_info" ]]; then
      while IFS=, read -r idx lang title; do
        [[ -z "$idx" ]] && continue
        local mapped_lang; mapped_lang=$(map_lang "$lang")
        local is_commentary=0
        is_commentary_title "$title" && is_commentary=1

        if [[ "$is_commentary" -eq 1 ]]; then
          out_map_args+=("-map" "0:$idx")
          echo "  → Keeping audio track $idx: commentary ($mapped_lang)"
        elif is_eng_or_ita "$mapped_lang"; then
          out_map_args+=("-map" "0:$idx")
          out_has_eng_or_ita=1
          out_has_non_russian=1
          echo "  → Keeping audio track $idx: $mapped_lang"
        elif [[ "$mapped_lang" == "rus" ]]; then
          out_russian_tracks+=("$idx")
          echo "  ⚠ Russian track $idx (will skip if other languages available)"
        elif [[ -n "$mapped_lang" ]]; then
          out_map_args+=("-map" "0:$idx")
          out_has_non_russian=1
          echo "  → Keeping audio track $idx: $mapped_lang (non-Russian)"
        elif [[ -z "$mapped_lang" || "$lang" == "und" ]]; then
          out_map_args+=("-map" "0:$idx")
          out_has_non_russian=1
          echo "  → Keeping audio track $idx: unknown (preserving)"
        fi
        ((audio_idx+=1))
      done <<< "$audio_info" || true
    fi

    return 0
  }

  finalize_audio_selection() {
    local -n _audio_map_args="$1"
    local -n _russian_tracks="$2"
    local has_eng_or_ita="$3"
    local has_non_russian="$4"

    if [[ "$has_eng_or_ita" -eq 0 && "$has_non_russian" -eq 0 && "${#_russian_tracks[@]}" -gt 0 ]]; then
      echo "  → No non-Russian audio found, keeping Russian track(s) as fallback"
      for rus_idx in "${_russian_tracks[@]}"; do
        _audio_map_args+=("-map" "0:$rus_idx")
        echo "  → Keeping audio track $rus_idx: rus (fallback)"
      done
    elif [[ "${#_russian_tracks[@]}" -gt 0 && "$has_non_russian" -eq 1 ]]; then
      for rus_idx in "${_russian_tracks[@]}"; do
        echo "  × Skipping audio track $rus_idx: rus (other languages available)"
      done
    fi

    if [[ "${#_audio_map_args[@]}" -eq 0 ]]; then
      echo "  → No audio tracks selected, keeping all audio tracks"
      _audio_map_args=("-map" "0:a?")
    fi
  }

  collect_subtitle() {
    local subfile="$1"
    local base="$2"
    local _sub_inputs="$3"
    local _sub_langs="$4"
    local _sub_forced="$5"
    local _sub_files="$6"
    local _sub_idx="$7"

    local fname; fname="$(basename "$subfile")"
    # Remove the base filename prefix
    local rest="${fname#"${base}"}"
    # Remove extension
    rest="${rest%.*}"
    
    local lang="" forced=0

    local rest_lower="$rest"
    rest_lower="$(to_lower "$rest_lower")"
    local is_commentary=0
    is_commentary_title "$rest_lower" && is_commentary=1

    # Split by common delimiters: dot, underscore, dash, space, parens, brackets
    IFS='._- ()[]' read -r -a tokens <<< "$rest"
    for tk in "${tokens[@]}"; do
      [[ -z "$tk" ]] && continue
      [[ -z "$lang" ]] && lang="$(map_lang "$tk")"
      [[ "$tk" =~ ^(forced|forzato|forzati|zwangs|obligatoire)$ ]] && forced=1
    done

    local should_add=0
    local target_lang="${lang:-und}"

    if [[ "$is_commentary" -eq 1 ]]; then
      echo "  + sub: $subfile  commentary lang=$target_lang forced=$forced"
      should_add=1
    elif is_eng_or_ita "$lang"; then
      target_lang="$lang"
      echo "  + sub: $subfile  lang=$target_lang forced=$forced"
      should_add=1
    else
      echo "  × skipping sub: $subfile  lang=${lang:-unknown} (not eng/ita/commentary)"
    fi

    if [[ "$should_add" -eq 1 ]]; then
      local safe_subfile safe_lang safe_forced
      printf -v safe_subfile %q "$subfile"
      printf -v safe_lang %q "$target_lang"
      printf -v safe_forced %q "$forced"

      eval "${_sub_inputs}+=(\"-i\" $safe_subfile)"
      eval "${_sub_langs}+=($safe_lang)"
      eval "${_sub_forced}+=($safe_forced)"
      eval "${_sub_files}+=($safe_subfile)"
      eval "${_sub_idx}=\$((\${${_sub_idx}} + 1))"
    fi
  }
else
  # shellcheck disable=SC2128,SC2178,SC2154
  build_audio_map_args() {
    local audio_info="$1"
    local out_map_args="$2"
    local out_russian_tracks="$3"
    local out_has_eng_or_ita="$4"
    local out_has_non_russian="$5"

    eval "$out_map_args=()"
    eval "$out_russian_tracks=()"
    eval "$out_has_eng_or_ita=0"
    eval "$out_has_non_russian=0"

    local audio_idx=0
    if [[ -n "$audio_info" ]]; then
      while IFS=, read -r idx lang title; do
        [[ -z "$idx" ]] && continue
        local mapped_lang; mapped_lang=$(map_lang "$lang")
        local is_commentary=0
        is_commentary_title "$title" && is_commentary=1

        if [[ "$is_commentary" -eq 1 ]]; then
          eval "$out_map_args+=(\"-map\" \"0:$idx\")"
          echo "  → Keeping audio track $idx: commentary ($mapped_lang)"
        elif is_eng_or_ita "$mapped_lang"; then
          eval "$out_map_args+=(\"-map\" \"0:$idx\")"
          eval "$out_has_eng_or_ita=1"
          eval "$out_has_non_russian=1"
          echo "  → Keeping audio track $idx: $mapped_lang"
        elif [[ "$mapped_lang" == "rus" ]]; then
          eval "$out_russian_tracks+=(\"$idx\")"
          echo "  ⚠ Russian track $idx (will skip if other languages available)"
        elif [[ -n "$mapped_lang" ]]; then
          eval "$out_map_args+=(\"-map\" \"0:$idx\")"
          eval "$out_has_non_russian=1"
          echo "  → Keeping audio track $idx: $mapped_lang (non-Russian)"
        elif [[ -z "$mapped_lang" || "$lang" == "und" ]]; then
          eval "$out_map_args+=(\"-map\" \"0:$idx\")"
          eval "$out_has_non_russian=1"
          echo "  → Keeping audio track $idx: unknown (preserving)"
        fi
        ((audio_idx+=1))
      done <<< "$audio_info" || true
    fi

    return 0
  }

  # shellcheck disable=SC2128,SC2178,SC2154
  finalize_audio_selection() {
    local _audio_map_args="$1"
    local _russian_tracks="$2"
    local has_eng_or_ita="$3"
    local has_non_russian="$4"

    eval "local rus_len=\${#${_russian_tracks}[@]}"
    if [[ "$has_eng_or_ita" -eq 0 && "$has_non_russian" -eq 0 && "$rus_len" -gt 0 ]]; then
      echo "  → No non-Russian audio found, keeping Russian track(s) as fallback"
      eval "local rus_tracks=(\"\${${_russian_tracks}[@]}\")"
      for rus_idx in "${rus_tracks[@]}"; do
        eval "${_audio_map_args}+=(\"-map\" \"0:${rus_idx}\")"
        echo "  → Keeping audio track ${rus_idx}: rus (fallback)"
      done
    elif [[ "$rus_len" -gt 0 && "$has_non_russian" -eq 1 ]]; then
      eval "local rus_tracks_skip=(\"\${${_russian_tracks}[@]}\")"
      for rus_idx in "${rus_tracks_skip[@]}"; do
        echo "  × Skipping audio track ${rus_idx}: rus (other languages available)"
      done
    fi

    eval "local map_len=\${#${_audio_map_args}[@]}"
    if [[ "$map_len" -eq 0 ]]; then
      echo "  → No audio tracks selected, keeping all audio tracks"
      eval "${_audio_map_args}=(\"-map\" \"0:a?\")"
    fi
  }

  collect_subtitle() {
    local subfile="$1"
    local base="$2"
    local _sub_inputs="$3"
    local _sub_langs="$4"
    local _sub_forced="$5"
    local _sub_files="$6"
    local _sub_idx="$7"

    local fname; fname="$(basename "$subfile")"
    # Remove the base filename prefix
    local rest="${fname#"${base}"}"
    # Remove extension
    rest="${rest%.*}"
    
    local lang="" forced=0

    local rest_lower="$rest"
    rest_lower="$(to_lower "$rest_lower")"
    local is_commentary=0
    is_commentary_title "$rest_lower" && is_commentary=1

    # Split by common delimiters: dot, underscore, dash, space, parens, brackets, quotes
    # Note: We use mixed quoting to include both single and double quotes in IFS
    IFS='._- ()[]"'"'" read -r -a tokens <<< "$rest"
    for tk in "${tokens[@]}"; do
      [[ -z "$tk" ]] && continue
      [[ -z "$lang" ]] && lang="$(map_lang "$tk")"
      [[ "$tk" =~ ^(forced|forzato|forzati|zwangs|obligatoire)$ ]] && forced=1
    done

    if [[ "$is_commentary" -eq 1 ]]; then
      echo "  + sub: $subfile  commentary lang=${lang:-unknown} forced=$forced"
      printf -v safe_subfile %q "$subfile"
      printf -v safe_lang %q "${lang:-und}"
      eval "${_sub_inputs}+=(\"-i\" $safe_subfile)"
      eval "${_sub_langs}+=($safe_lang)"
      eval "${_sub_forced}+=(\"$forced\")"
      eval "${_sub_files}+=($safe_subfile)"
      eval "$_sub_idx=$((_sub_idx+1))"
    elif is_eng_or_ita "$lang"; then
      echo "  + sub: $subfile  lang=$lang forced=$forced"
      printf -v safe_subfile %q "$subfile"
      printf -v safe_lang %q "$lang"
      eval "${_sub_inputs}+=(\"-i\" $safe_subfile)"
      eval "${_sub_langs}+=($safe_lang)"
      eval "${_sub_forced}+=(\"$forced\")"
      eval "${_sub_files}+=($safe_subfile)"
      eval "$_sub_idx=$((_sub_idx+1))"
    else
      echo "  × skipping sub: $subfile  lang=${lang:-unknown} (not eng/ita/commentary)"
    fi
  }
fi

SUBTITLE_SELECTION_MAP_ARGS=()
SUBTITLE_INTERNAL_COUNT=0

select_internal_subtitles() {
  local subtitle_info="$1"

  SUBTITLE_SELECTION_MAP_ARGS=()
  SUBTITLE_INTERNAL_COUNT=0
  SUBTITLE_SELECTED_INDEXES=""

  local ranks_buf=""

  if [[ -n "$subtitle_info" ]]; then
    while IFS= read -r __line__; do
      [[ -z "$__line__" ]] && continue
      local __sep__=","
      [[ "$__line__" == *"|"* ]] && __sep__="|"
      # shellcheck disable=SC2034
      IFS="$__sep__" read -r sub_stream_idx sub_codec sub_lang sub_title sub_default sub_forced sub_hi <<< "$__line__"
      [[ -z "$sub_stream_idx" || ! "$sub_stream_idx" =~ ^[0-9]+$ ]] && continue
      local mapped_lang; mapped_lang="$(map_lang "$sub_lang")"
      local is_commentary=0; is_commentary_title "$sub_title" && is_commentary=1
      local is_forced=0; [[ "${sub_forced:-0}" =~ ^[0-9]+$ ]] && [[ "${sub_forced:-0}" -gt 0 ]] && is_forced=1
      local is_default=0; [[ "${sub_default:-0}" =~ ^[0-9]+$ ]] && [[ "${sub_default:-0}" -gt 0 ]] && is_default=1
      local text_flag=0; is_text_codec "$sub_codec" && text_flag=1
      local bitmap_flag=0; is_bitmap_codec "$sub_codec" && bitmap_flag=1
      local lang_score=2
      [[ "$mapped_lang" == "eng" ]] && lang_score=0
      [[ "$mapped_lang" == "ita" ]] && lang_score=1
      local forced_score=$(( is_forced == 1 ? 0 : 1 ))
      local default_score=$(( is_default == 1 ? 0 : 1 ))
      local codec_score=1
      [[ "$text_flag" -eq 1 ]] && codec_score=0
      [[ "$bitmap_flag" -eq 1 ]] && codec_score=1
      local commentary_score=0
      [[ "$is_commentary" -eq 1 ]] && commentary_score=-1
      local rank=$(( commentary_score*10000 + lang_score*1000 + forced_score*100 + default_score*10 + codec_score ))
      local display_lang="$mapped_lang"; [[ -z "$display_lang" && -n "$sub_lang" ]] && display_lang="$sub_lang"; [[ -z "$display_lang" ]] && display_lang="unknown"
      local codec_label="$sub_codec"; [[ -z "$codec_label" ]] && codec_label="unknown"
      ranks_buf+="${rank}|${sub_stream_idx}|${display_lang}|${codec_label}|${is_forced}|${is_default}|${is_commentary}"$'\n'
    done <<< "$subtitle_info"
  fi

  local ENG_NORMAL=0 ENG_FORCED=0 ITA_NORMAL=0 ITA_FORCED=0
  local chosen=""
  if [[ -n "$ranks_buf" ]]; then
    while IFS='|' read -r rank idx lang codec is_forced is_default is_commentary; do
      [[ -z "$idx" ]] && continue
      if [[ " $chosen " == *" $idx "* ]]; then
        continue
      fi
      local mapped="$lang"
      [[ "$mapped" == "english" || "$mapped" == "en" ]] && mapped="eng"
      [[ "$mapped" == "italian" || "$mapped" == "it" ]] && mapped="ita"

      if [[ "$is_commentary" -eq 1 ]]; then
        SUBTITLE_SELECTION_MAP_ARGS+=("-map" "0:$idx")
        ((SUBTITLE_INTERNAL_COUNT+=1))
        SUBTITLE_SELECTED_INDEXES+=" $idx"
        chosen+=" $idx"
        echo "  → Keeping subtitle track $idx: commentary ($codec)"
        continue
      fi
      if [[ "$mapped" == "eng" ]]; then
        if [[ "$is_forced" -eq 1 && "$ENG_FORCED" -eq 0 ]]; then
          SUBTITLE_SELECTION_MAP_ARGS+=("-map" "0:$idx"); ((SUBTITLE_INTERNAL_COUNT+=1)); SUBTITLE_SELECTED_INDEXES+=" $idx"; chosen+=" $idx"; ENG_FORCED=1
          echo "  → Keeping subtitle track $idx: eng ($codec)"
        elif [[ "$is_forced" -eq 0 && "$ENG_NORMAL" -eq 0 ]]; then
          SUBTITLE_SELECTION_MAP_ARGS+=("-map" "0:$idx"); ((SUBTITLE_INTERNAL_COUNT+=1)); SUBTITLE_SELECTED_INDEXES+=" $idx"; chosen+=" $idx"; ENG_NORMAL=1
          echo "  → Keeping subtitle track $idx: eng ($codec)"
        fi
        continue
      elif [[ "$mapped" == "ita" ]]; then
        if [[ "$is_forced" -eq 1 && "$ITA_FORCED" -eq 0 ]]; then
          SUBTITLE_SELECTION_MAP_ARGS+=("-map" "0:$idx"); ((SUBTITLE_INTERNAL_COUNT+=1)); SUBTITLE_SELECTED_INDEXES+=" $idx"; chosen+=" $idx"; ITA_FORCED=1
          echo "  → Keeping subtitle track $idx: ita ($codec)"
        elif [[ "$is_forced" -eq 0 && "$ITA_NORMAL" -eq 0 ]]; then
          SUBTITLE_SELECTION_MAP_ARGS+=("-map" "0:$idx"); ((SUBTITLE_INTERNAL_COUNT+=1)); SUBTITLE_SELECTED_INDEXES+=" $idx"; chosen+=" $idx"; ITA_NORMAL=1
          echo "  → Keeping subtitle track $idx: ita ($codec)"
        fi
        continue
      else
        if [[ "$is_forced" -eq 1 ]]; then
          SUBTITLE_SELECTION_MAP_ARGS+=("-map" "0:$idx")
          ((SUBTITLE_INTERNAL_COUNT+=1))
          SUBTITLE_SELECTED_INDEXES+=" $idx"
          chosen+=" $idx"
          echo "  → Keeping subtitle track $idx: $lang ($codec) [forced]"
        fi
      fi
    done < <(printf '%s' "$ranks_buf" | sort -t '|' -k1,1n -k2,2n)
  fi

  if [[ "$SUBTITLE_INTERNAL_COUNT" -eq 0 && -n "$ranks_buf" ]]; then
    # Fallback: Pick the highest ranked track (first in sorted list)
    local first_line
    first_line=$(printf '%s' "$ranks_buf" | sort -t '|' -k1,1n -k2,2n | head -n1)
    if [[ -n "$first_line" ]]; then
      # shellcheck disable=SC2034
      IFS='|' read -r rank idx lang codec is_forced is_default is_commentary <<< "$first_line"
      SUBTITLE_SELECTION_MAP_ARGS+=("-map" "0:$idx")
      ((SUBTITLE_INTERNAL_COUNT+=1))
      SUBTITLE_SELECTED_INDEXES+=" $idx"
      echo "  → Keeping subtitle track $idx: $lang ($codec) [fallback]"
    fi
  fi
}

discover_external_subs() {
  local video="$1"
  local dir; dir="$(dirname "$video")"
  local fname; fname="$(basename "$video")"
  local base="${fname%.*}"
  local prefer_sdh="${PREFER_SDH:-0}"

  local old_nullglob
  shopt -q nullglob && old_nullglob=1 || old_nullglob=0
  shopt -s nullglob

  local candidates=""
  local f stem rest ext lang forced sdh commentary
  for f in "$dir/$base"*; do
    [[ -f "$f" ]] || continue
    ext="$(to_lower "${f##*.}")"
    case "$ext" in
      srt|ass|ssa|vtt) ;;
      *) continue ;;
    esac
    stem="$(basename "$f")"; stem="${stem%.*}"
    if [[ "$stem" == "$base" ]]; then
      rest=""
    elif [[ "$stem" == "$base"* ]]; then
      local next_char="${stem:${#base}:1}"
      case "$next_char" in
        .|_|-|\ |\(|\)|\[|\]) ;;
        *) continue ;;
      esac
      rest="${stem:${#base}}"
    else
      continue
    fi
    lang=""; forced=0; sdh=0; commentary=0
    local lower="$rest"; lower="$(to_lower "$lower")"
    IFS='._- ()[]' read -r -a __tokens <<< "$rest"
    local tk
    for tk in "${__tokens[@]}"; do
      [[ -z "$tk" ]] && continue
      [[ -z "$lang" ]] && lang="$(map_lang "$tk")"
      case "$(to_lower "$tk")" in
        forced|forzato|forzati|zwangs|obligatoire) forced=1 ;;
        sdh|cc|hi|hearing|hearingimpaired|hearing-impaired|hearing_impaired) sdh=1 ;;
        commentary|commento|kommentar|comentario) commentary=1 ;;
      esac
    done
    [[ -z "$lang" ]] && lang="und"
    candidates+="${f}|${lang}|${forced}|${sdh}|${commentary}|${ext}"$'\n'
  done

  [[ "$old_nullglob" -eq 0 ]] && shopt -u nullglob

  if [[ -z "$candidates" ]]; then
    return 0
  fi

  printf '%s' "$candidates"
}

build_subtitle_plan() {
  local video="$1"
  
  # 1. Gather Candidates
  local internal_raw
  internal_raw="$(probe_internal_subs "$video")"
  
  local external_raw
  external_raw="$(discover_external_subs "$video")"
  
  local combined_list=""
  
  # Parse Internal
  # Format: index|codec|lang|title|default|forced|hearing_impaired
  if [[ -n "$internal_raw" ]]; then
    while IFS='|' read -r idx codec lang title def forced sdh; do
      [[ -z "$idx" ]] && continue
      local mapped_lang; mapped_lang="$(map_lang "$lang")"
      local is_comm=0; is_commentary_title "$title" && is_comm=1
      local is_forced=0; [[ "${forced:-0}" -eq 1 ]] && is_forced=1
      local is_sdh=0; [[ "${sdh:-0}" -eq 1 ]] && is_sdh=1
      local is_def=0; [[ "${def:-0}" -eq 1 ]] && is_def=1
      
      # source|id|lang|forced|sdh|commentary|codec|default
      combined_list+="int|${idx}|${mapped_lang}|${is_forced}|${is_sdh}|${is_comm}|${codec}|${is_def}"$'\n'
    done <<< "$internal_raw"
  fi
  
  # Parse External
  # Format: path|lang|forced|sdh|commentary|ext
  if [[ -n "$external_raw" ]]; then
    while IFS='|' read -r path lang forced sdh comm ext; do
      [[ -z "$path" ]] && continue
      # source|id|lang|forced|sdh|commentary|codec|default
      combined_list+="ext|${path}|${lang}|${forced}|${sdh}|${comm}|${ext}|0"$'\n'
    done <<< "$external_raw"
  fi
  
  [[ -z "$combined_list" ]] && return 0
  
  # 2. Score Candidates
  local ranked_list=""
  local prefer_sdh="${PREFER_SDH:-0}"
  
  while IFS='|' read -r source id lang forced sdh comm codec def; do
    [[ -z "$source" ]] && continue
    
    # Calculate Score (Lower is better)
    local score=0
    
    # Origin Score (External Text > Internal Text > Bitmap)
    # External is always text (filtered by discover_external_subs)
    # Internal can be text or bitmap
    if [[ "$source" == "ext" ]]; then
      if [[ "${PREFER_EXTERNAL_SUBS:-1}" == "1" ]]; then
        score=$((score + 0))
      else
        score=$((score + 100))
      fi
    else
      if is_text_codec "$codec"; then
        score=$((score + 100))
      else
        if [[ "${KEEP_BITMAP_SUBS:-1}" == "0" ]]; then
             continue # Skip this candidate
        fi
        score=$((score + 200))
      fi
    fi
    
    # SDH Score
    if [[ "$prefer_sdh" -eq 1 ]]; then
      [[ "$sdh" -eq 0 ]] && score=$((score + 50))
    else
      [[ "$sdh" -eq 1 ]] && score=$((score + 50))
    fi
    
    # Codec Specific Score (Tie-breaker for external mainly)
    case "$codec" in
      srt|subrip) score=$((score + 0)) ;;
      vtt|webvtt) score=$((score + 10)) ;;
      ass|ssa) score=$((score + 20)) ;;
      *) score=$((score + 30)) ;;
    esac
    
    # Default Score (Internal tie-breaker)
    [[ "$def" -eq 1 ]] && score=$((score - 5))
    
    # Rank line: score|source|id|lang|forced|sdh|comm|codec
    ranked_list+="${score}|${source}|${id}|${lang}|${forced}|${sdh}|${comm}|${codec}"$'\n'
  done <<< "$combined_list"
  
  # 3. Select Winners
  # Slots:
  # - Commentary: Keep all (or follow policy)
  # - Eng/Ita: 1 Normal, 1 Forced
  # - Others: 1 Forced
  
  local CHOSEN_KEYS=""
  local DEFAULT_ASSIGNED=0
  
  # Sort by score ascending, then by source descending (int before ext on ties)
  local sorted_list
  sorted_list="$(echo "$ranked_list" | sort -t '|' -k1,1n -k2,2r)"
  
  while IFS='|' read -r score source id lang forced sdh comm codec; do
    [[ -z "$score" ]] && continue
    
    local keep=0
    
    if [[ "$comm" -eq 1 ]]; then
      keep=1 # Always keep commentary
    elif is_wanted_lang "$lang"; then
      local key_forc="${lang}_forc"
      local key_norm="${lang}_norm"
      
      if [[ "$forced" -eq 1 ]]; then
        if [[ "$CHOSEN_KEYS" != *"$key_forc"* ]]; then
           CHOSEN_KEYS+="$key_forc "
           keep=1
        fi
      else
        if [[ "$CHOSEN_KEYS" != *"$key_norm"* ]]; then
           CHOSEN_KEYS+="$key_norm "
           keep=1
        fi
      fi
    else
      # Other languages: Keep forced only
      if [[ "$forced" -eq 1 ]]; then
         local key="${lang}_forc"
         if [[ "$CHOSEN_KEYS" != *"$key"* ]]; then
           CHOSEN_KEYS+="$key "
           keep=1
         fi
      fi
    fi
    
    if [[ "$keep" -eq 1 ]]; then
      local is_default=0
      # Apply default disposition if requested and it's a normal track (not forced/commentary)
      if [[ "${MARK_NORMAL_SUB_DEFAULT:-0}" == "1" && "$forced" -eq 0 && "$comm" -eq 0 && "$DEFAULT_ASSIGNED" -eq 0 ]]; then
        is_default=1
        DEFAULT_ASSIGNED=1
      fi
      # Output: source|id|lang|forced|codec|is_default
      echo "${source}|${id}|${lang}|${forced}|${codec}|${is_default}"
    fi
  done <<< "$sorted_list"
}
