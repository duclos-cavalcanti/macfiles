#!/bin/bash
#
# Claude Code Notification hook orchestrator.
# Dispatches to whichever agentic backend matches the current environment.
# Backends exit 1 when not applicable. The hook always exits 0.

"$HOME/.tmux/agentic/claude-notif-signal.sh"

# Future: peer cmux backend can hook in here.
# "$HOME/.cmux/agentic/claude-notif-signal.sh"

exit 0
