#!/bin/bash
#
# break.sh — move the current window out into its own session.
# Usage: break.sh <new-session-name>

target_session="$1"
[[ -z "$target_session" ]] && exit 0

# The window we're moving out (fully qualified: "session:index").
current_window=$(tmux display-message -p '#{session_name}:#{window_index}')

# Create the new session detached. tmux auto-creates one placeholder
# window in it, which we capture so we can remove it afterwards.
tmux new-session -d -s "$target_session"
placeholder_window=$(tmux list-windows -t "$target_session" -F '#{window_id}' | head -1)

# Move our window in, drop the placeholder, then follow the move.
tmux move-window -s "$current_window" -t "$target_session"
tmux kill-window -t "$placeholder_window"
tmux switch-client -t "$target_session"
