.PHONY: all check-aws init validate fmt tflint tfsec plan

all: check-aws init validate fmt tflint tfsec plan apply

check-aws:
	@echo "Checking AWS credentials..."
	@aws sts get-caller-identity > /dev/null 2>&1; if [ $$? -gt 0 ]; then \
		echo "An error occurred (ExpiredToken) when calling the GetCallerIdentity operation: The security token included in the request is expired"; \
		exit 254; \
	fi

init: check-aws
	@echo "Initializing Terraform..."
	@terraform init -backend=false -reconfigure -upgrade


validate: init
	@echo "Validating Terraform configuration..."
	@terraform validate

fmt:
	@echo "Formatting Terraform configuration..."
	@terraform fmt -recursive -diff -list=true

tflint:
	@echo "Running TFLint..."
	@tflint --fix

tfsec:
	@echo "Running TFSec..."
	@tfsec --config-file .tfsec.yaml --minimum-severity HIGH

plan:
	@echo "Creating Terraform plan..."
	@terraform plan -input=false
	@echo "\n\033[1;31m*** THIS PLAN IS NOT DEPLOYABLE. ***\033[0m"

sure: check-aws init validate fmt tflint tfsec plan
