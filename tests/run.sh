#!/usr/bin/env bash
# Portable Bash Test Harness & Runner
# Usage: ./tests/run.sh [pattern]

set -u

# Global Counters
SUITES_RUN=0
SUITES_FAILED=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# -----------------------------------------------------------------------------
# Assertion Helpers
# -----------------------------------------------------------------------------

fail() {
  echo -e "${RED}FAIL:${NC} $1"
  exit 1
}

assert_eq() {
  local expected="$1"
  local actual="$2"
  local msg="${3:-"Expected '$expected', got '$actual'"}"
  if [[ "$expected" != "$actual" ]]; then
    fail "$msg"
  fi
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local msg="${3:-"Expected to find '$needle' in content"}"
  if [[ "$haystack" != *"$needle"* ]]; then
    fail "$msg"
  fi
}

assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  local msg="${3:-"Expected NOT to find '$needle' in content"}"
  if [[ "$haystack" == *"$needle"* ]]; then
    fail "$msg"
  fi
}

# -----------------------------------------------------------------------------
# Runner Logic
# -----------------------------------------------------------------------------

run_suite() {
  local suite_file="$1"
  ((SUITES_RUN+=1))
  echo "Running suite: $suite_file"

  # We run the suite in a subshell so variables don't leak between suites,
  # but we export the assert functions so they are visible.
  # Note: Functions are not automatically exported to subshells unless we export -f,
  # but here we are just forking, so they should be available if we don't exec.
  # However, sourcing inside the subshell is the safest way.
  
  (
    # Load the test file
    # shellcheck source=/dev/null
    source "$suite_file"

    # Auto-discover test functions (starting with test_)
    local funcs=""
    if type compgen >/dev/null 2>&1; then
      funcs=$(compgen -A function | grep '^test_' || true)
    else
      # Portable fallback
      funcs=$(declare -F | cut -d' ' -f3 | grep '^test_' || true)
    fi


    local suite_failed=0

    for test_func in $funcs; do
      # Run setup if defined
      if type setup >/dev/null 2>&1; then setup; fi

      # Capture output? For now let's just run it. 
      # If we want to capture output we need more complex logic.
      # We'll rely on tests being quiet on success or printing useful info.
      
      if $test_func; then
        echo -e "  ${GREEN}✓ $test_func${NC}"
      else
        echo -e "  ${RED}✗ $test_func${NC}"
        suite_failed=1
      fi

      # Run teardown if defined
      if type teardown >/dev/null 2>&1; then teardown; fi
    done

    exit "$suite_failed"
  )
  local status=$?

  # Check subshell exit code
  if [[ $status -ne 0 ]]; then
    echo "Suite failed: $suite_file (exit code $status)"
    ((SUITES_FAILED+=1))
  fi
}

run_test_cmd() {
  local cmd="$1"
  if ! $cmd; then
    fail "Command failed: $cmd"
  fi
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

main() {
  local pattern="${1:-tests/suite_*.sh}"
  
  # Resolve path relative to CWD or script location
  # If the pattern doesn't match anything, bash leaves it as-is.
  # We check if files exist.
  
  local found_files=0
  for f in $pattern; do
    if [[ -f "$f" ]]; then
      found_files=1
      run_suite "$f"
    fi
  done

  if [[ "$found_files" -eq 0 ]]; then
    echo "No test files found matching: $pattern"
    exit 1
  fi

  echo "------------------------------------------------"
  echo "Suites Run: $SUITES_RUN"
  echo "Suites Failed: $SUITES_FAILED"
  
  if [[ "$SUITES_FAILED" -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
  else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
  fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
