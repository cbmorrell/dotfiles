# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

autoload -U colors && colors

# Autocomplete Makefile targets
zstyle ':completion:*:*:make:*' tag-order 'targets'

autoload -U compinit && compinit

# fzf key bindings (Ctrl-T, Ctrl-R, Alt-C) and fuzzy completion (**<Tab>)
if command -v fzf >/dev/null; then
  export FZF_DEFAULT_OPTS='--height 40% --layout reverse --border'

  # Use fd to list files/directories: faster than find, includes hidden files,
  # and respects .gitignore
  if command -v fd >/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
  fi

  source <(fzf --zsh)

  # Move the cd widget from Alt-C to Ctrl-O so all fzf bindings use Ctrl
  bindkey -r '\ec'
  bindkey '^O' fzf-cd-widget
fi

# Add color to directories
alias ls='ls -G'

# Shift+Enter inserts a literal newline for multi-line commands (WezTerm
# sends this as the CSI-u sequence for Shift+Enter). self-insert-unmeta
# only works for the 2-byte ESC-CR case (Alt+Enter), so use a dedicated
# widget that inserts a newline for this longer sequence.
insert-newline() { LBUFFER+=$'\n' }
zle -N insert-newline
bindkey "^[[13;2u" insert-newline

source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
