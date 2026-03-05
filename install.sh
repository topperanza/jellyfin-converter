#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
export LANG=C

REPO_DEFAULT="mt/jellyfin-converter"
VERSION=""
GITHUB_REPO="${GITHUB_REPO:-$REPO_DEFAULT}"
BIN_DIR=""
INSTALL_BASE=""
ARTIFACT_DIR=""
SKIP_SELF_CHECK=0

usage() {
  cat <<USAGE
Usage: install.sh --version <vX.Y.Z>

Options:
  --version <tag>       Release tag to install (required, e.g. v1.0.0)
  --github-repo <repo>  GitHub repo (default: mt/jellyfin-converter)
  --bin-dir <path>      Destination for jellyfin-converter executable
  --install-base <path> Installation base dir for versioned files
  --artifact-dir <dir>  Install from local release assets dir (offline/CI)
  --skip-self-check     Skip post-install self-check command
  -h, --help            Show this help message
USAGE
}

sha256_check() {
  local checksum_file="$1"
  local dir="$2"
  if command -v sha256sum >/dev/null 2>&1; then
    (cd "$dir" && sha256sum -c "$checksum_file")
  else
    local status=0
    while read -r sum name; do
      [[ -z "$sum" || -z "$name" ]] && continue
      local got
      got="$(shasum -a 256 "$dir/$name" | awk '{print $1}')"
      if [[ "$got" != "$sum" ]]; then
        echo "ERROR: checksum mismatch for $name"
        status=1
      fi
    done <"$checksum_file"
    return "$status"
  fi
}

download_file() {
  local url="$1"
  local out="$2"
  if command -v curl >/dev/null 2>&1; then
    curl --fail --location --proto '=https' --tlsv1.2 "$url" -o "$out"
  elif command -v wget >/dev/null 2>&1; then
    wget --https-only "$url" -O "$out"
  else
    echo "ERROR: Need curl or wget"
    exit 1
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)
      VERSION="${2:-}"
      shift 2
      ;;
    --github-repo)
      GITHUB_REPO="${2:-}"
      shift 2
      ;;
    --bin-dir)
      BIN_DIR="${2:-}"
      shift 2
      ;;
    --install-base)
      INSTALL_BASE="${2:-}"
      shift 2
      ;;
    --artifact-dir)
      ARTIFACT_DIR="${2:-}"
      shift 2
      ;;
    --skip-self-check)
      SKIP_SELF_CHECK=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$VERSION" ]]; then
  echo "ERROR: --version is required"
  usage
  exit 1
fi

if [[ -z "$BIN_DIR" ]]; then
  if [[ -w "/usr/local/bin" ]]; then
    BIN_DIR="/usr/local/bin"
  else
    BIN_DIR="$HOME/.local/bin"
  fi
fi

if [[ -z "$INSTALL_BASE" ]]; then
  if [[ -w "/usr/local/lib" ]]; then
    INSTALL_BASE="/usr/local/lib/jellyfin-converter"
  else
    INSTALL_BASE="$HOME/.local/share/jellyfin-converter"
  fi
fi

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

if [[ -n "$ARTIFACT_DIR" ]]; then
  cp "$ARTIFACT_DIR/release.tar.gz" "$TMP_DIR/release.tar.gz"
  cp "$ARTIFACT_DIR/checksums.txt" "$TMP_DIR/checksums.txt"
else
  BASE_URL="https://github.com/$GITHUB_REPO/releases/download/$VERSION"
  download_file "$BASE_URL/release.tar.gz" "$TMP_DIR/release.tar.gz"
  download_file "$BASE_URL/checksums.txt" "$TMP_DIR/checksums.txt"
fi

while read -r sum name; do
  [[ -z "${sum:-}" || -z "${name:-}" ]] && continue
  [[ -f "$TMP_DIR/$name" ]] && continue
  if [[ -n "$ARTIFACT_DIR" ]]; then
    if [[ -f "$ARTIFACT_DIR/$name" ]]; then
      cp "$ARTIFACT_DIR/$name" "$TMP_DIR/$name"
    else
      echo "ERROR: missing asset in artifact dir: $name"
      exit 1
    fi
  else
    download_file "$BASE_URL/$name" "$TMP_DIR/$name"
  fi
done <"$TMP_DIR/checksums.txt"

sha256_check "$TMP_DIR/checksums.txt" "$TMP_DIR"

mkdir -p "$INSTALL_BASE" "$BIN_DIR"

tar -xzf "$TMP_DIR/release.tar.gz" -C "$TMP_DIR"

PKG_DIR="$TMP_DIR/jellyfin-converter-${VERSION#v}"
if [[ ! -d "$PKG_DIR" ]]; then
  PKG_DIR="$(find "$TMP_DIR" -maxdepth 1 -type d -name 'jellyfin-converter-*' | head -n1)"
fi

if [[ -z "$PKG_DIR" || ! -d "$PKG_DIR" ]]; then
  echo "ERROR: Extracted package directory not found"
  exit 1
fi

TARGET_DIR="$INSTALL_BASE/$VERSION"
rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"
cp -R "$PKG_DIR/"* "$TARGET_DIR/"

BIN_TARGET="$BIN_DIR/jellyfin-converter"
ln -sfn "$TARGET_DIR/run.sh" "$BIN_TARGET"
chmod +x "$TARGET_DIR/run.sh"

"$BIN_TARGET" --version >/dev/null
"$BIN_TARGET" --help >/dev/null
if [[ "$SKIP_SELF_CHECK" -eq 0 ]]; then
  "$BIN_TARGET" --self-check >/dev/null
fi

echo "Installed jellyfin-converter $VERSION"
echo "  binary: $BIN_TARGET"
echo "  files:  $TARGET_DIR"
