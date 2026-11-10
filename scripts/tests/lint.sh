#!/bin/bash
#
# Static checks: syntax, formatting, executable bits, and shellcheck.
set -euo pipefail

REPO_ROOT="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")/../..")"
cd "$REPO_ROOT"

# shellcheck source=../../output.sh
source "$REPO_ROOT/output.sh"

shopt -s globstar nullglob
shell_files=(**/*.sh)

if [[ "${#shell_files[@]}" -eq 0 ]]; then
	error "lint: no shell files found under $REPO_ROOT"
	exit 1
fi

status=0

function run_check() {
	local name="$1"
	shift

	if "$@"; then
		info "PASS: $name"
	else
		error "FAIL: $name"
		status=1
	fi
}

function check_syntax() {
	local failed=0
	local file

	for file in "${shell_files[@]}"; do
		if ! bash -n "$file"; then
			error "syntax error: $file"
			failed=1
		fi
	done

	return "$failed"
}

function check_format() {
	if ! command -v shfmt >/dev/null 2>&1; then
		error "shfmt not found"
		return 1
	fi

	shfmt -d "${shell_files[@]}"
}

function check_executable_bits() {
	local failed=0
	local file

	for file in "${shell_files[@]}"; do
		case "$file" in
			scripts/tests/*)
				if [[ ! -x "$file" ]]; then
					error "entrypoint is not executable: $file"
					failed=1
				fi
				;;
			*)
				if [[ -x "$file" ]]; then
					error "sourced module must not be executable: $file"
					failed=1
				fi
				;;
		esac
	done

	return "$failed"
}

function check_shellcheck() {
	if ! command -v shellcheck >/dev/null 2>&1; then
		if [[ "${WYWY_REQUIRE_SHELLCHECK:-0}" == "1" ]]; then
			error "shellcheck not found and WYWY_REQUIRE_SHELLCHECK=1"
			return 1
		fi
		info "shellcheck not found; skipping (set WYWY_REQUIRE_SHELLCHECK=1 to require)"
		return 0
	fi

	shellcheck "${shell_files[@]}"
}

run_check "syntax" check_syntax
run_check "format" check_format
run_check "executable bits" check_executable_bits
run_check "shellcheck" check_shellcheck

if [[ "$status" -ne 0 ]]; then
	error "lint failed (${#shell_files[@]} files)"
	exit 1
fi

info "lint passed (${#shell_files[@]} files)"
