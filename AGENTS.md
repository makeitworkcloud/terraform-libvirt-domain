# Agent Instructions

## Ownership

OpenTofu-compatible module for libvirt domains. Keep module inputs, outputs, provider constraints, and generated documentation compatible with downstream consumers.

## Validation and delivery

Use GitHub MCP and PR CI as the validation authority. The canonical pre-commit configuration is owned by `images/tfroot-runner`; the generated root config must not be edited. Do not run local OpenTofu, Makefile, or release commands from this headless server.

A `v*` tag releases the module. Open an authorized scoped branch and PR; do not tag, publish, or merge without explicit confirmation. Never expose state, credentials, SSH material, decrypted SOPS values, or sensitive plans.
