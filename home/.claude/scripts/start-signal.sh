#!/bin/bash
#
# Claude Code SessionStart hook orchestrator.
# Dispatches to whichever agentic backend matches the current environment.
# Backends exit 1 when not applicable (e.g. the tmux helper when not in
# a tmux session). The hook itself always exits 0 — Claude Code doesn't
# care about backend outcome.

# "$HOME/.tmux/agentic/claude-start-signal.sh"

# Future: peer cmux backend can hook in here.
# "$HOME/.cmux/agentic/claude-start-signal.sh"

exit 0
