.PHONY: all check-aws init validate format tflint tfsec plan

all: check-aws init validate format tflint tfsec plan apply

check-aws:
	@echo "Checking AWS credentials..."
	@AWS_IDENTITY=$$(aws sts get-caller-identity --output text --query 'Account'); \
	AWS_USER=$$(aws sts get-caller-identity --output text --query 'Arn'); \
	if [ -z "$$AWS_IDENTITY" ]; then \
		echo "Failed to retrieve AWS identity."; \
		exit 1; \
	else \
		echo "AWS User: $$AWS_USER"; \
	fi

init: check-aws
	@echo "Initializing Terraform..."
	@terraform init $(TERRAFORM_INIT_ARGS)


validate: init
	@echo "Validating Terraform configuration..."
	@terraform validate $(TERRAFORM_VALIDATE_ARGS)

format:
	@echo "Formatting Terraform configuration..."
	@terraform fmt $(TERRAFORM_FORMAT_ARGS)

tflint:
	@echo "Running TFLint..."
	@tflint $(TFLINT_ARGS)

tfsec:
	@echo "Running TFSec..."
	@tfsec $(TFSEC_ARGS)

plan:
	@echo "Creating Terraform plan..."
	@terraform plan $(TERRAFORM_PLAN_ARGS)
	@echo "\n\033[1;31m*** THIS PLAN IS NOT DEPLOYABLE. ***\033[0m"

sure: check-aws validate format tflint tfsec plan
