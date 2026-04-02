#!/bin/bash

SIGNAL_DIR="$HOME/.cache/claude-signals"
current=$(tmux display-message -p '#{session_name}')
sessions=""

while read -r name; do
    signal=""
    color=""
    [[ -f "$SIGNAL_DIR/$name" ]] && signal=$(cat "$SIGNAL_DIR/$name")

    if [[ "$name" == "$current" ]]; then
        color="#[fg=red,bold]"

    elif [[ "$signal" == "DONE" ]]; then
        color="#[fg=green,bold]"

    elif [[ "$signal" == "ACTIVE" ]]; then
        color="#[fg=white,bold]"

    elif [[ "$signal" == "ATTENTION" ]]; then
        color="#[fg=yellow,bold]"

    else
        color="#[fg=brightblack]"
    fi
    sessions="${sessions}${color} $name #[default]"
done < <(tmux list-sessions -F '#{session_name}')

echo "#[align=left]$sessions"
