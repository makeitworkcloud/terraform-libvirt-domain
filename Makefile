SHELL     := /bin/bash
TERRAFORM := $(shell which tofu)

.PHONY: help init test pre-commit-check-deps pre-commit-install-hooks

help:
	@echo "Terraform Module targets"
	@echo "------------------------"
	@echo
	@echo "\thelp: show this help text"
	@echo "\tinit: run 'terraform init' (no backend)"
	@echo "\ttest: run pre-commit checks"
	@echo
	@echo "One-time repo init targets"
	@echo "--------------------------"
	@echo
	@echo "\tpre-commit-install-hooks: install pre-commit hooks"
	@echo "\tpre-commit-check-deps: check pre-commit dependencies"
	@echo

init:
	@${TERRAFORM} init -backend=false -upgrade

test: .pre-commit-config.yaml .git/hooks/pre-commit
	@pre-commit run -a

.pre-commit-config.yaml:
	@curl -sSL -o .pre-commit-config.yaml \
		https://raw.githubusercontent.com/makeitworkcloud/shared-workflows/main/tfroot-pre-commit-config.yaml

DEPS_PRE_COMMIT=$(shell which pre-commit || echo "pre-commit not found")
DEPS_TERRAFORM_DOCS=$(shell which terraform-docs || echo "terraform-docs not found")
DEPS_TFLINT=$(shell which tflint || echo "tflint not found")
DEPS_CHECKOV=$(shell which checkov || echo "checkov not found")
DEPS_JQ=$(shell which jq || echo "jq not found")
pre-commit-check-deps:
	@echo "Checking for pre-commit and its dependencies:"
	@echo "  pre-commit: ${DEPS_PRE_COMMIT}"
	@echo "  terraform-docs: ${DEPS_TERRAFORM_DOCS}"
	@echo "  tflint: ${DEPS_TFLINT}"
	@echo "  checkov: ${DEPS_CHECKOV}"
	@echo "  jq: ${DEPS_JQ}"
	@echo ""

pre-commit-install-hooks: .git/hooks/pre-commit

.git/hooks/pre-commit: pre-commit-check-deps
	@pre-commit install --install-hooks
