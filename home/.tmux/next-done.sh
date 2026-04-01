#!/bin/bash

SIGNAL_DIR="$HOME/.cache/claude-signals"
current=$(tmux display-message -p '#{session_name}')

# Collect all sessions in order, starting after current
sessions=()
found_current=false
while read -r name; do
    if $found_current; then
        sessions+=("$name")
    fi
    if [[ "$name" == "$current" ]]; then
        found_current=true
    fi
done < <(tmux list-sessions -F '#{session_name}')

# Wrap around: add sessions before current
while read -r name; do
    [[ "$name" == "$current" ]] && break
    sessions+=("$name")
done < <(tmux list-sessions -F '#{session_name}')

# Switch to first session with a "done" signal
for name in "${sessions[@]}"; do
    if [[ -f "$SIGNAL_DIR/$name" ]] && [[ "$(cat "$SIGNAL_DIR/$name")" == "done" ]]; then
        tmux switch-client -t "$name"
        exit 0
    fi
done

tmux display-message "No sessions with 'done' signal"
