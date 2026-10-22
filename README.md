# dotfiles

Configuration files for MacOS.

## Description

- `.zshrc`: Common shell configuration.
- `.p10k.zsh`: Powerlevel10k prompt configuration.
- `wezterm/`: Configuration for the WezTerm terminal emulator.
- `nvim/`: Configuration for Neovim.
- `aerospace/`: Configuration for the AeroSpace window manager.
- `git/`: Git configuration (global ignore file and shared settings). Identity (`user.name`/`user.email`) belongs in `~/.gitconfig` on each machine, not this repo; `user.useConfigOnly` makes Git refuse to commit until it's set.

## Setup

```sh
./setup.sh <command> <component...>
```

Commands:

- `install`: Create symlinks for the given components.
- `clean`: Remove symlinks for the given components.
- `help`: Show usage.

Components:

| Component   | Effect                                                          |
| ----------- | --------------------------------------------------------------- |
| `nvim`      | `~/.config/nvim` → `nvim/`                                      |
| `wezterm`   | `~/.config/wezterm` → `wezterm/`                                |
| `aerospace` | `~/.config/aerospace` → `aerospace/`                            |
| `p10k`      | `~/.p10k.zsh` → `.p10k.zsh`                                     |
| `git`       | `~/.config/git` → `git/`                                        |
| `zshrc`     | Appends a line to `~/.zshrc` that sources this repo's `.zshrc`  |
| `all`       | Every component except `aerospace`                              |

If a destination already exists and isn't a symlink, it's backed up to `<path>.bak` first.

`clean zshrc` doesn't edit `~/.zshrc`; remove the source line manually.

Examples:

```sh
./setup.sh install all
./setup.sh install nvim wezterm
./setup.sh clean aerospace
```
