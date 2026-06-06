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
