#!/bin/bash

current_session=$(tmux display-message -p '#{session_name}')

while IFS= read -r entry; do
    session="${entry%%:*}"
    pane="${entry#*:}"
    if [ "$session" = "$current_session" ]; then
        tmux select-pane -t "$pane"
        exit 0
    fi
done < <(~/.tmux/agentic/find-agent.sh)
