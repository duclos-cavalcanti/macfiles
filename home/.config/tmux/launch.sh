#!/bin/bash

main() {
    cd "$HOME"/Work
    local folder=$(fd --follow --hidden --type d \
        --exclude .git \
        --exclude .cache \
        --exclude .local \
        --exclude node_modules \
        --exclude target \
        --exclude dist \
        -d 3 \
        .  \
        | sort \
        | fzf --layout=reverse --tmux center,60%,border-native --exit-0 --prompt="launch > ")

    [[ -z "$folder" ]] && exit 0
    local session=$(basename "$folder")

    if ! tmux has-session -t "$session" 2>/dev/null; then
        tmux new-session -d -s "$session" -c "$folder"
    fi
    
    tmux switch-client -t "$session"
}

main $@
