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
export MACFILES="$HOME/.macfiles"
export TMUXP_CONFIGDIR="$HOME/.macfiles/sessions"
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
if [[ -d /opt/homebrew ]]; then
    export HOMEBREW_PREFIX='/opt/homebrew'
    export HOMEBREW_CACHE="$XDG_CACHE_HOME/homebrew"
    export HOMEBREW_LOGS="$XDG_STATE_HOME/homebrew"

    export CA_BUNDLE="$HOMEBREW_PREFIX/opt/ca-certificates/share/ca-certificates/cacert.pem"
    export CURL_CA_BUNDLE="$CA_BUNDLE"

    export PATH=$PATH:$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$HOMEBREW_PREFIX/opt/curl/bin

    export CPLUS_INCLUDE_PATH="$HOMEBREW_PREFIX/include:/usr/local/include"
    export LDFLAGS="-L$HOMEBREW_PREFIX/lib -L$HOMEBREW_PREFIX/opt/libpq/lib -L$HOMEBREW_PREFIX/opt/curl/lib"
    export CPPFLAGS="-I$HOMEBREW_PREFIX/include -I/usr/local/include -I$HOMEBREW_PREFIX/opt/libpq/include -I$HOMEBREW_PREFIX/opt/curl/include"
    export LIBRARY_PATH="$HOMEBREW_PREFIX/lib:$HOMEBREW_PREFIX/opt/libpq/lib:/usr/local/lib:/usr/lib"
    export LD_LIBRARY_PATH="$HOMEBREW_PREFIX/lib:/usr/local/lib:/usr/lib"
    export PKG_CONFIG_PATH="$HOMEBREW_PREFIX/opt/curl/lib/pkgconfig"
    export DYLD_LIBRARY_PATH="$HOMEBREW_PREFIX/opt/sqlite/lib:$HOMEBREW_PREFIX/lib:/usr/local/lib"
fi

# Go
if command -v go &>/dev/null; then
    export GOPATH="$HOME/.go"
    export PATH=$PATH:$GOPATH/bin
fi

# Rust
export CARGO_HOME="$HOME/.cargo/"
export PATH=$PATH:$HOME/.cargo/bin

# Node.js
if command -v npm &>/dev/null; then
    export NPM_CONFIG_PREFIX="$HOME/.node_modules"
    export N_PREFIX="$HOME/.n"
    export NODE="$HOME/.n/bin/node"
    export PATH=$PATH:$HOME/.n/bin:$HOME/.node_modules:$HOME/.node_modules/bin
fi

# Aliases — general
alias v='nvim'

alias ls='ls --color=auto'
alias la='ls -a --color=auto'
alias ll='ls -l --color=auto'

alias ..='cd ..'
alias ...='cd ../..'
alias mv='mv -i'
alias cp='cp -i'
alias less='less -R'
alias diff='diff --color=auto'
alias grep='grep --colour=auto'

# Aliases — git
alias g='git status'
alias ga='git add'
alias gc='git checkout'
alias gcb='git checkout -b'
alias gm='git commit'
alias gl='git log'
alias glo='git log --pretty="oneline"'
alias glol='git log --graph --oneline --decorate'
alias gp='git pull'
alias gpo='git push origin'
alias gd='git diff --color=always'
alias gdd='git diff HEAD~1 HEAD'
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch -d'
alias gbD='git push --delete origin'
