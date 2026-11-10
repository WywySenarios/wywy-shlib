# shellcheck shell=bash
# Some preflight check helpers
#
# The helpers return non-zero on failure.

if [[ -n "${_WYWY_PREFLIGHT_LOADED:-}" ]]; then
	return 0
fi
_WYWY_PREFLIGHT_LOADED=1

_WYWY_PREFLIGHT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=output.sh
source "$_WYWY_PREFLIGHT_DIR/output.sh"
unset _WYWY_PREFLIGHT_DIR

# Fail if a command is not on PATH.
# Example usage:
#   wywy_require_cmd docker "install Docker Engine"
function wywy_require_cmd() {
	local cmd="${1:-}"
	local hint="${2:-}"

	if [[ -z "$cmd" ]]; then
		error "wywy_require_cmd: command name is required"
		return 2
	fi
	command -v -- "$cmd" >/dev/null 2>&1 || {
		error "required command not found: $cmd${hint:+ ($hint)}"
		return 1
	}
}

# Fail if an environment variable is unset or empty.
# Example usage:
#   wywy_require_env FOO_TOKEN "mint one in the operator console"
function wywy_require_env() {
	local name="${1:-}"
	local hint="${2:-}"

	if [[ -z "$name" ]]; then
		error "wywy_require_env: variable name is required"
		return 2
	fi
	if [[ ! "$name" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
		error "wywy_require_env: invalid variable name: $name"
		return 2
	fi
	if [[ -z "${!name:-}" ]]; then
		if [[ -n "$hint" ]]; then
			error "required environment variable is not set: $name ($hint)"
		else
			error "required environment variable is not set: $name"
		fi
		return 1
	fi
}
