#
# Public Variables
#

PYTHON_VENV ?= venv
TERRAFORM_STATE_CACHE := $(ROOTDIR)/$(CACHE_DIR)/terraform/$(TERRAFORM_WORKSPACE_NAME)-state.json

#
# Functions
#
in_venv = . $(PYTHON_VENV)/bin/activate && $(1)
#
# Integration with root Makefile
#

setup: python_venv
lint: python_lint
distclean: python_distclean

#
# Main Python commands
#


.PHONY: python_venv
python_venv: $(PYTHON_VENV)
	@:

.PHONY: python_distclean
python_distclean:
	rm -rf "$(PYTHON_VENV)"
	rm -rf ".pytest_cache"

#
# Virtual Env
#

install_dependencies: export PIP_PROCESS_DEPENDENCY_LINKS=1
install_dependencies: $(PYTHON_VENV)
	$(call in_venv,$(PIP) install --upgrade 'pip')
ifneq ($(wildcard ./setup.py),)
	$(call in_venv,$(PIP) install --editable .)
endif

$(PYTHON_VENV):
	$(PYTHON) -m venv "$@"
	touch $(PYTHON_VENV)

.PHONY: python_lint
python_lint: $(PYTHON_VENV)
	$(call in_venv,$(PIP) install -q -r linting/requirements.txt)
	$(call in_venv,$(BASH) linting/lint.sh)
