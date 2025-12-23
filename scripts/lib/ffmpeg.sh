#!/usr/bin/env bash

# Dependency checks for required binaries
need_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "ERROR: Missing required command: $1 ($2)" >&2; exit 1; }; }

# Codec compatibility checks
is_codec_compatible_video() { case "$1" in h264|hevc|av1) return 0 ;; *) return 1 ;; esac; }
is_codec_compatible_audio() { case "$1" in aac|ac3|eac3|mp3|flac|opus|dts) return 0 ;; *) return 1 ;; esac; }

# Hardware acceleration detection helpers
encoder_present() { ffmpeg -hide_banner -encoders 2>/dev/null | grep -q "$1"; }

# Wrapper to run ffmpeg non-interactively and safely
run_ffmpeg() {
  local cmd="$1"
  shift
  # Inject -nostdin to prevent interactive prompts/hanging and ensure stdin is not read.
  # This allows the script to run in background or via automation without suspending.
  "$cmd" -nostdin "$@"
}

detect_hw_accel() {
  if [[ -n "${RESOLVED_HW:-}" ]]; then
    echo "$RESOLVED_HW"
    return
  fi

  local codec_enc_nvenc="h264_nvenc"
  local codec_enc_qsv="h264_qsv"
  local codec_enc_vaapi="h264_vaapi"

  if [[ "$CODEC" == "hevc" ]]; then
    codec_enc_nvenc="hevc_nvenc"
    codec_enc_qsv="hevc_qsv"
    codec_enc_vaapi="hevc_vaapi"
  fi

  case "$HW_ACCEL" in
    auto)
      if encoder_present "$codec_enc_nvenc"; then
        RESOLVED_HW="nvenc"
      elif encoder_present "$codec_enc_qsv"; then
        RESOLVED_HW="qsv"
      elif encoder_present "$codec_enc_vaapi"; then
        RESOLVED_HW="vaapi"
      else
        RESOLVED_HW="none"
      fi
      ;;
    nvenc)
      if encoder_present "$codec_enc_nvenc"; then
        RESOLVED_HW="nvenc"
      else
        RESOLVED_HW="none"
      fi
      ;;
    qsv)
      if encoder_present "$codec_enc_qsv"; then
        RESOLVED_HW="qsv"
      else
        RESOLVED_HW="none"
      fi
      ;;
    vaapi)
      if encoder_present "$codec_enc_vaapi"; then
        RESOLVED_HW="vaapi"
      else
        RESOLVED_HW="none"
      fi
      ;;
    none)
      RESOLVED_HW="none"
      ;;
    *)
      RESOLVED_HW="none"
      ;;
  esac

  echo "$RESOLVED_HW"
}

preflight_hw_encoder() {
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

# Determine optimal CRF based on source resolution
get_optimal_crf() {
  local src="$1"
  local height=$(ffprobe -v error -select_streams v:0 \
    -show_entries stream=height -of csv=p=0 "$src" 2>/dev/null || echo "720")

  if [[ "$height" -ge 2160 ]]; then
    echo 22
  elif [[ "$height" -ge 1080 ]]; then
    echo 20
  elif [[ "$height" -ge 720 ]]; then
    echo 21
  else
    echo 23
  fi
}

get_video_bitrate_kbps() {
  local src="$1"
  local bitrate

  bitrate=$(ffprobe -v error -select_streams v:0 -show_entries stream=bit_rate \
    -of default=nw=1:nk=1 "$src" 2>/dev/null || true)

  if [[ -z "$bitrate" || "$bitrate" == "N/A" || ! "$bitrate" =~ ^[0-9]+$ ]]; then
    bitrate=$(ffprobe -v error -show_entries format=bit_rate \
      -of default=nw=1:nk=1 "$src" 2>/dev/null || true)
  fi

  if [[ -z "$bitrate" || "$bitrate" == "N/A" || ! "$bitrate" =~ ^[0-9]+$ ]]; then
    echo 0
  else
    echo $((bitrate / 1000))
  fi
}

get_filesize_mb() {
  local src="$1"
  local size

  size=$(stat -f%z "$src" 2>/dev/null || true)
  if [[ -z "$size" || ! "$size" =~ ^[0-9]+$ ]]; then
    size=$(stat -c%s "$src" 2>/dev/null || true)
  fi

  if [[ -z "$size" || ! "$size" =~ ^[0-9]+$ ]]; then
    echo 0
  else
    echo $((size / 1024 / 1024))
  fi
}
