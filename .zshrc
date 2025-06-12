
autoload -U colors && colors
# Load version control information
autoload -Uz vcs_infoAdd commentMore actions

# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:git:*' formats '{%b}'

# Define color codes
RED="%{$fg[red]%}"
RESET="%{$reset_color%}"
  
# Function to get virtual environment name
get_venv_name() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo "${RED}(${VIRTUAL_ENV##*/})${RESET} "
    fi
}

# Set up the prompt (with git branch name)
set_prompt() {
    PROMPT='$(get_venv_name) ${PWD/#$HOME/~} ${RED}${vcs_info_msg_0_}${RESET} $ '
}

# Set prompt initially
set_prompt

# Set prompt after each command
precmd() {
    vcs_info
    set_prompt
}
setopt PROMPT_SUBST

# Autocomplete Makefile targets
zstyle ':completion:*:*:make:*' tag-order 'targets'

autoload -U compinit && compinit

# Add color to directories
alias ls='ls -G'
