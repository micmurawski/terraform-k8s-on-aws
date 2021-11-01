#
# Public Variables
#

TERRAFORM_DIR ?= infra/terraform
TFENV_VERSION ?= 2.0.0

#
# Functions
#

terraform_get_output  = $(shell cat $(TERRAFORM_STATE_CACHE) | $(JQ) .$(1).value)

#
# Private Variables
#

TFENV_DIR := $(if $(shell command -v tfenv),$(shell dirname $$(dirname $$(command -v tfenv))),$(CACHE_DIR)/tfenv)
TFENV ?= $(TFENV_DIR)/bin/tfenv
TERRAFORM ?= $(TFENV_DIR)/bin/terraform
TERRAFORM_STATE_CACHE := $(CACHE_DIR)/$(TERRAFORM_WORKSPACE_NAME)-state.json

TERRAFORM_FILES := $(shell find $(TERRAFORM_DIR) -type f -iname "*.tf")

#
# Integration with root makefile
#

setup: terraform_init
deploy: terraform_apply
test: terraform_validate
destroy: terraform_destroy
clean: terraform_clean
distclean: terraform_distclean

#
# Targets
#

.PHONY: terraform_plan
terraform_plan: $(TERRAFORM) terraform_init $(TERRAFORM_DIR)/tfplan.out
	@


$(TERRAFORM_DIR)/tfplan.out: $(CACHE_DIR) $(TERRAFORM_FILES) terraform_init
ifneq ($(VAR_FILE),)
	cd $(TERRAFORM_DIR) && $(TERRAFORM) plan -var-file=../../../$(VAR_FILE) -out tfplan.out
else
	cd $(TERRAFORM_DIR) && $(TERRAFORM) plan -out tfplan.out
endif

.PHONY: terraform_apply
terraform_apply: terraform_plan
ifneq ($(VAR_FILE),)
	cd $(TERRAFORM_DIR) && $(TERRAFORM) apply -var-file=../../../$(VAR_FILE) -auto-approve tfplan.out
	rm $(TERRAFORM_DIR)/tfplan.out
else
	cd $(TERRAFORM_DIR) && $(TERRAFORM) apply -auto-approve tfplan.out
	rm $(TERRAFORM_DIR)/tfplan.out
endif

.PHONY: terraform_refresh
terraform_refresh: $(TERRAFORM) terraform_validate terraform_init
	cd $(TERRAFORM_DIR) && $(TERRAFORM) refresh


.PHONY: terraform_destroy
terraform_destroy: $(TERRAFORM) terraform_init
	cd $(TERRAFORM_DIR) && $(TERRAFORM) destroy -var-file=../../../$(BACKEND_CONFIG)

.PHONY: terraform_destroy_target
terraform_destroy_target: $(TERRAFORM) terraform_init
	cd infra/terraform && $(TERRAFORM) destroy -var-file=../../../$(BACKEND_CONFIG)


.PHONY: terraform_validate
terraform_validate: export AWS_DEFAULT_REGION=$(AWS_REGION)
terraform_validate: $(TERRAFORM_DIR)/backend.tf $(TERRAFORM) terraform_init
	cd $(TERRAFORM_DIR) && $(TERRAFORM) validate


.PHONY: terraform_init
terraform_init: $(TERRAFORM)
	cd $(TERRAFORM_DIR) && $(TERRAFORM) init -backend-config=../../../$(BACKEND_CONFIG)
#	cd $(TERRAFORM_DIR) && $(TERRAFORM) workspace new $(TERRAFORM_WORKSPACE_NAME)
#select $(TERRAFORM_WORKSPACE_NAME) -backend-config=$(BACKEND_CONFIG) || $(TERRAFORM) workspace new $(TERRAFORM_WORKSPACE_NAME) -backend-config=$(BACKEND_CONFIG)
#ifneq ($(BACKEND_CONFIG), "")
#	cd $(TERRAFORM_DIR) && $(TERRAFORM) init -backend-config=$(BACKEND_CONFIG)
#endif
#	cd $(TERRAFORM_DIR) && $(TERRAFORM) init -backend-config="bucket=$(TERRAFORM_BUCKET)" -backend=$(ALLOW_DEPLOY)
#
#ifeq ($(ALLOW_DEPLOY),true)
#	cd $(TERRAFORM_DIR) && $(TERRAFORM) workspace select $(TERRAFORM_WORKSPACE_NAME) || $(TERRAFORM) workspace new $(TERRAFORM_WORKSPACE_NAME)
#endif


.PHONY: terraform_state
terraform_state: $(TERRAFORM_STATE_CACHE)
	@:


# State should be redownloaded on each separate invocation of make.
.PHONY: $(TERRAFORM_STATE_CACHE)
$(TERRAFORM_STATE_CACHE): terraform_init
ifneq ($(ALLOW_DEPLOY),true)
	$(error "Cannot download Terraform state when ALLOW_DEPLOY is false")
endif
	cd $(TERRAFORM_DIR) && $(TERRAFORM) output -json | tee "$@"


.PHONY: terraform_clean
terraform_clean:
	rm -rf $(TERRAFORM_DIR)/.terraform
	rm -rf $(TERRAFORM_DIR)/tfplan.out


.PHONY: terraform_distclean
terraform_distclean:
	rm -rf $(CACHE_DIR)/tfenv

#
# Install Terraform
#

$(TFENV_DIR):
	curl -L "https://github.com/tfutils/tfenv/archive/v$(TFENV_VERSION).tar.gz" -o "/tmp/tfenv.tar.gz"
	mkdir -p $(TFENV_DIR)
	cd $(TFENV_DIR) && tar xzvf /tmp/tfenv.tar.gz --strip 1


$(TERRAFORM): $(TFENV_DIR)
	cd $(TERRAFORM_DIR) && PATH="$(PATH):$(TFENV_DIR)/bin" && $(TFENV) install $(shell cat $(TERRAFORM_DIR)/.terraform-version || printf "latest")
	cd $(TERRAFORM_DIR) && PATH="$(PATH):$(TFENV_DIR)/bin" && $(TFENV) use $(shell cat $(TERRAFORM_DIR)/.terraform-version || printf "latest")


.PHONY: terraform_fmt
terraform_fmt: $(TERRAFORM)
	cd $(TERRAFORM_DIR) && $(TERRAFORM) fmt -recursive
