# wywy-shlib

## Scope

Shared Bash helpers and the canonical shell style guide for Wywy repositories.
This repository contains no application logic and performs no state-changing operations.

## Rules

- Sourced modules have no shebang and are not executable. Entrypoints (under `scripts/tests/`) have a shebang and are executable.
- All modules must be dependency-free.
- The public API is documented in `README.md`.

## Testing

Run suites through their scripts:

```bash
scripts/tests/lint.sh
scripts/tests/unit.sh
```

Never invoke `shfmt` or `shellcheck` directly as a substitute for `lint.sh`.
