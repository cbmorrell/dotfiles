# dotfiles

Configuration files for MacOS.

## Description

- `.zshrc`: Common shell configuration.
  - `Shift-Enter` inserts a newline instead of running the command, for writing multi-line commands. Relies on WezTerm sending `Shift-Enter` as `\e[13;2u` (see `wezterm/helpers/navigation.lua`).
  - [fzf](https://github.com/junegunn/fzf) shell integration when `fzf` is installed (`brew install fzf`), using [fd](https://github.com/sharkdp/fd) to list files when it's installed (`brew install fd`):
    - `Ctrl-T`: fuzzy-pick files and paste them into the command line.
    - `Ctrl-R`: fuzzy-search shell history.
    - `Ctrl-O`: fuzzy-pick a directory and `cd` into it (moved from fzf's default `Alt-C`).
    - `**<Tab>`: fuzzy completion, e.g. `vim **<Tab>`.
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
