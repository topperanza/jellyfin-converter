#!/usr/bin/env bash
set -u
setup() {
  TMP_DIR="$(mktemp -d)"
}
teardown() {
  rm -rf "${TMP_DIR:-}"
}
test_path_stub_exits_zero() {
  BIN_DIR="$TMP_DIR/bin"
  mkdir -p "$BIN_DIR"
  cat >"$BIN_DIR/shellcheck" <<'EOF'
#!/usr/bin/env bash
if [[ "$1" == "--version" ]]; then
  echo "shellcheck 0.8.0 (fake)"
  exit 0
fi
exit 0
EOF
  chmod +x "$BIN_DIR/shellcheck"
  OLD_PATH="$PATH"
  PATH="$BIN_DIR:$PATH"
  OUT="$(./scripts/install_shellcheck.sh 2>&1 || true)"
  PATH="$OLD_PATH"
  assert_contains "$OUT" "shellcheck 0.8.0"
}
test_forced_install_failure_prints_diagnostics() {
  OLD_PATH="$PATH"
  PATH="/usr/bin:/bin"
  SHELLCHECK_INSTALL_SIMULATE_FAIL=1 OUT="$(./scripts/install_shellcheck.sh 2>&1 || true)"
  PATH="$OLD_PATH"
  assert_contains "$OUT" "PIP_INDEX_URL"
  assert_contains "$OUT" "pip config debug"
  assert_contains "$OUT" "-vvv"
}
