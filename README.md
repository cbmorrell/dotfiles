# dotfiles

Configuration files for MacOS.

## Description

- `.zshrc`: Common shell configuration.
- `.p10k.zsh`: Powerlevel10k prompt configuration.
- `config/wezterm`: Configuration for the WezTerm terminal emulator.
- `config/nvim`: Configuration for Neovim.

## Setup

```sh
./install.sh
```

This will:

- Add a command to `~/.zshrc` to source this repo's `.zshrc`.
- Create symlinks for `wezterm`, `nvim`, and `.p10k.zsh`.

To remove the symlinks:

```sh
./install.sh clean
```

