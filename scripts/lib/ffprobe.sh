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
  
  # Search for line: streams.stream.<idx>.<key>=...
  # We rely on grep. 
  local line
  line=$(echo "$data" | grep -F "streams.stream.${idx}.${key}=")
  
  if [[ -n "$line" ]]; then
    local val="${line#*=}"
    # Strip quotes if present (both " and ')
    val="${val%\"}"
    val="${val#\"}"
    echo "$val"
  else
    echo ""
  fi
}

# Extract a format value
# Usage: probe_get_format_val "$probe_data" "$key"
probe_get_format_val() {
  local data="$1"
  local key="$2"
  
  local line
  line=$(echo "$data" | grep -F "format.${key}=")
  
  if [[ -n "$line" ]]; then
    local val="${line#*=}"
    val="${val%\"}"
    val="${val#\"}"
    echo "$val"
  else
    echo ""
  fi
}

# Get list of stream indices for a specific codec type
# Usage: probe_get_stream_indices "$probe_data" "video|audio|subtitle"
probe_get_stream_indices() {
  local data="$1"
  local type="$2"
  
  # streams.stream.0.codec_type="video"
  # Extract the index number
  echo "$data" | grep -F "codec_type=\"${type}\"" | sed -n 's/streams\.stream\.\([0-9]*\)\.codec_type.*/\1/p'
}
