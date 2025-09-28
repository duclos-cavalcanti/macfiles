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
export TMUXP_CONFIGDIR="$HOME/Documents/macfiles/sessions"
export TERM='screen-256color-bce'
export BAT_THEME='ansi'
export PYLINTHOME="${XDG_DATA_HOME}/pylint"
export IPYTHONDIR="$HOME/.config/ipython/"
export CARGO_HOME="$HOME/.cargo/"
export LESSHISTFILE=-
export HISTFILE="${HOME}/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=10000

# Enable command auto-correction and completion
autoload -Uz compinit && compinit
autoload -Uz vcs_info
autoload -Uz is-at-least
autoload -U colors && colors

# emacs mode for CLI
set -o emacs

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt PROMPT_SUBST

if [[ -r /usr/share/git/completion/git-completion.zsh ]]; then
  source /usr/share/git/completion/git-completion.zsh
fi

if command -v brew &>/dev/null; then
    if [[ -d $(brew --prefix)/share/zsh-autosuggestions ]]; then
        source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    fi
    
    if [[ -d $(brew --prefix)/share/zsh-autocomplete ]]; then
        source $(brew --prefix)/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
    
        bindkey -M emacs              '^I'         menu-complete
        bindkey -M emacs "$terminfo[kcbt]" reverse-menu-complete
    
        bindkey -M emacs \
            "^[p"   .history-search-backward \
            "^[n"   .history-search-forward \
            "^P"    .up-line-or-history \
            "^[OA"  .up-line-or-history \
            "^[[A"  .up-line-or-history \
            "^N"    .down-line-or-history \
            "^[OB"  .down-line-or-history \
            "^[[B"  .down-line-or-history
    fi
fi

# PROMPTS
if [[ -n "$SSH_CONNECTION" ]]; then
    export PS1="%n@%m: %~ \$ "

elif [ -d "$HOME/.oh-my-zsh/" ]; then
    export ZSH="$HOME/.oh-my-zsh"
    export ZSH_THEME="robbyrussell"
    source $ZSH/oh-my-zsh.sh

    plugins=(
        macos 
        dotenv
    )

else
    __git_prompt_git() {
      GIT_OPTIONAL_LOCKS=0 command git "$@"
    }
    
    git_prompt_info() {
      local git_status ref ahead behind dirty untracked stash state diverge=""
    
      git_status=$(__git_prompt_git status --porcelain=2 --branch 2>/dev/null) || return
    
      # Extract branch name
      ref=$(echo "$git_status" | grep '^# branch.head' | cut -d ' ' -f3)
      [[ "$ref" == "(detached)" ]] && \
        ref="DETACHED@$(git rev-parse --short HEAD 2>/dev/null)"
    
      # Extract ahead/behind counts
      ahead=$(git rev-list --count @{upstream}..HEAD 2>/dev/null || echo 0)
      behind=$(git rev-list --count HEAD..@{upstream} 2>/dev/null || echo 0)
      [[ "$ahead" -gt 0 ]] && diverge+=" ↑${ahead}"
      [[ "$behind" -gt 0 ]] && diverge+=" ↓${behind}"
    
      # Check if dirty or untracked
      if echo "$git_status" | grep -q '^[12]'; then
        dirty="✗"
      fi
      if echo "$git_status" | grep -q '^?'; then
        untracked="?"
      fi
    
      # Stash check
      if __git_prompt_git stash list --quiet 2>/dev/null | grep -q .; then
        stash="$"
      fi
    
      # Repo state
      local gitdir
      gitdir=$(__git_prompt_git rev-parse --git-dir 2>/dev/null)
      if [[ -d "$gitdir/rebase-apply" ]]; then
        state="|REBASE"
      elif [[ -d "$gitdir/MERGE_HEAD" ]]; then
        state="|MERGING"
      elif [[ -f "$gitdir/BISECT_LOG" ]]; then
        state="|BISECTING"
      fi
    
      echo "%{$fg_bold[blue]%}git:(%{$fg[red]%}${ref}%{$fg_bold[blue]%})%{$fg_bold[blue]%}${diverge}%{$fg_bold[yellow]%}${dirty}${untracked}${stash}%{$fg_bold[blue]%}${state}%{$reset_color%} "
    }

    PROMPT='%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ ) %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)'
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
    export DYLD_LIBRARY_PATH="$HOMEBREW_PREFIX/lib:/usr/local/lib:/usr/lib:/usr/local/opt/sqlite/lib"
    export PKG_CONFIG_PATH="$HOMEBREW_PREFIX/opt/curl/lib/pkgconfig"
fi

# Python
if [[ -d ${HOME}/Library/Python/3.9/bin ]]; then
  export PATH=$PATH:${HOME}/Library/Python/3.9/bin
fi

# Lua
if command -v lua &>/dev/null; then
  export LUA_PATH=";;$HOME/Documents/programs/debugger.lua/?.lua"
  export PATH=$PATH:${HOME}/.luarocks/bin
  if [[ -d ${HOME}/Documents/programs/lua-language-server ]]; then
    export PATH=$PATH:${HOME}/Documents/programs/lua-language-server/bin
  fi
fi

# Java
if command -v java &>/dev/null; then
    if [[ -d /opt/homebrew ]]; then
        export JAVA_HOME="/opt/homebrew/opt/openjdk"
    else
        export JAVA_HOME="/usr/lib/jvm/java-18-openjdk/"
    fi
fi

# Ruby
if command -v ruby &>/dev/null; then
  export GEM_HOME="$HOME/.gems"
  export PATH=$PATH:${HOME}/.local/gem/ruby/3.0.0/bin:${HOME}/.gems/bin
fi

# Go
if command -v go &>/dev/null; then
  export GOPATH="$HOME/.go"
  export PATH=$PATH:${GOPATH}/bin
fi

# Rust
export PATH=$PATH:${HOME}/.cargo/bin

# Node.js and npm
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
  alias cat="bat -p"
fi

if command -v eza &>/dev/null; then
    alias ls="eza"
    alias sl="eza"
    alias la="eza -la"
    alias ll="eza -l"
else
    alias ls="ls --color=auto"
    alias sl="ls --color=auto"
    alias la="ls -a --color=auto"
    alias ll="ls -l --color=auto"
fi


alias '..'="cd .."
alias '...'="cd ../.."

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
alias glo='git log --pretty="oneline"'
alias glol='git log --graph --oneline --decorate'
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

if command -v fzf &>/dev/null; then
    export FZF_DEFAULT_COMMAND="fd --follow --hidden --type f --exclude .git --exclude VMs --exclude .cache --exclude .icons --exclude .local --exclude Programs --exclude snap --exclude quicklisp --exclude Music"
    export FZF_ALT_C_COMMAND="fd --follow --hidden --type d --exclude .git --exclude VMs --exclude .cache --exclude .icons --exclude .local --exclude Programs --exclude snap --exclude quicklisp --exclude Music"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

    [ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
    [ -f /opt/homebrew/opt/fzf/shell/completion.zsh ] && source /opt/homebrew/opt/fzf/shell/completion.zsh
fi
