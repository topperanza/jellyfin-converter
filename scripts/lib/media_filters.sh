#!/usr/bin/env bash

LIB_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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

is_eng_or_ita() {
  local lang="$1"
  [[ "$lang" == "eng" || "$lang" == "ita" ]]
}

is_commentary_title() {
  local title_lower="$1"
  title_lower="$(to_lower "$title_lower")"
  [[ "$title_lower" =~ (commentary|commento|kommentar|comentario) ]]
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
        local mapped_lang; mapped_lang=$(map_lang "$lang")
        local is_commentary=0
        is_commentary_title "$title" && is_commentary=1

        if [[ "$is_commentary" -eq 1 ]]; then
          out_map_args+=("-map" "0:a:$audio_idx")
          echo "  → Keeping audio track $audio_idx: commentary ($mapped_lang)"
        elif is_eng_or_ita "$mapped_lang"; then
          out_map_args+=("-map" "0:a:$audio_idx")
          out_has_eng_or_ita=1
          out_has_non_russian=1
          echo "  → Keeping audio track $audio_idx: $mapped_lang"
        elif [[ "$mapped_lang" == "rus" ]]; then
          out_russian_tracks+=("$audio_idx")
          echo "  ⚠ Russian track $audio_idx (will skip if other languages available)"
        elif [[ -n "$mapped_lang" ]]; then
          out_map_args+=("-map" "0:a:$audio_idx")
          out_has_non_russian=1
          echo "  → Keeping audio track $audio_idx: $mapped_lang (non-Russian)"
        elif [[ -z "$mapped_lang" || "$lang" == "und" ]]; then
          out_map_args+=("-map" "0:a:$audio_idx")
          out_has_non_russian=1
          echo "  → Keeping audio track $audio_idx: unknown (preserving)"
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
        _audio_map_args+=("-map" "0:a:$rus_idx")
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
    local -n _sub_inputs="$3"
    local -n _sub_langs="$4"
    local -n _sub_forced="$5"
    local -n _sub_files="$6"
    local -n _sub_idx="$7"

    local fname; fname="$(basename "$subfile")"
    # Remove the base filename prefix
    local rest="${fname#${base}}"
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

    if [[ "$is_commentary" -eq 1 ]]; then
      echo "  + sub: $subfile  commentary lang=${lang:-unknown} forced=$forced"
      _sub_inputs+=("-i" "$subfile")
      _sub_langs+=("${lang:-und}")
      _sub_forced+=("$forced")
      _sub_files+=("$subfile")
      ((_sub_idx+=1))
    elif is_eng_or_ita "$lang"; then
      echo "  + sub: $subfile  lang=$lang forced=$forced"
      _sub_inputs+=("-i" "$subfile")
      _sub_langs+=("$lang")
      _sub_forced+=("$forced")
      _sub_files+=("$subfile")
      ((_sub_idx+=1))
    else
      echo "  × skipping sub: $subfile  lang=${lang:-unknown} (not eng/ita/commentary)"
    fi
  }
