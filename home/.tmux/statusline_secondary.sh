#!/bin/bash

SIGNAL_DIR="$HOME/.cache/claude-signals"
current=$(tmux display-message -p '#{session_name}')
sessions=""

while read -r name; do
    signal=""
    [[ -f "$SIGNAL_DIR/$name" ]] && signal=$(cat "$SIGNAL_DIR/$name")

    if [[ "$name" == "$current" ]]; then
        sessions="$sessions#[fg=red,bold] $name #[default]"
    elif [[ "$signal" == "done" ]]; then
        sessions="$sessions#[fg=green,bold] $name #[default]"
    elif [[ "$signal" == "attention" ]]; then
        sessions="$sessions#[fg=yellow,bold] $name #[default]"
    else
        sessions="$sessions#[fg=brightblack] $name #[default]"
    fi
done < <(tmux list-sessions -F '#{session_name}')

echo "#[align=centre]$sessions"
