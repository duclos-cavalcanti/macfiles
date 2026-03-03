#!/bin/bash

current_path=$(tmux display-message -p '#{session_path}')

session=$(tmux list-sessions -F '#{session_name}|#{session_path}' | \
  awk -F'|' -v path="$current_path" '$1 ~ /^claude / && $2 == path {print $1}')

if [[ -n "$session" ]]; then
  tmux switch-client -t "$session"
fi
