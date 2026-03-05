#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="${1:-$ROOT/dist}"
INSTALL_ROOT="$(mktemp -d)"
HOME_DIR="$INSTALL_ROOT/home"
mkdir -p "$HOME_DIR"

cleanup() {
  rm -rf "$INSTALL_ROOT"
}
trap cleanup EXIT

export HOME="$HOME_DIR"
"$ROOT/install.sh" --version "v$(cat "$ROOT/VERSION")" --artifact-dir "$DIST_DIR" --bin-dir "$INSTALL_ROOT/bin" --install-base "$INSTALL_ROOT/lib"

"$INSTALL_ROOT/bin/jellyfin-converter" --version
"$INSTALL_ROOT/bin/jellyfin-converter" --help >/dev/null
"$INSTALL_ROOT/bin/jellyfin-converter" --self-check >/dev/null

echo "Installer validation passed"
