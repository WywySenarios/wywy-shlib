# wywy-shlib

Shared Bash helpers and the canonical shell styling guide for Wywy repositories.

The repository is designed to be checked out as a submodule at
`scripts/lib/`, so its root modules sit directly beside the consumer's other
library files:

```text
<repo>/
└── scripts/
    ├── install/
    │   └── foo.sh
    └── lib/               <- this repository
        ├── output.sh
        ├── preflight.sh
        └── run.sh
```

## Use

Source the modules you need — each module resolves its own dependencies:

```bash
#!/bin/bash
#
# Install foo.
#
# Usage:
#   scripts/install/foo.sh [--dry-run]
set -euo pipefail

SCRIPT_DIR="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")"
REPO_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# shellcheck source=../lib/output.sh
source "$REPO_ROOT/scripts/lib/output.sh"
# shellcheck source=../lib/preflight.sh
source "$REPO_ROOT/scripts/lib/preflight.sh"
# shellcheck source=../lib/run.sh
source "$REPO_ROOT/scripts/lib/run.sh"

if [[ "${1:-}" == "--dry-run" ]]; then
	WYWY_DRY_RUN=1
fi

wywy_require_cmd git
header "Installing foo"
wywy_run git clone --depth 1 https://example.invalid/foo "$HOME/.local/share/foo"
info "foo installed"
```

Sourcing `output.sh` alone is enough when that is all you need:

```bash
# shellcheck source=../lib/output.sh
source "$REPO_ROOT/scripts/lib/output.sh"
header "Hello"
```

## Modules

| Module         | Public API                             | Purpose                                     |
| -------------- | -------------------------------------- | ------------------------------------------- |
| `output.sh`    | `header`, `info`, `error`, `die`       | TTY-aware, `NO_COLOR`-aware output helpers. |
| `preflight.sh` | `wywy_require_cmd`, `wywy_require_env` | Fail-closed prerequisite checks.            |
| `run.sh`       | `WYWY_DRY_RUN`, `wywy_run`             | Dry-run-aware command execution.            |

## Style guide

[`STYLE.md`](STYLE.md) is the canonical shell style guide. It is enforced by
`scripts/tests/lint.sh`:

```bash
scripts/tests/lint.sh
scripts/tests/unit.sh
```

The guide aligns with `internal/conventions/languages/bash.mdx` and
`internal/conventions/install-scripts.mdx` in `Wywy-Docs`. If the two disagree,
treat the convention in `Wywy-Docs` as authoritative and open a change here.

## Compatibility

- Bash 5.x (the Debian 13 baseline).
- Coreutils and Bash builtins only; no runtime dependency beyond `shfmt` and
  `shellcheck` for development.
- CI runs `lint.sh` with `WYWY_REQUIRE_SHELLCHECK=1`, so the Jenkins agent must
  provide `shellcheck`.

## Status

Unstable. The public API may change without a deprecation cycle until the first
tagged release.
