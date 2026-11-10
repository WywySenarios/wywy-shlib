#!/bin/bash
#
# Unit tests for the wywy-shlib modules.
set -euo pipefail

REPO_ROOT="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")/../..")"
cd "$REPO_ROOT"

# Deterministic output: disable colour even when stdout is a TTY.
export NO_COLOR=1

# shellcheck source=../../output.sh
source "$REPO_ROOT/output.sh"
# shellcheck source=../../preflight.sh
source "$REPO_ROOT/preflight.sh"
# shellcheck source=../../run.sh
source "$REPO_ROOT/run.sh"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

FAILED=0

function pass() {
	info "PASS: $*"
}

function fail() {
	error "FAIL: $*"
	FAILED=1
}

function assert_eq() {
	local name="$1"
	local expected="$2"
	local actual="$3"

	if [[ "$actual" == "$expected" ]]; then
		pass "$name"
	else
		fail "$name: expected [$expected], got [$actual]"
	fi
}

# ---- output ------------------------------------------------------------------

assert_eq "header format" "==> hello" "$(header "hello")"
assert_eq "info format" "    hello" "$(info "hello")"
assert_eq "error stream and format" "boom" "$(error "boom" 2>&1 >/dev/null)"

set +e
die_output="$(die "fatal" 2>&1)"
die_status=$?
set -e

assert_eq "die exit code" "1" "$die_status"
assert_eq "die format" "fatal" "$die_output"

# ---- preflight ---------------------------------------------------------------

if wywy_require_cmd bash; then
	pass "require_cmd finds bash"
else
	fail "require_cmd did not find bash"
fi

set +e
missing_cmd_output="$(wywy_require_cmd wywy-no-such-command 2>&1)"
missing_cmd_status=$?
empty_cmd_output="$(wywy_require_cmd "" 2>&1)"
empty_cmd_status=$?
set -e

assert_eq "require_cmd missing command fails" "1" "$missing_cmd_status"
assert_eq "require_cmd missing command message" \
	"required command not found: wywy-no-such-command" "$missing_cmd_output"
assert_eq "require_cmd empty name fails" "2" "$empty_cmd_status"
assert_eq "require_cmd empty name message" \
	"wywy_require_cmd: command name is required" "$empty_cmd_output"

if wywy_require_env HOME; then
	pass "require_env finds HOME"
else
	fail "require_env did not find HOME"
fi

set +e
missing_env_output="$(WYWY_TEST_MISSING="" wywy_require_env WYWY_TEST_MISSING 2>&1)"
missing_env_status=$?
invalid_env_output="$(wywy_require_env "BAD-NAME" 2>&1)"
invalid_env_status=$?
set -e

assert_eq "require_env empty variable fails" "1" "$missing_env_status"
assert_eq "require_env empty variable message" \
	"required environment variable is not set: WYWY_TEST_MISSING" "$missing_env_output"
assert_eq "require_env invalid name fails" "2" "$invalid_env_status"
assert_eq "require_env invalid name message" \
	"wywy_require_env: invalid variable name: BAD-NAME" "$invalid_env_output"

# ---- run ---------------------------------------------------------------------

wywy_run touch "$TMP_DIR/executed"
if [[ -e "$TMP_DIR/executed" ]]; then
	pass "run executes in normal mode"
else
	fail "run did not execute in normal mode"
fi

dry_expected="$(
	printf '    would run: '
	printf '%q ' touch "$TMP_DIR/skipped"
)"
dry_expected="${dry_expected% }"
dry_output="$(WYWY_DRY_RUN=1 wywy_run touch "$TMP_DIR/skipped")"
assert_eq "run prints the plan in dry-run mode" "$dry_expected" "$dry_output"
if [[ ! -e "$TMP_DIR/skipped" ]]; then
	pass "run changes nothing in dry-run mode"
else
	fail "run created a file in dry-run mode"
fi

set +e
invalid_dry_output="$(WYWY_DRY_RUN=yes wywy_run true 2>&1)"
invalid_dry_status=$?
empty_run_output="$(wywy_run 2>&1)"
empty_run_status=$?
set -e

assert_eq "run rejects an invalid WYWY_DRY_RUN" "2" "$invalid_dry_status"
assert_eq "run invalid WYWY_DRY_RUN message" \
	"wywy_run: WYWY_DRY_RUN must be 0 or 1 (got: yes)" "$invalid_dry_output"
assert_eq "run rejects an empty command" "2" "$empty_run_status"
assert_eq "run empty command message" "wywy_run: no command given" "$empty_run_output"

if [[ "$FAILED" -ne 0 ]]; then
	error "unit tests failed"
	exit 1
fi

info "unit tests passed"
