
# This file is for you! Edit it to implement your own Terraform make targets.

# ==============================================================================
# Custom implementation - implementation of a make target should not exceed 5 lines of effective code.
# In most cases there should be no need to modify the existing make targets.

TF_ENV ?= dev
STACK ?= ${stack}
TERRAFORM_STACK ?= $(or ${STACK}, infrastructure/environments/${TF_ENV})
dir ?= ${TERRAFORM_STACK}

terraform-docs:
	terraform-docs infrastructure

terraform-init: # Initialise Terraform - optional: terraform_dir|dir=[path to a directory where the command will be executed, relative to the project's top-level directory, default is one of the module variables or the example directory, if not set], terraform_opts|opts=[options to pass to the Terraform init command, default is none/empty] @Development
	make _terraform cmd="init" \
		dir=$(or ${terraform_dir}, ${dir}) \
		opts=$(or ${terraform_opts}, ${opts})

terraform-plan: # Plan Terraform changes - optional: terraform_dir|dir=[path to a directory where the command will be executed, relative to the project's top-level directory, default is one of the module variables or the example directory, if not set], terraform_opts|opts=[options to pass to the Terraform plan command, default is none/empty] @Development
	make _terraform cmd="plan" \
		dir=$(or ${terraform_dir}, ${dir}) \
		opts=$(or ${terraform_opts}, ${opts})

terraform-apply: # Apply Terraform changes - optional: terraform_dir|dir=[path to a directory where the command will be executed, relative to the project's top-level directory, default is one of the module variables or the example directory, if not set], terraform_opts|opts=[options to pass to the Terraform apply command, default is none/empty] @Development
	make _terraform cmd="apply" \
		dir=$(or ${terraform_dir}, ${dir}) \
		opts=$(or ${terraform_opts}, ${opts})

terraform-destroy: # Destroy Terraform resources - optional: terraform_dir|dir=[path to a directory where the command will be executed, relative to the project's top-level directory, default is one of the module variables or the example directory, if not set], terraform_opts|opts=[options to pass to the Terraform destroy command, default is none/empty] @Development
	make _terraform \
		cmd="destroy" \
		dir=$(or ${terraform_dir}, ${dir}) \
		opts=$(or ${terraform_opts}, ${opts})

terraform-fmt: # Format Terraform files - optional: terraform_dir|dir=[path to a directory where the command will be executed, relative to the project's top-level directory, default is one of the module variables or the example directory, if not set], terraform_opts|opts=[options to pass to the Terraform fmt command, default is '-recursive'] @Quality
	make _terraform cmd="fmt" \
		dir=$(or ${terraform_dir}, ${dir}) \
		opts=$(or ${terraform_opts}, ${opts})

terraform-validate: # Validate Terraform configuration - optional: terraform_dir|dir=[path to a directory where the command will be executed, relative to the project's top-level directory, default is one of the module variables or the example directory, if not set], terraform_opts|opts=[options to pass to the Terraform validate command, default is none/empty] @Quality
	make _terraform cmd="validate" \
		dir=$(or ${terraform_dir}, ${dir}) \
		opts=$(or ${terraform_opts}, ${opts})

