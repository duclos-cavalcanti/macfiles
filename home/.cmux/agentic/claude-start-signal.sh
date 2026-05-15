#!/bin/bash
#
# cmux backend for the Claude Code SessionStart hook.
# Mirrors ~/.tmux/agentic/claude-start-signal.sh for the cmux environment.
#
# Exits 1 if not inside a cmux workspace — caller decides how to react.

[[ -z "$CMUX_WORKSPACE_ID" ]] && exit 1

# TODO: equivalent of touch "$SIGNAL_DIR/$SESSION" in the tmux backend.
# Candidates:
#   - cmux set-status claude_code "started" --icon sparkle
#   - write to a cmux-side cache, e.g. ~/.cache/claude-signals-cmux/$CMUX_WORKSPACE_ID
