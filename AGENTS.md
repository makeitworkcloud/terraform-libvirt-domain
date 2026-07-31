# Operational Context
- **Type:** OpenTofu-compatible infrastructure module
- **Static validation:** `make test`
- **Lint:** `tflint`, `tofu fmt`

## Git Workflow

Use a feature branch and open a pull request rather than pushing directly to
`main`. Do not push any branch unless explicitly requested.

## Pre-commit Configuration

Pre-commit configuration is centralized at
`https://raw.githubusercontent.com/makeitworkcloud/images/main/tfroot-runner/pre-commit-config.yaml`. The root
`.pre-commit-config.yaml` is generated and ignored; do not edit it.

For local development, run:
```bash
make test
```

This refreshes the generated config from the canonical source on every run and
replaces it only when the content changed. CI also runs `make test`, so the
module fetches the same canonical config there rather than tracking a copy.
