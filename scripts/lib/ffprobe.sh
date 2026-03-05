#!/usr/bin/env bash

# Wraps ffprobe to minimize subprocess calls by batching queries.
# Returns flat format data that can be parsed by helpers.

probe_file() {
  local src="$1"
  # -v error: suppress logs
  # -show_streams: get stream info
  # -show_format: get container info
  # -of flat: easy parsing (key=value)
  ffprobe -v error -show_streams -show_format -of flat "$src" < /dev/null
}

# Extract a value for a specific stream index and key
# Usage: probe_get_stream_val "$probe_data" "$stream_idx" "$key"
probe_get_stream_val() {
  local data="$1"
  local idx="$2"
  local key="$3"

  local prefix="streams.stream.${idx}.${key}="
  local line
  while IFS= read -r line; do
    case "$line" in
      "$prefix"*)
        local val="${line#*=}"
        val="${val%\"}"
        val="${val#\"}"
        echo "$val"
        return 0
        ;;
    esac
  done <<< "$data"

  echo ""
}

# Extract a format value
# Usage: probe_get_format_val "$probe_data" "$key"
probe_get_format_val() {
  local data="$1"
  local key="$2"

  local prefix="format.${key}="
  local line
  while IFS= read -r line; do
    case "$line" in
      "$prefix"*)
        local val="${line#*=}"
        val="${val%\"}"
        val="${val#\"}"
        echo "$val"
        return 0
        ;;
    esac
  done <<< "$data"

  echo ""
}

# Get list of stream indices for a specific codec type
# Usage: probe_get_stream_indices "$probe_data" "video|audio|subtitle"
probe_get_stream_indices() {
  local data="$1"
  local type="$2"

  local needle=".codec_type=\"${type}\""
  local line
  while IFS= read -r line; do
    case "$line" in
      streams.stream.*"$needle")
        local rest="${line#streams.stream.}"
        local idx="${rest%%.*}"
        if [[ "$idx" =~ ^[0-9]+$ ]]; then
          echo "$idx"
        fi
        ;;
    esac
  done <<< "$data"
}
