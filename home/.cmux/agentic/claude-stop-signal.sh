#!/bin/bash
#
# cmux backend for the Claude Code Stop hook.
# Mirrors ~/.tmux/agentic/claude-stop-signal.sh for the cmux environment.
#
# Usage: claude-stop-signal.sh [STATE]
#   STATE defaults to "DONE".
#
# Exits 1 if not inside a cmux workspace — caller decides how to react.

[[ -z "$CMUX_WORKSPACE_ID" ]] && exit 1

# TODO: equivalent of writing the STATE to the tmux signal file.
# Candidates:
#   - cmux set-status claude_code "${1:-DONE}" --color "#7BC47F"
#   - cmux notify --title "Claude" --body "${1:-DONE}"
