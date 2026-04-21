#!/bin/zsh

# Resolve the absolute path of the directory this script lives in.
# dirname "$0" gives the script's directory (possibly relative, e.g. "."),
# so we cd into it and use pwd to get the full absolute path.
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

symlink() {
  local src="$1"
  local dst="$2"

  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "Warning: $dst already exists and is not a symlink. Backing it up to $dst.bak"
    mv "$dst" "$dst.bak"
  fi

  if [ ! -L "$dst" ]; then
    echo "Creating symlink: $src -> $dst"
    ln -sf "$src" "$dst"
  else
    echo "Symlink $dst already exists. Skipping creation."
  fi
}

install() {
  # Ensure .config exists if it doesn't
  mkdir -p "$HOME/.config"

  # Neovim
  echo "--- Installing Neovim configuration ---"
  symlink "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"

  # WezTerm
  echo "--- Installing WezTerm configuration ---"
  symlink "$DOTFILES_DIR/config/wezterm" "$HOME/.config/wezterm"

  # Powerlevel10k
  echo "--- Installing Powerlevel10k configuration ---"
  symlink "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

  # Git
  echo "--- Installing Git configuration ---"
  symlink "$DOTFILES_DIR/config/git/gitignore_global" "$HOME/.gitignore_global"
  git config --global core.excludesfile "$HOME/.gitignore_global"

  # Ensure dotfiles .zshrc is sourced
  echo "--- Ensuring dotfiles .zshrc is sourced in $HOME/.zshrc ---"
  if ! grep -q "source \"$DOTFILES_DIR/.zshrc\"" "$HOME/.zshrc"; then
    echo "" >> "$HOME/.zshrc"
    echo "# Load dotfiles" >> "$HOME/.zshrc"
    echo "if [ -f \"$DOTFILES_DIR/.zshrc\" ]; then" >> "$HOME/.zshrc"
    echo "    source \"$DOTFILES_DIR/.zshrc\"" >> "$HOME/.zshrc"
    echo "fi" >> "$HOME/.zshrc"
    echo "Done. Please restart your shell or run 'source $HOME/.zshrc' to apply changes."
  else
    echo "Source command already present in $HOME/.zshrc. No changes needed."
  fi
}

clean() {
  echo "--- Cleaning up dotfiles symlinks ---"
  rm -f "$HOME/.config/nvim"
  rm -f "$HOME/.config/wezterm"
  rm -f "$HOME/.p10k.zsh"
  rm -f "$HOME/.gitignore_global"
  echo "Clean up complete. You may need to manually remove the source line from $HOME/.zshrc."
}

help() {
  echo "Usage: ./install.sh [command]"
  echo ""
  echo "Commands:"
  echo "  install   Create symlinks and configure ~/.zshrc"
  echo "  clean     Remove symlinks"
  echo "  help      Show this help message"
}

if [ "$1" = "install" ]; then
  install
elif [ "$1" = "clean" ]; then
  clean
elif [ "$1" = "help" ]; then
  help
else
  echo "Unknown command: $1"
  help
  exit 1
fi
