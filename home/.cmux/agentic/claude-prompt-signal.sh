#!/bin/bash
#
# cmux backend for the Claude Code UserPromptSubmit hook.
# Mirrors ~/.tmux/agentic/claude-prompt-signal.sh for the cmux environment.
#
# Exits 1 if not inside a cmux workspace — caller decides how to react.

[[ -z "$CMUX_WORKSPACE_ID" ]] && exit 1

# TODO: equivalent of writing "ACTIVE" to the tmux signal file.
# Candidates:
#   - cmux set-status claude_code "active" --color "#FFD166"