terraform-lint: # Lint Terraform modules using tflint - optional: module=[name of the module to lint, e.g. 'managed-identity'] @Quality
	echo "Running TFLint..."
	make _install-dependency name="tflint"
	if [ -n "${module}" ]; then \
		module_dir="infrastructure/modules/${module}"; \
		if [ ! -d "$$module_dir" ]; then echo "Error: Module directory $$module_dir not found"; exit 1; fi; \
		if ls "$$module_dir"/*.tf > /dev/null 2>&1; then \
			echo "=== Linting $$module_dir ==="; \
			tflint --init --chdir="$$module_dir" > /dev/null 2>&1 || true; \
			tflint --chdir="$$module_dir" --format=compact; \
		else \
			echo "Skipping $$module_dir (no .tf files)"; \
		fi; \
	else \
		total_issues=0; \
		for module_dir in $$(find infrastructure/modules -mindepth 1 -maxdepth 1 -type d); do \
			module_name=$$(basename "$$module_dir"); \
			if ls "$$module_dir"/*.tf > /dev/null 2>&1; then \
				echo "=== Linting $$module_dir ==="; \
				tflint --init --chdir="$$module_dir" > /dev/null 2>&1 || true; \
				output=$$(tflint --chdir="$$module_dir" --format=compact 2>&1 || true); \
				issue_count=$$(echo "$$output" | grep -c ":" || echo "0"); \
				if [ "$$issue_count" -gt 0 ] && [ -n "$$output" ]; then \
					total_issues=$$((total_issues + issue_count)); \
					echo "### ⚠️ $$module_name ($$issue_count issues)"; \
					echo "$$output"; \
				else \
					echo "### ✅ $$module_name"; \
				fi; \
				echo ""; \
			fi; \
		done; \
		echo "Total issues: $$total_issues"; \
		if [ $$total_issues -gt 0 ]; then \
			echo "> **Note:** TFLint issues are advisory only."; \
		fi; \
	fi

terraform-security: # Run security scan using tfsec - optional: module=[name of the module to scan, e.g. 'managed-identity'] @Quality
	echo "Running tfsec..."
	make _install-dependency name="tfsec"
	if [ -n "${module}" ]; then \
		module_dir="infrastructure/modules/${module}"; \
		if [ ! -d "$$module_dir" ]; then echo "Error: Module directory $$module_dir not found"; exit 1; fi; \
		echo "=== Scanning $$module_dir ==="; \
		tfsec "$$module_dir" --soft-fail; \
	else \
		tfsec infrastructure/ --soft-fail; \
	fi

terraform-static-analysis: # Run static analysis using SonarScanner @Quality
	echo "Running Static Analysis..."
	./scripts/reports/perform-static-analysis.sh

terraform-test-modules: # Run Go unit tests for Terraform modules - optional: module=[name of the module to test, e.g. 'managed-identity'] @Testing
	echo "Running Module Tests..."
	make _install-dependency name="golang"
	failed=0
	if [ -n "${module}" ]; then \
		test_dir="infrastructure/modules/${module}/tests"; \
		if [ ! -d "$$test_dir" ]; then echo "Error: Test directory $$test_dir not found"; exit 1; fi; \
		echo "=== Running tests in $$test_dir ==="; \
		cd "$$test_dir"; \
		go mod tidy; \
		if ! go test -v ./...; then failed=1; fi; \
	else \
		for test_dir in $$(find infrastructure/modules -type d -name "tests"); do \
			if ls "$$test_dir"/*_test.go 1> /dev/null 2>&1; then \
				echo "=== Running tests in $$test_dir ==="; \
				cd "$$test_dir"; \
				go mod tidy; \
				if ! go test -v ./...; then failed=1; fi; \
				cd - > /dev/null; \
			fi; \
		done; \
	fi; \
	if [ $$failed -eq 1 ]; then exit 1; fi

terraform-test: # Run all Terraform quality checks and tests @Testing
	make terraform-lint
	make terraform-security
	make terraform-test-modules

terraform-install-tools: # Install all terraform related tools @Installation
	make _install-dependency name="terraform"
	make _install-dependency name="tflint"
	make _install-dependency name="tfsec"
	make _install-dependency name="golang"

clean:: # Remove Terraform files (terraform) - optional: terraform_dir|dir=[path to a directory where the command will be executed, relative to the project's top-level directory, default is one of the module variables or the example directory, if not set] @Operations
	make _terraform cmd="clean" \
		dir=$(or ${terraform_dir}, ${dir}) \
		opts=$(or ${terraform_opts}, ${opts})

_terraform: # Terraform command wrapper - mandatory: cmd=[command to execute]; optional: dir=[path to a directory where the command will be executed, relative to the project's top-level directory, default is one of the module variables or the example directory, if not set], opts=[options to pass to the Terraform command, default is none/empty]
	dir=$(or ${dir}, ${TERRAFORM_STACK})
	source scripts/terraform/terraform.lib.sh
	terraform-${cmd} # 'dir' and 'opts' are accessible by the function as environment variables, if set

# ==============================================================================
# Quality checks - please DO NOT edit this section!

terraform-shellscript-lint: # Lint all Terraform module shell scripts @Quality
	for file in $$(find scripts/terraform -type f -name "*.sh"); do
		file=$${file} scripts/shellscript-linter.sh
	done

# ==============================================================================
# Configuration - please DO NOT edit this section!

terraform-install: # Install Terraform @Installation
	make _install-dependency name="terraform"

# ==============================================================================

${VERBOSE}.SILENT: \
	_terraform \
	clean \
	terraform-apply \
	terraform-destroy \
	terraform-fmt \
	terraform-init \
	terraform-install \
	terraform-install-tools \
	terraform-lint \
	terraform-plan \
	terraform-security \
	terraform-shellscript-lint \
	terraform-static-analysis \
	terraform-test \
	terraform-test-modules \
	terraform-validate \
