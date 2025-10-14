#!/bin/bash

session=$(tmux list-sessions -F '#{session_name}' | fzf --layout=reverse --tmux center,40%,border-native --exit-0)

if [[ -n "$session" ]]; then
  tmux switch-client -t "$session"
fi
