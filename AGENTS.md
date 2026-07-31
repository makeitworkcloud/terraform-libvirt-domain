# Operational Context
- **Type:** OpenTofu-compatible infrastructure module
- **Static validation:** `make test`
- **Lint:** `tflint`, `tofu fmt`

## Git Workflow

Use a feature branch and open a pull request rather than pushing directly to
`main`. Do not push any branch unless explicitly requested.

## Pre-commit Configuration

Pre-commit configuration is **centralized** in `makeitworkcloud/images/tfroot-runner/pre-commit-config.yaml`. The CI workflow fetches this config at runtime.

**Do not** modify `.pre-commit-config.yaml` in this repository.

For local development, run:
```bash
make test
```

This automatically fetches the canonical config if not present.
