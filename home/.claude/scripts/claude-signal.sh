#!/bin/bash

SIGNAL_DIR="$HOME/.cache/claude-signals"
mkdir -p "$SIGNAL_DIR"

action="${1:-done}"
session=$(tmux display-message -p '#{session_name}' 2>/dev/null)

[[ -z "$session" ]] && exit 0

echo "$action" > "$SIGNAL_DIR/$session"
