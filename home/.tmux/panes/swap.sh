#!/bin/bash

current=$(tmux display-message -p '#{pane_id}')

pane=$(tmux list-panes -s \
    -F '#{pane_id}|#{window_name}:#{pane_index}  #{pane_current_command}' | \
    grep -v "^${current}|" | \
    fzf --layout=reverse --tmux center,60%,border-native --exit-0 --delimiter='|' --with-nth=2 | \
    cut -d'|' -f1)

if [[ -n "$pane" ]]; then
    tmux swap-pane -t "$pane"
fi
