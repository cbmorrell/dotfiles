#!/bin/zsh

# Resolve the absolute path of the directory this script lives in.
# dirname "$0" gives the script's directory (possibly relative, e.g. "."),
# so we cd into it and use pwd to get the full absolute path.
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

COMPONENTS=(nvim wezterm docker p10k git zshrc)

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

install_component() {
  case "$1" in
    nvim)
      echo "--- Installing Neovim configuration ---"
      mkdir -p "$HOME/.config"
      symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
      ;;
    wezterm)
      echo "--- Installing WezTerm configuration ---"
      mkdir -p "$HOME/.config"
      symlink "$DOTFILES_DIR/wezterm" "$HOME/.config/wezterm"
      ;;
    aerospace)
      echo "--- Installing Aerospace configuration ---"
      mkdir -p "$HOME/.config"
      symlink "$DOTFILES_DIR/aerospace" "$HOME/.config/aerospace"
      ;;
    docker)
      echo "--- Installing Docker configuration ---"
      mkdir -p "$HOME/.docker"
      symlink "$DOTFILES_DIR/docker/config.json" "$HOME/.docker/config.json"
      ;;
    p10k)
      echo "--- Installing Powerlevel10k configuration ---"
      symlink "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
      ;;
    git)
      echo "--- Installing Git configuration ---"
      symlink "$DOTFILES_DIR/git/gitignore_global" "$HOME/.gitignore_global"
      git config --global core.excludesfile "$HOME/.gitignore_global"
      ;;
    zshrc)
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
      ;;
    all)
      for c in "${COMPONENTS[@]}"; do install_component "$c"; done
      ;;
    *)
      echo "Unknown component: $1"
      echo "Available components: ${COMPONENTS[*]}"
      exit 1
      ;;
  esac
}

remove_symlink() {
  local path="$1"
  if [ -L "$path" ]; then
    /bin/rm -f "$path"
    echo "Removed symlink: $path"
  else
    echo "No symlink found at $path. Skipping."
  fi
}

clean_component() {
  case "$1" in
    nvim)
      echo "--- Cleaning Neovim configuration ---"
      remove_symlink "$HOME/.config/nvim"
      ;;
    wezterm)
      echo "--- Cleaning WezTerm configuration ---"
      remove_symlink "$HOME/.config/wezterm"
      ;;
    aerospace)
      echo "--- Cleaning Aerospace configuration ---"
      remove_symlink "$HOME/.config/aerospace"
      ;;
    docker)
      echo "--- Cleaning Docker configuration ---"
      remove_symlink "$HOME/.docker/config.json"
      ;;
    p10k)
      echo "--- Cleaning Powerlevel10k configuration ---"
      remove_symlink "$HOME/.p10k.zsh"
      ;;
    git)
      echo "--- Cleaning Git configuration ---"
      remove_symlink "$HOME/.gitignore_global"
      ;;
    zshrc)     echo "Note: remove the dotfiles source line from $HOME/.zshrc manually." ;;
    all)
      for c in "${COMPONENTS[@]}"; do clean_component "$c"; done
      ;;
    *)
      echo "Unknown component: $1"
      echo "Available components: ${COMPONENTS[*]}"
      exit 1
      ;;
  esac
}

help() {
  echo "Usage: ./install.sh <command> <component...>"
  echo ""
  echo "Commands:"
  echo "  install <component...>   Create symlinks for the given components"
  echo "  clean <component...>     Remove symlinks for the given components"
  echo "  help                     Show this help message"
  echo ""
  echo "Components: ${COMPONENTS[*]}"
  echo ""
  echo "Examples:"
  echo "  ./install.sh install all"
  echo "  ./install.sh install nvim wezterm"
  echo "  ./install.sh clean aerospace"
}

cmd="$1"
shift

if [ "$cmd" = "install" ]; then
  if [ $# -eq 0 ]; then
    echo "Error: no component specified."
    help
    exit 1
  fi
  for component in "$@"; do
    install_component "$component"
  done
elif [ "$cmd" = "clean" ]; then
  if [ $# -eq 0 ]; then
    echo "Error: no component specified."
    help
    exit 1
  fi
  for component in "$@"; do
    clean_component "$component"
  done
elif [ "$cmd" = "help" ]; then
  help
else
  echo "Unknown command: $cmd"
  help
  exit 1
fi
