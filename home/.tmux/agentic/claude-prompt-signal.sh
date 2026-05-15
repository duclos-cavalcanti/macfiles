#!/bin/bash
#
# Mark the current Claude Code session as "active" (user just submitted
# a prompt). Called by ~/.claude/scripts/prompt-signal.sh.
#
# Exits 1 if not inside a tmux session — caller decides how to react.

[[ -z "$TMUX" ]] && exit 1

SIGNAL_DIR="$HOME/.cache/claude-signals"
[[ -d "$SIGNAL_DIR" ]] || exit 1

SESSION=$(tmux display-message -p '#{session_name}' 2>/dev/null) || exit 1
[[ -z "$SESSION" ]] && exit 1

echo "ACTIVE" > "$SIGNAL_DIR/$SESSION"
