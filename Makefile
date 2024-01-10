.PHONY: all setup-local-env check-aws init validate format tflint tfsec plan
all: check-aws init validate format tflint tfsec plan

setup-local-env:
ifeq ($(GITHUB_ACTIONS),true)
	@echo "Running on GitHub Actions => Skipping .env.local export
else
	@sed -E "s/=(['\"])([^'\"]+)(['\"])/=\2/" .env.local > .env.tmp
	$(eval include .env.tmp)
	$(eval export)
	@echo "Running locally => .env.local variables exported"
endif

check-aws: setup-local-env
	@echo "Checking AWS credentials..."; \
	AWS_USER=$$(aws sts get-caller-identity --output text --query 'Arn'); \
	if [ -z "$$AWS_USER" ]; then \
		echo "Failed to retrieve AWS identity."; \
		exit 1; \
	else \
		echo "AWS User: $$AWS_USER"; \
	fi

init: check-aws
	@echo "Initializing Terraform..."
	@echo TERRAFORM_INIT_ARGS=$(TERRAFORM_INIT_ARGS)
	@terraform init $(TERRAFORM_INIT_ARGS)

validate: init
	@echo "Validating Terraform configuration..."
	@echo TERRAFORM_VALIDATE_ARGS=$(TERRAFORM_VALIDATE_ARGS)
	@terraform validate $(TERRAFORM_VALIDATE_ARGS)

format: setup-local-env
	@echo "Formatting Terraform configuration..."
	@echo TERRAFORM_FORMAT_ARGS=$(TERRAFORM_FORMAT_ARGS)
	@terraform fmt $(TERRAFORM_FORMAT_ARGS)

tflint: setup-local-env
	@echo "Running TFLint..."
	@echo TFLINT_ARGS=$(TFLINT_ARGS)
	@tflint $(TFLINT_ARGS)

tfsec: setup-local-env
	@echo "Running TFSec..."
	@echo TFSEC_ARGS=$(TFSEC_ARGS)
	@tfsec $(TFSEC_ARGS)

plan: setup-local-env
	@echo "Creating Terraform plan..."
	@echo TERRAFORM_PLAN_ARGS=$(TERRAFORM_PLAN_ARGS)
	@terraform plan $(TERRAFORM_PLAN_ARGS)
	@echo "\n\033[1;31m*** THIS PLAN IS NOT DEPLOYABLE. ***\033[0m"

sure: check-aws validate format tflint tfsec plan
