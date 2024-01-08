# Terraform Modules for AWS Infrastructure (Blueprints)

This repository hosts the essential Terraform modules for the AWS infrastructure as part of the project. It includes modules for networking, EKS setup, and application-specific configurations. This README covers how to use these modules and the commands available through the Makefile for managing Terraform configurations.

## Modules

- **Network Module**: Sets up the VPC, subnets, and other networking resources.
- **EKS Module**: Configures AWS Elastic Kubernetes Service (EKS).
- **App Module**: Deploys application-specific resources like S3 buckets and CloudFront distributions.

## Prerequisites

- Terraform: Ensure Terraform is installed and configured.
- AWS CLI: The AWS Command Line Interface should be installed and configured with necessary permissions.
- TFLint: A Terraform linter tool for identifying possible errors and enforcing best practices.
- TFSec: A security analysis tool for Terraform code.

## Makefile Commands

The Makefile includes several commands to simplify Terraform workflows:

- `make check-aws`: Verifies AWS credentials.
- `make init`: Initializes Terraform.
- `make validate`: Validates Terraform configuration.
- `make format`: Formats Terraform configuration files.
- `make tflint`: Runs TFLint for Terraform code.
- `make tfsec`: Executes TFSec for security checks.
- `make plan`: Generates a Terraform plan (non-deployable).
- `make sure`: Runs a sequence of commands (`check-aws`, `validate`, `format`, `tflint`, `tfsec`, `plan`) for thorough checking and planning.

## Usage

To utilize the modules in this repository:

1. Clone the repository to your local machine.
2. Navigate to the module directory (e.g., `cd modules/network`).
3. Use the Terraform commands or Makefile targets to manage the infrastructure.
4. Refer to the specific README within each module for detailed instructions.

### Sample Workflow

1. Check AWS credentials:
   ```bash
   make check-aws
   ```
2. Initialize Terraform:
   ```bash
   make init
   ```
3. Validate, format, and run security checks:
   ```bash
   make sure
   ```
4. Create a plan:
   ```bash
   make plan
   ```

## Troubleshooting

- Use the `make sure` command to catch common issues before applying changes.
- In case of Terraform errors, refer to the specific error message and check against the module documentation for potential fixes.

## Notes

- The modules in this repository are designed for use in the project and may have specific configurations tailored to the project's needs.
- Ensure to keep the AWS credentials and Terraform state files secure and manage access appropriately.
