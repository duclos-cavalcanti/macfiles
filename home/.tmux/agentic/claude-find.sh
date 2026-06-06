#!/bin/bash

for entry in $(tmux list-panes -s -F '#{session_name}:#{pane_id}:#{pane_pid}'); do
    session="${entry%%:*}"
    rest="${entry#*:}"
    pane="${rest%%:*}"
    pid="${rest##*:}"
    if pgrep -P "$pid" -f claude &>/dev/null; then
        echo "$session:$pane"
    fi
done
