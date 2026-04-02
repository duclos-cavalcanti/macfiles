#!/bin/bash

SIGNAL_DIR="$HOME/.cache/claude-signals"
[[ ! -d "$SIGNAL_DIR" ]] && exit 0

SESSION=$(tmux display-message -p '#{session_name}' 2>/dev/null)
[[ -z "$SESSION" ]] && exit 0

tmux resize-window -A
tmux refresh-client -S

echo "IDLE" > "$SIGNAL_DIR/$SESSION"
