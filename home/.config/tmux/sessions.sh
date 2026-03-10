#!/bin/bash

main() {
    local session
    local sessions
    local max_len

    sessions=$(tmux list-sessions -F '#{session_name}|#{session_path}')
    max_len=$(echo "$sessions" | awk -F'|' '{print length($1)}' | sort -n | tail -1)
    session=$(echo "$sessions" | awk -F'|' -v max="$max_len" '{printf "%s|%-*s  %s\n", $1, max, $1, $2}' | \
        fzf --layout=reverse --tmux center,60%,border-native --exit-0 --delimiter='|' --with-nth=2 | \ 
        cut -d'|' -f1)

    if [[ -n "$session" ]]; then
        tmux switch-client -t "$session"
    fi
}

main $@