else
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
        local mapped_lang; mapped_lang=$(map_lang "$lang")
        local is_commentary=0
        is_commentary_title "$title" && is_commentary=1

        if [[ "$is_commentary" -eq 1 ]]; then
          eval "$out_map_args+=(\"-map\" \"0:a:$audio_idx\")"
          echo "  → Keeping audio track $audio_idx: commentary ($mapped_lang)"
        elif is_eng_or_ita "$mapped_lang"; then
          eval "$out_map_args+=(\"-map\" \"0:a:$audio_idx\")"
          eval "$out_has_eng_or_ita=1"
          eval "$out_has_non_russian=1"
          echo "  → Keeping audio track $audio_idx: $mapped_lang"
        elif [[ "$mapped_lang" == "rus" ]]; then
          eval "$out_russian_tracks+=(\"$audio_idx\")"
          echo "  ⚠ Russian track $audio_idx (will skip if other languages available)"
        elif [[ -n "$mapped_lang" ]]; then
          eval "$out_map_args+=(\"-map\" \"0:a:$audio_idx\")"
          eval "$out_has_non_russian=1"
          echo "  → Keeping audio track $audio_idx: $mapped_lang (non-Russian)"
        elif [[ -z "$mapped_lang" || "$lang" == "und" ]]; then
          eval "$out_map_args+=(\"-map\" \"0:a:$audio_idx\")"
          eval "$out_has_non_russian=1"
          echo "  → Keeping audio track $audio_idx: unknown (preserving)"
        fi
        ((audio_idx+=1))
      done <<< "$audio_info" || true
    fi

    return 0
  }

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
        eval "${_audio_map_args}+=(\"-map\" \"0:a:${rus_idx}\")"
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
    local rest="${fname#${base}}"
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

  local -a preferred_candidates=()
  local -a fallback_candidates=()
  local -a russian_candidates=()

  if [[ -n "$subtitle_info" ]]; then
    while IFS=, read -r sub_stream_idx sub_codec sub_lang sub_title _sub_default sub_forced; do
      [[ -z "$sub_stream_idx" || ! "$sub_stream_idx" =~ ^[0-9]+$ ]] && continue

      local mapped_lang; mapped_lang="$(map_lang "$sub_lang")"
      local is_commentary=0
      is_commentary_title "$sub_title" && is_commentary=1
      local is_forced=0
      [[ "${sub_forced:-0}" -gt 0 ]] && is_forced=1
      local is_russian=0
      [[ "$mapped_lang" == "rus" ]] && is_russian=1
      
      local display_lang="$mapped_lang"
      [[ -z "$display_lang" && -n "$sub_lang" ]] && display_lang="$sub_lang"
      [[ -z "$display_lang" ]] && display_lang="unknown"
      [[ "$is_commentary" -eq 1 ]] && display_lang="commentary"

      local codec_label="$sub_codec"
      [[ -z "$codec_label" ]] && codec_label="unknown"

      local entry="$sub_stream_idx|$codec_label|$display_lang"

      if [[ "$is_commentary" -eq 1 || "$is_forced" -eq 1 ]] || is_eng_or_ita "$mapped_lang"; then
        preferred_candidates+=("$entry")
      elif [[ "$is_russian" -eq 1 ]]; then
        russian_candidates+=("$entry")
      else
        fallback_candidates+=("$entry")
      fi
    done <<< "$subtitle_info" || true
  fi

  if [[ ${#preferred_candidates[@]} -gt 0 ]]; then
    local entry
    for entry in "${preferred_candidates[@]}"; do
      IFS='|' read -r idx codec_label display_lang <<< "$entry"
      SUBTITLE_SELECTION_MAP_ARGS+=("-map" "0:$idx")
      ((SUBTITLE_INTERNAL_COUNT+=1))
      echo "  → Keeping subtitle track $idx: $display_lang ($codec_label)"
    done
  elif [[ ${#fallback_candidates[@]} -gt 0 ]]; then
    local entry="${fallback_candidates[0]}"
    IFS='|' read -r idx codec_label display_lang <<< "$entry"
    SUBTITLE_SELECTION_MAP_ARGS+=("-map" "0:$idx")
    ((SUBTITLE_INTERNAL_COUNT+=1))
    echo "  → Keeping subtitle track $idx: $display_lang ($codec_label) [fallback]"
  elif [[ ${#russian_candidates[@]} -gt 0 ]]; then
    local entry="${russian_candidates[0]}"
    IFS='|' read -r idx codec_label display_lang <<< "$entry"
    SUBTITLE_SELECTION_MAP_ARGS+=("-map" "0:$idx")
    ((SUBTITLE_INTERNAL_COUNT+=1))
    echo "  → Keeping subtitle track $idx: $display_lang ($codec_label) [last resort]"
  fi
}
