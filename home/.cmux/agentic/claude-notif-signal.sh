#!/bin/bash
#
# cmux backend for the Claude Code Notification hook.
# Mirrors ~/.tmux/agentic/claude-notif-signal.sh for the cmux environment.
#
# Exits 1 if not inside a cmux workspace — caller decides how to react.

[[ -z "$CMUX_WORKSPACE_ID" ]] && exit 1

# TODO: equivalent of writing "ATTENTION" to the tmux signal file.
# Candidates:
#   - cmux set-status claude_code "needs attention" --color "#E76F51"
#   - cmux notify --title "Claude" --body "needs attention"
#   - cmux trigger-flash  (highlight the workspace in the sidebar)
