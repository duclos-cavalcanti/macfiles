#!/bin/bash
#
# Claude Code Stop hook orchestrator.
# Forwards optional STATE arg (default "DONE") to the backend helper so
# the tmux statusline can differentiate completion reasons.
# Backends exit 1 when not applicable. The hook always exits 0.

# "$HOME/.tmux/agentic/claude-stop-signal.sh" "$@"

# Future: peer cmux backend can hook in here.
# "$HOME/.cmux/agentic/claude-stop-signal.sh" "$@"

exit 0
