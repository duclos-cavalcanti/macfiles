#!/bin/bash

session=$(tmux display-message -p '#{session_name}')
host=$(hostname -s)

# Build window list
windows=""
current_idx=$(tmux display-message -p '#{window_index}')
while IFS=$'\t' read -r idx name marked zoomed; do
    if [[ "$idx" == "$current_idx" ]]; then
        flags=""
        [[ "$marked" == "1" ]] && flags="+"  || flags="*"
        [[ "$zoomed" == "1" ]] && flags="$flags Z"
        windows="$windows#[fg=white,bold] $idx:$name$flags "
    else
        windows="$windows#[fg=brightblack,nobold] $idx:$name  "
    fi
done < <(tmux list-windows -F "#{window_index}	#{window_name}	#{pane_marked}	#{window_zoomed_flag}")

echo "#[default]$windows#[align=right]#[fg=green]$host "
