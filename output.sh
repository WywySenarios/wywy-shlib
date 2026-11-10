# shellcheck shell=bash

if [[ -n "${_WYWY_OUTPUT_LOADED:-}" ]]; then
	return 0
fi
_WYWY_OUTPUT_LOADED=1

# Color is rendered if NO_COLOR is empty and stdout is a TTY.
if [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]]; then
	COLOR_HEADER=$'\033[33m'
	COLOR_INFO=$'\033[94m'
	COLOR_ERROR=$'\033[31m'
	COLOR_RESET=$'\033[0m'
else
	COLOR_HEADER=""
	COLOR_INFO=""
	COLOR_ERROR=""
	COLOR_RESET=""
fi

function header() {
	printf '%s==> %s%s\n' "$COLOR_HEADER" "$*" "$COLOR_RESET"
}

function info() {
	printf '%s    %s%s\n' "$COLOR_INFO" "$*" "$COLOR_RESET"
}

function error() {
	printf '%s%s%s\n' "$COLOR_ERROR" "$*" "$COLOR_RESET" >&2
}

function die() {
	error "$@"
	exit 1
}
