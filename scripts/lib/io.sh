#!/usr/bin/env bash

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

check_write_permissions() {
  local output_dir="$OUTROOT_PATH"
  local logs_dir="$LOG_DIR"
  local tmp_file="$output_dir/.perm_test.$$"
  local log_probe="${LOGFILE}.permcheck"

  mkdir -p "$output_dir" "$logs_dir" || {
    echo "ERROR: Cannot create output or log directories: $output_dir, $logs_dir (check permissions or disk space)"
    exit 3
  }

  if ! touch "$tmp_file" "$log_probe" 2>/dev/null; then
    echo "ERROR: Cannot write to $output_dir or $logs_dir (check permissions or available space)"
    exit 3
  fi

  if ! rm -f "$tmp_file" "$log_probe" 2>/dev/null; then
    echo "ERROR: Cannot clean up temp files in $output_dir or $logs_dir (check permissions)"
    exit 3
  fi
}

build_find_pattern() {
  local -a patterns=()
  IFS='|' read -ra formats <<< "$VIDEO_FORMATS"
  for fmt in "${formats[@]}"; do
    patterns+=("-iname" "*.${fmt}" "-o")
  done
  local last_idx=$((${#patterns[@]} - 1))
  unset "patterns[$last_idx]"
  printf '%s\n' "${patterns[@]}"
}

display_patterns() {
  local -a patterns=()
  IFS='|' read -ra formats <<< "$VIDEO_FORMATS"
  for fmt in "${formats[@]}"; do
    patterns+=("*.${fmt}")
  done
  echo "${patterns[*]}"
}

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

  if [[ -z "$input_path" ]]; then
    input_path="$default_path"
  fi

  input_path="${input_path/#\~/$HOME}"

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

  SCAN_DIR=$(cd "$input_path" && pwd)

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
