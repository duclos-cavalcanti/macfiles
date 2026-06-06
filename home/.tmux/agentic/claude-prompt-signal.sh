#!/bin/bash
#
# Mark the current Claude Code session as "active" (user just submitted
# a prompt). Called by ~/.claude/scripts/prompt-signal.sh.
#
# Exits 1 if not inside a tmux session — caller decides how to react.

[[ -z "$TMUX" ]] && exit 1
