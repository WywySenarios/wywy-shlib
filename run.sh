# shellcheck shell=bash
# Dry-run aware command execution. Source this file; do not execute it.

if [[ -n "${_WYWY_RUN_LOADED:-}" ]]; then
	return 0
fi
_WYWY_RUN_LOADED=1

_WYWY_RUN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=output.sh
source "$_WYWY_RUN_DIR/output.sh"
unset _WYWY_RUN_DIR

# 0 executes commands; 1 prints them and changes nothing.
WYWY_DRY_RUN="${WYWY_DRY_RUN:-0}"

# Execute the argument vector, or print it when WYWY_DRY_RUN=1.
#
# The vector is executed directly with "$@"; it is never assembled into a
# string. The display form is shell-quoted with printf %q.
#
#   wywy_run install -m 0755 "$artifact" "$HOME/.local/bin/foo"
function wywy_run() {
	local rendered

	if [[ "$#" -eq 0 ]]; then
		error "wywy_run: no command given"
		return 2
	fi

	case "$WYWY_DRY_RUN" in
		0) ;;
		1)
			printf -v rendered '%q ' "$@"
			info "would run: ${rendered% }"
			return 0
			;;
		*)
			error "wywy_run: WYWY_DRY_RUN must be 0 or 1 (got: $WYWY_DRY_RUN)"
			return 2
			;;
	esac

	"$@"
}
