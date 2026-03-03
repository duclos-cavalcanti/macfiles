#!/bin/bash

session=$(tmux list-sessions -F '#{session_name}|#{session_name}: #{session_path}' | \
  fzf --layout=reverse --tmux center,60%,border-native --exit-0 \
      --delimiter='|' --with-nth=2 | \
  cut -d'|' -f1)

if [[ -n "$session" ]]; then
  tmux switch-client -t "$session"
fi
