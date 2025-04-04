export AWS_PROFILE=custo-eng-dev

export VISUAL='nvim'
export EDITOR="nvim"
export GIT_EDITOR='nvim'
export DIFFPROG='nvim'
export PAGER='less'
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
export TMUXP_CONFIGDIR="$HOME/.dotfiles/sessions"
export TERM='xterm-256color'
export BAT_THEME='ansi'
export PYLINTHOME="${XDG_DATA_HOME}/pylint"
export IPYTHONDIR="$HOME/.config/ipython/"
export CARGO_HOME="$HOME/.cargo/"
export LESSHISTFILE=-

# Enable command auto-correction and completion
autoload -Uz compinit && compinit
autoload -Uz vcs_info

# Set history options
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY

set -o emacs

zstyle ':vcs_info:*'        enable git
zstyle ':vcs_info:git:*'    formats '%F{green}(%b%u%c%f) ' # Show branch name
zstyle ':vcs_info:git:*'    actionformats '%F{red}(%b|%a%u%c%f) ' # Show if in rebase, merge, etc.
zstyle ':vcs_info:git:*'    unstagedstr '%F{yellow}*%f' # Indicator for unstaged changes
zstyle ':vcs_info:git:*'    stagedstr '%F{red}+%f' # Indicator for staged changes
zstyle ':vcs_info:git:*'    check-for-changes true

if [[ -r /usr/share/git/completion/git-completion.zsh ]]; then
  source /usr/share/git/completion/git-completion.zsh
elif [[ -r /etc/bash_completion.d/git ]]; then
  source /etc/bash_completion.d/git
fi

[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ] && source /opt/homebrew/opt/fzf/shell/completion.zsh

if [[ -r /usr/share/git/completion/git-prompt.sh ]]; then
  source /usr/share/git/completion/git-prompt.sh
elif [[ -r /etc/bash_completion.d/git-prompt ]]; then
  source /etc/bash_completion.d/git-prompt
fi

if command -v fzf &>/dev/null; then
    fzf_dirs=(
      /usr/share/fzf/key-bindings.zsh
      /usr/share/fzf/completion.zsh
      /usr/share/doc/fzf/examples/key-bindings.zsh
    )
    for d in ${fzf_dirs[@]}; do
      [[ -e ${d} ]] && source ${d}
    done

    export FZF_DEFAULT_COMMAND="fd --follow --hidden --type f --exclude .git --exclude VMs --exclude .cache --exclude .icons --exclude .local --exclude Programs --exclude snap --exclude quicklisp --exclude Music"
    export FZF_ALT_C_COMMAND="fd --follow --hidden --type d --exclude .git --exclude VMs --exclude .cache --exclude .icons --exclude .local --exclude Programs --exclude snap --exclude quicklisp --exclude Music"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# PROMPTS
_prompt() {
  precmd() { vcs_info }
  setopt prompt_subst
  PROMPT='%F{blue}%~ %F{white}${vcs_info_msg_0_}%f%(?.%F{green}.%F{red})%#%f '
}

if [[ -n "$SSH_CONNECTION" ]]; then
  export PS1="%n@%m: %~ \$ "
else
  _prompt
fi

export PS2=">> "
export PS4="> "

# PATH
export PATH=$PATH:${HOME}/.local/bin:${HOME}/.bin

# Homebrew
if [[ -d /opt/homebrew ]]; then
    export PATH=$PATH:/opt/homebrew/bin
    export HOMEBREW_PREFIX="/opt/homebrew"
    export HOMEBREW_CACHE="$XDG_CACHE_HOME/homebrew"
    export HOMEBREW_LOGS="$XDG_STATE_HOME/homebrew"

    export CA_BUNDLE="$HOMEBREW_PREFIX/opt/ca-certificates/share/ca-certificates/cacert.pem"
    export CURL_CA_BUNDLE="$CA_BUNDLE"

    # export SDKMAN_DIR="$(brew --prefix sdkman-cli)/libexec"

    export PATH=$PATH:$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$HOMEBREW_PREFIX/opt/curl/bin

    export LIBRARY_PATH=$LIBRARY_PATH:/opt/homebrew/lib
    export INCLUDE_PATH=$INCLUDE_PATH:/opt/homebrew/include

    export CPLUS_INCLUDE_PATH="$HOMEBREW_PREFIX/include:/usr/local/include"
    export LDFLAGS="-L$HOMEBREW_PREFIX/lib -L$HOMEBREW_PREFIX/opt/libpq/lib -L$HOMEBREW_PREFIX/opt/curl/lib"
    export CPPFLAGS="-I$HOMEBREW_PREFIX/include -I/usr/local/include -I$HOMEBREW_PREFIX/opt/libpq/include -I$HOMEBREW_PREFIX/opt/curl/include"
    export LIBRARY_PATH="$HOMEBREW_PREFIX/lib:$HOMEBREW_PREFIX/opt/libpq/lib:/usr/local/lib:/usr/lib"
    export LD_LIBRARY_PATH="$HOMEBREW_PREFIX/lib:/usr/local/lib:/usr/lib"
    export DYLD_LIBRARY_PATH="$HOMEBREW_PREFIX/lib:/usr/local/lib:/usr/lib"
    export PKG_CONFIG_PATH="$HOMEBREW_PREFIX/opt/curl/lib/pkgconfig"
