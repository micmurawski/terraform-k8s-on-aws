.PHONY: install_githooks
install_githooks:
	cp makefiles/githooks/prepare-commit-msg .git/hooks/prepare-commit-msg
	cat makefiles/githooks/prepare-commit-msg > .git/hooks/prepare-commit-msg
