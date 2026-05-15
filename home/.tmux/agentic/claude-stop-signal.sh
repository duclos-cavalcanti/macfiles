#!/bin/bash
#
# Mark the current Claude Code session as stopped. Called by
# ~/.claude/scripts/stop-signal.sh.
#
# Usage: claude-stop-signal.sh [STATE]
#   STATE defaults to "DONE". Other states (e.g. "ERROR") let the
#   tmux statusline differentiate completion reasons.
#
# Exits 1 if not inside a tmux session — caller decides how to react.

[[ -z "$TMUX" ]] && exit 1

SIGNAL_DIR="$HOME/.cache/claude-signals"
[[ -d "$SIGNAL_DIR" ]] || exit 1

SESSION=$(tmux display-message -p '#{session_name}' 2>/dev/null) || exit 1
[[ -z "$SESSION" ]] && exit 1

echo "${1:-DONE}" > "$SIGNAL_DIR/$SESSION"
