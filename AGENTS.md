# Operational Context
- **Type:** Terraform Module
- **Test:** `make test`
- **Lint:** `tflint`, `terraform fmt`

## Pre-commit Configuration

Pre-commit configuration is **centralized** in `makeitworkcloud/shared-workflows/tfroot-pre-commit-config.yaml`. The CI workflow fetches this config at runtime.

**Do not** modify `.pre-commit-config.yaml` in this repository.

For local development, run:
```bash
make test
```

This automatically fetches the canonical config if not present.
