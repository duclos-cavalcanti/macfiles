#!/bin/bash

# Skip if not in a tmux session — keeps the cmux workflow noise-free.
[[ -z "$TMUX" ]] && exit 0

SIGNAL_DIR="$HOME/.cache/claude-signals"
[[ -d "$SIGNAL_DIR" ]] || exit 0

SESSION=$(tmux display-message -p '#{session_name}' 2>/dev/null)
[[ -z "$SESSION" ]] && exit 0

echo "DONE" > "$SIGNAL_DIR/$SESSION"
