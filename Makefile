# Define the directory where your dotfiles repository is cloned
DOTFILES_REPO_DIR := $(HOME)/dotfiles

# Define the path to your machine's primary .zshrc file
LOCAL_ZSHRC := $(HOME)/.zshrc

.PHONY: install-zshrc-source check-dotfiles-repo

# This is the main target you'll run
install-zshrc-source: check-dotfiles-repo
	@echo "--- Ensuring dotfiles .zshrc is sourced in $(LOCAL_ZSHRC) ---"
	@if [ ! -d "$(DOTFILES_REPO_DIR)" ]; then \
		echo "Error: Dotfiles repository not found at $(DOTFILES_REPO_DIR)."; \
		echo "Please clone your dotfiles repo first: git clone https://github.com/yourusername/dotfiles.git $(DOTFILES_REPO_DIR)"; \
		exit 1; \
	fi
	@if ! grep -q "source \"$(DOTFILES_REPO_DIR)/.zshrc\"" "$(LOCAL_ZSHRC)"; then \
		echo "Adding source command to $(LOCAL_ZSHRC)..."; \
		echo "" >> "$(LOCAL_ZSHRC)"; \
		echo "# Load dotfiles from GitHub repo" >> "$(LOCAL_ZSHRC)"; \
		echo "if [ -f \"$(DOTFILES_REPO_DIR)/.zshrc\" ]; then" >> "$(LOCAL_ZSHRC)"; \
		echo "    source \"$(DOTFILES_REPO_DIR)/.zshrc\"" >> "$(LOCAL_ZSHRC)"; \
		echo "fi" >> "$(LOCAL_ZSHRC)"; \
		echo "Done. Please restart your shell or run 'source $(LOCAL_ZSHRC)' to apply changes."; \
	else \
		echo "Source command already present in $(LOCAL_ZSHRC). No changes needed."; \
	fi

# A helper target to remind the user to clone the repo
check-dotfiles-repo:
	@if [ ! -d "$(DOTFILES_REPO_DIR)" ]; then \
		echo "Warning: Dotfiles repository not found at $(DOTFILES_REPO_DIR)."; \
		echo "Please ensure your dotfiles repo is cloned there before running this target."; \
		echo "Example: git clone https://github.com/yourusername/dotfiles.git $(DOTFILES_REPO_DIR)"; \
	fi