fi

if [[ -d ${HOME}/Library/Python/3.9/bin ]]; then
  export PATH=$PATH:${HOME}/Library/Python/3.9/bin
fi

# Lua setup
if command -v lua &>/dev/null; then
  export LUA_PATH=";;$HOME/Documents/programs/debugger.lua/?.lua"
  export PATH=$PATH:${HOME}/.luarocks/bin
  if [[ -d ${HOME}/Documents/programs/lua-language-server ]]; then
    export PATH=$PATH:${HOME}/Documents/programs/lua-language-server/bin
  fi
fi

# Java setup
if command -v java &>/dev/null; then
  export JAVA_HOME="/usr/lib/jvm/java-18-openjdk/"
fi

# Ruby setup
if command -v ruby &>/dev/null; then
  export GEM_HOME="$HOME/.gems"
  export PATH=$PATH:${HOME}/.local/gem/ruby/3.0.0/bin:${HOME}/.gems/bin
fi

# Go setup
if command -v go &>/dev/null; then
  export GOPATH="$HOME/.go"
  export PATH=$PATH:${GOPATH}/bin
fi

# Rust setup
export PATH=$PATH:${HOME}/.cargo/bin

# Node.js and npm setup
if command -v npm &>/dev/null; then
  export NPM_CONFIG_PREFIX="${HOME}/.node_modules"
  export N_PREFIX="${HOME}/.n"
  export NODE="${HOME}/.n/bin/node"
  export PATH=$PATH:${HOME}/.n/bin:${HOME}/.node_modules:${HOME}/.node_modules/bin
fi

# ALIASES
alias e="vim"
alias v="nvim"

if command -v bat &>/dev/null || command -v batcat &>/dev/null; then
  # alias bat="batcat"
  alias cat="bat -p"
fi

if command -v exa &>/dev/null; then
  alias ls="exa"
  alias tree="exa --tree"
fi


alias '..'="cd .."
alias '...'="cd ../.."

alias ls="ls --color=auto"
alias sl="ls --color=auto"
alias la="ls -a --color=auto"
alias ll="ls -l --color=auto"

alias mv="mv -i"
alias cp="cp -i"

alias less='less -R'
alias diff="diff --color=auto"

alias grep='grep --colour=always'
alias egrep='egrep --colour=always'
alias fgrep='fgrep --colour=always'

alias gupd="git add --all && git commit -m 'Update' && git push origin"
alias grd="git add README.md && git commit -m 'Updated README' && git push origin"
alias gi="git add .gitignore && git commit -m 'Updated gitignore' && git push origin"
alias gmk="git add Makefile && git commit -m 'Updated Makefile' && git push origin"
alias gada="git add --all && git commit"
alias g="git status"
alias gunchange="git update-index --assume-unchanged"
alias ga="git add"
alias gc="git checkout"
alias gcb="git checkout -b"
alias gm="git commit"
alias gmm="git commit -m"
alias gl="git log"
alias gpo="git push origin"
alias gd="git diff --color=always"
alias gdd="git diff HEAD~1 HEAD"
alias gba="git branch --all"
alias gb="git branch"
alias gbd="git branch -d"
alias gbD="git push --delete origin"
alias greset="git reset --hard"
alias greb="git rebase -i --root"

alias azlog="az login"
alias metlog="az acr login -n metacodev"

cd() {
  builtin cd "$@" && ls --color=auto
}
