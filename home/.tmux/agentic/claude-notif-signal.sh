#!/bin/bash
#
# Mark the current Claude Code session as needing the user's attention
# (Claude raised a Notification event). Called by
# ~/.claude/scripts/notif-signal.sh.
#
# Exits 1 if not inside a tmux session — caller decides how to react.

[[ -z "$TMUX" ]] && exit 1

SIGNAL_DIR="$HOME/.cache/claude-signals"
[[ -d "$SIGNAL_DIR" ]] || exit 1

SESSION=$(tmux display-message -p '#{session_name}' 2>/dev/null) || exit 1
[[ -z "$SESSION" ]] && exit 1

echo "ATTENTION" > "$SIGNAL_DIR/$SESSION"
