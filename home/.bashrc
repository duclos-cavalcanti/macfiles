# Interactive guard
case $- in
  *i*) ;;
    *) return
esac

# Environment
export TERMINAL='Terminal'
export TERM='tmux-256color'
export VISUAL='nvim'
export EDITOR='nvim'
export PAGER='less'

# Custom
export MACFILES="$HOME/.macfiles"

# Configuration
export BAT_THEME='ansi'

# XDG
export XDG_DESKTOP_DIR="$HOME/Desktop"
export XDG_DOCUMENTS_DIR="$HOME/Documents"
export XDG_DOWNLOAD_DIR="$HOME/Downloads"
export XDG_MUSIC_DIR="$HOME/Music"
export XDG_PICTURES_DIR="$HOME/Pictures"
export XDG_PUBLICSHARE_DIR="$HOME/Public"
export XDG_TEMPLATES_DIR="$HOME/Templates"
export XDG_VIDEOS_DIR="$HOME/Videos"
export XDG_DATA_HOME="$HOME/.local/"
export XDG_CACHE_HOME="$HOME/.cache/"
export XDG_CONFIG_HOME="$HOME/.config/"
export XDG_STATE_HOME="$HOME/.local/state"

# History
export HISTFILE="$HOME/.bash_history"
export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTCONTROL=ignoreboth:erasedups

# Shell options
shopt -s histappend
shopt -s checkwinsize
shopt -s expand_aliases

# Completions
if [ -r /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi

if [ -r /usr/share/git/completion/git-completion.bash ]; then
    . /usr/share/git/completion/git-completion.bash
fi

# Prompt
if [ -n "$SSH_CONNECTION" ]; then
    export PS1="\u@\h: \w \$ "
else
    export PS1="\W \$ "
fi

export PS2=">> "
export PS4="> "

# PATH & toolchains
export PATH=$PATH:$HOME/.local/bin:$HOME/.bin

# Homebrew
if [[ -d /opt/homebrew/bin ]]; then
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
fi

# Rust
export CARGO_HOME="$HOME/.cargo/"
export PATH=$PATH:$HOME/.cargo/bin

# Aliases — general
alias v='nvim'

alias ls='ls --color=auto'
alias la='ls -a --color=auto'
alias ll='ls -l --color=auto'

alias ..='cd ..'
alias ...='cd ../..'
alias less='less -R'
alias diff='diff --color=auto'
alias grep='grep --colour=auto'
