# Jellyfin Converter Tests

This directory contains the test suite for the Jellyfin Converter scripts.

## Running Tests

To run all tests (portable bash harness):
```bash
./tests/run.sh
```

To run a specific test suite:
```bash
./tests/run.sh tests/suite_parser.sh
```

## Structure

- `run.sh`: The test runner and harness (defines assertions).
- `suite_*.sh`: Individual test suites.
- `fixtures/`: Data files used by tests.

## Adding Tests

Create a new file `tests/suite_myfeature.sh`.
Source the harness or libraries in `setup()`.
Define functions starting with `test_`.

```bash
setup() {
  source "scripts/lib/my_lib.sh"
}

test_something() {
  assert_eq "expected" "actual"
}
```
