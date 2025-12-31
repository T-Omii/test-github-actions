#!/usr/bin/env bash
set -euo pipefail

# Generic test entrypoint. The concrete test command can be injected via the
# TEST_CMD environment variable. Default is pytest.
: "${TEST_CMD:=pytest -q}"

echo "Running tests: $TEST_CMD"
# shellcheck disable=SC2086
bash -c "$TEST_CMD"
