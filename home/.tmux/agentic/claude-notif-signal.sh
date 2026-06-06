#!/bin/bash
#
# Mark the current Claude Code session as needing the user's attention
# (Claude raised a Notification event). Called by
# ~/.claude/scripts/notif-signal.sh.
#
# Exits 1 if not inside a tmux session — caller decides how to react.

[[ -z "$TMUX" ]] && exit 1
