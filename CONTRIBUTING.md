# Contributing to wywy-shlib

The public API must be documented in `README.md`.

## Bash Rules & Conventions

Modules must have no shebang and must not be executeable. The testing entrypoints must have shebangs and must be executeable.

Modules must be dependency-free.

## Development setup

Install the hooks once per clone:

```bash
pre-commit install
```

## Testing

All suites must pass before commit. `pre-commit` runs them.

```bash
scripts/tests/lint.sh
scripts/tests/unit.sh
```

It is highly advised to run the suites before making changes to set a baseline.

## A Final Warning

Do not commit with `--no-verify`.
