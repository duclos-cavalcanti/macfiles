#!/bin/bash

session="$1"

[[ -z "$session" ]] && exit 0

window=$(tmux display-message -p '#{session_name}:#{window_index}')
tmux new-session -d -s "$session"
initial=$(tmux list-windows -t "$session" -F '#{window_id}' | head -1)
tmux move-window -s "$window" -t "$session"
tmux kill-window -t "$initial"
tmux switch-client -t "$session"
