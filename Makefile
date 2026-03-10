# Define the directory where your dotfiles repository is cloned
DOTFILES_REPO_DIR := $(HOME)/dotfiles

# Define the path to your machine's primary .zshrc file
LOCAL_ZSHRC := $(HOME)/.zshrc

# Define common configuration directories
NVIM_CONFIG_DIR := $(HOME)/.config/nvim
WEZTERM_CONFIG_DIR := $(HOME)/.config/wezterm
LOCAL_P10K := $(HOME)/.p10k.zsh

.PHONY: all install-zshrc-source install-nvim-config install-wezterm-config install-p10k-config clean help check-dotfiles-repo

all: install-zshrc-source install-nvim-config install-wezterm-config install-p10k-config ## Install all dotfiles configurations

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

install-nvim-config: check-dotfiles-repo
	@echo "--- Installing Neovim configuration ---"
	@mkdir -p $(dir $(NVIM_CONFIG_DIR)) # Ensure ~/.config exists if it doesn't
	@if [ -e "$(NVIM_CONFIG_DIR)" ] && [ ! -L "$(NVIM_CONFIG_DIR)" ]; then \
		echo "Warning: $(NVIM_CONFIG_DIR) already exists and is not a symlink. Backing it up to $(NVIM_CONFIG_DIR).bak"; \
		mv "$(NVIM_CONFIG_DIR)" "$(NVIM_CONFIG_DIR).bak"; \
	fi
	@if [ ! -L "$(NVIM_CONFIG_DIR)" ]; then \
		echo "Creating symlink: $(DOTFILES_REPO_DIR)/config/nvim -> $(NVIM_CONFIG_DIR)"; \
		ln -sf "$(DOTFILES_REPO_DIR)/config/nvim" "$(NVIM_CONFIG_DIR)"; \
	else \
		echo "Symlink $(NVIM_CONFIG_DIR) already exists. Skipping creation."; \
	fi

install-wezterm-config: check-dotfiles-repo
	@echo "--- Installing WezTerm configuration ---"
	@mkdir -p $(dir $(WEZTERM_CONFIG_DIR)) # Ensure ~/.config exists if it doesn't
	@if [ -e "$(WEZTERM_CONFIG_DIR)" ] && [ ! -L "$(WEZTERM_CONFIG_DIR)" ]; then \
		echo "Warning: $(WEZTERM_CONFIG_DIR) already exists and is not a symlink. Backing it up to $(WEZTERM_CONFIG_DIR).bak"; \
		mv "$(WEZTERM_CONFIG_DIR)" "$(WEZTERM_CONFIG_DIR).bak"; \
	fi
	@if [ ! -L "$(WEZTERM_CONFIG_DIR)" ]; then \
		echo "Creating symlink: $(DOTFILES_REPO_DIR)/config/wezterm -> $(WEZTERM_CONFIG_DIR)"; \
		ln -sf "$(DOTFILES_REPO_DIR)/config/wezterm" "$(WEZTERM_CONFIG_DIR)"; \
	else \
		echo "Symlink $(WEZTERM_CONFIG_DIR) already exists. Skipping creation."; \
	fi

install-p10k-config: check-dotfiles-repo
	@echo "--- Installing Powerlevel10k configuration ---"
	@if [ -e "$(LOCAL_P10K)" ] && [ ! -L "$(LOCAL_P10K)" ]; then \
		echo "Warning: $(LOCAL_P10K) already exists and is not a symlink. Backing it up to $(LOCAL_P10K).bak"; \
		mv "$(LOCAL_P10K)" "$(LOCAL_P10K).bak"; \
	fi
	@if [ ! -L "$(LOCAL_P10K)" ]; then \
		echo "Creating symlink: $(DOTFILES_REPO_DIR)/.p10k.zsh -> $(LOCAL_P10K)"; \
		ln -sf "$(DOTFILES_REPO_DIR)/.p10k.zsh" "$(LOCAL_P10K)"; \
	else \
		echo "Symlink $(LOCAL_P10K) already exists. Skipping creation."; \
	fi

clean:
	@echo "--- Cleaning up dotfiles symlinks ---"
	@rm -f "$(NVIM_CONFIG_DIR)"
	@rm -f "$(WEZTERM_CONFIG_DIR)"
	@rm -f "$(LOCAL_P10K)"
	@echo "Clean up complete. You may need to manually remove the source line from $(LOCAL_ZSHRC)."

check-dotfiles-repo:
	@if [ ! -d "$(DOTFILES_REPO_DIR)" ]; then \
		echo "Warning: Dotfiles repository not found at $(DOTFILES_REPO_DIR)."; \
		echo "Please ensure your dotfiles repo is cloned there before running this target."; \
		echo "Example: git clone https://github.com/yourusername/dotfiles.git $(DOTFILES_REPO_DIR)"; \
	fi

help: ## Show this help.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
