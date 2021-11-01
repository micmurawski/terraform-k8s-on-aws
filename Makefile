#
# Configuration
#

PROJECT_NAME = aws-k8s-terraform-infra
AWS_REGION ?= us-east-1
BUILD_NUMBER ?= 0
TERRAFORM_DIR = deployment

include makefiles/root.mk
include makefiles/python.mk
include makefiles/terraform.mk
include makefiles/githooks.mk

.PHONY: project_name
project_name:
	@echo -n $(PROJECT_NAME)
