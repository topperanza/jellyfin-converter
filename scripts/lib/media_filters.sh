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
          if [[ "$audio_idx" -eq 0 ]]; then
            out_map_args+=("-map" "0:a:$audio_idx")
            out_has_non_russian=1
            echo "  → Keeping audio track $audio_idx: unknown/original"
          fi
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
    local rest="${fname#${base}}"; rest="${rest#.}"; rest="${rest%.*}"
    local lang="" forced=0

    local rest_lower="$rest"
    rest_lower="$(to_lower "$rest_lower")"
    local is_commentary=0
    is_commentary_title "$rest_lower" && is_commentary=1

    IFS='._- ' read -r -a tokens <<< "$rest"
    for tk in "${tokens[@]}"; do
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
          if [[ "$audio_idx" -eq 0 ]]; then
            eval "$out_map_args+=(\"-map\" \"0:a:$audio_idx\")"
            eval "$out_has_non_russian=1"
            echo "  → Keeping audio track $audio_idx: unknown/original"
          fi
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
    local rest="${fname#${base}}"; rest="${rest#.}"; rest="${rest%.*}"
    local lang="" forced=0

    local rest_lower="$rest"
    rest_lower="$(to_lower "$rest_lower")"
    local is_commentary=0
    is_commentary_title "$rest_lower" && is_commentary=1

    IFS='._- ' read -r -a tokens <<< "$rest"
    for tk in "${tokens[@]}"; do
      [[ -z "$lang" ]] && lang="$(map_lang "$tk")"
      [[ "$tk" =~ ^(forced|forzato|forzati|zwangs|obligatoire)$ ]] && forced=1
    done

    if [[ "$is_commentary" -eq 1 ]]; then
      echo "  + sub: $subfile  commentary lang=${lang:-unknown} forced=$forced"
      eval "${_sub_inputs}+=(\"-i\" \"$subfile\")"
      eval "${_sub_langs}+=(\"${lang:-und}\")"
      eval "${_sub_forced}+=(\"$forced\")"
      eval "${_sub_files}+=(\"$subfile\")"
      eval "$_sub_idx=$((_sub_idx+1))"
    elif is_eng_or_ita "$lang"; then
      echo "  + sub: $subfile  lang=$lang forced=$forced"
      eval "${_sub_inputs}+=(\"-i\" \"$subfile\")"
      eval "${_sub_langs}+=(\"$lang\")"
      eval "${_sub_forced}+=(\"$forced\")"
      eval "${_sub_files}+=(\"$subfile\")"
      eval "$_sub_idx=$((_sub_idx+1))"
    else
      echo "  × skipping sub: $subfile  lang=${lang:-unknown} (not eng/ita/commentary)"
    fi
  }
fi
