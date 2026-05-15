#!/bin/bash
#
# Mark the current Claude Code session as "started" in the tmux
# statusline signal cache. Called by ~/.claude/scripts/start-signal.sh.
#
# Exits 1 if not inside a tmux session — caller decides how to react.

[[ -z "$TMUX" ]] && exit 1

SIGNAL_DIR="$HOME/.cache/claude-signals"
mkdir -p "$SIGNAL_DIR"

SESSION=$(tmux display-message -p '#{session_name}' 2>/dev/null) || exit 1
[[ -z "$SESSION" ]] && exit 1

touch "$SIGNAL_DIR/$SESSION"
