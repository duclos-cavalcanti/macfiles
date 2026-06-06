#!/bin/bash
#
# Mark the current Claude Code session as "started" in the tmux
# statusline signal cache. Called by ~/.claude/scripts/start-signal.sh.
#
# Exits 1 if not inside a tmux session — caller decides how to react.

[[ -z "$TMUX" ]] && exit 1
