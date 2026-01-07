#!/usr/bin/env bash
set -u
exists() { command -v "$1" >/dev/null 2>&1; }
if exists shellcheck; then
  shellcheck --version
  exit 0
fi
ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PY=""
if [[ -n "${VIRTUAL_ENV:-}" && -x "$VIRTUAL_ENV/bin/python" ]]; then
  PY="$VIRTUAL_ENV/bin/python"
else
  if command -v python >/dev/null 2>&1; then
    PY="python"
  elif command -v python3 >/dev/null 2>&1; then
    PY="python3"
  else
    echo "python not found on PATH"
    exit 1
  fi
fi
if [[ -n "${SHELLCHECK_INSTALL_SIMULATE_FAIL:-}" ]]; then
  echo "pip config debug"
  echo "PIP_INDEX_URL=${PIP_INDEX_URL:-unset}"
  echo "PIP_EXTRA_INDEX_URL=${PIP_EXTRA_INDEX_URL:-unset}"
  echo "Hint: set PIP_INDEX_URL ending with /simple"
  echo "Hint: set HTTP_PROXY/HTTPS_PROXY"
  echo "Re-run with pip -vvv"
  exit 2
fi
ok=0
if [[ -n "${VIRTUAL_ENV:-}" ]]; then
  "$PY" -m pip install -U pip >/dev/null 2>&1 || true
  if "$PY" -m pip install shellcheck-py; then ok=1; fi
  if [[ "$ok" -eq 1 ]]; then
    SC_PATH="$("$PY" - <<'PY'
import sys, os
print(os.path.join(sys.prefix, "bin", "shellcheck"))
PY
)"
    if [[ -x "$SC_PATH" ]]; then
      "$SC_PATH" --version
      exit 0
    fi
    if exists shellcheck; then
      shellcheck --version
      exit 0
    fi
  fi
fi
if [[ "$ok" -eq 0 ]]; then
  VENV_DIR="$ROOT/.venv-shellcheck"
  if [[ ! -d "$VENV_DIR" ]]; then
    "$PY" -m venv "$VENV_DIR" || true
  fi
  VPY="$VENV_DIR/bin/python"
  if [[ -x "$VPY" ]]; then
    "$VPY" -m pip install -U pip >/dev/null 2>&1 || true
    if "$VPY" -m pip install shellcheck-py; then ok=1; fi
    if [[ -n "${GITHUB_PATH:-}" ]]; then
      printf "%s\n" "$VENV_DIR/bin" >>"$GITHUB_PATH" || true
    fi
    SC_VENV_PATH="$("$VPY" - <<'PY'
import sys, os
print(os.path.join(sys.prefix, "bin", "shellcheck"))
PY
)"
    if [[ -x "$SC_VENV_PATH" ]]; then
      "$SC_VENV_PATH" --version
      exit 0
    fi
  fi
fi
if exists shellcheck; then
  shellcheck --version
  exit 0
fi
"$PY" -m pip config list || true
"$PY" -m pip debug || true
echo "pip config debug"
"$PY" -m pip debug || true
echo "PIP_INDEX_URL=${PIP_INDEX_URL:-unset}"
echo "PIP_EXTRA_INDEX_URL=${PIP_EXTRA_INDEX_URL:-unset}"
echo "Advice: set PIP_INDEX_URL to URL ending with /simple"
echo "Advice: configure HTTP_PROXY/HTTPS_PROXY if behind proxy"
echo "Advice: rerun with pip -vvv"
exit 1
