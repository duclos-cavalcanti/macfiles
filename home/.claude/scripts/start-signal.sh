#!/bin/bash

SIGNAL_DIR="$HOME/.cache/claude-signals"
mkdir -p "$SIGNAL_DIR"

SESSION=$(tmux display-message -p '#{session_name}' 2>/dev/null)
[[ -z "$SESSION" ]] && exit 0

touch "$SIGNAL_DIR/$SESSION"
