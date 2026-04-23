#!/bin/bash
layouts=("even-horizontal" "even-vertical" "main-horizontal" "main-vertical" "tiled")
current=$(tmux show -wqv @layout_index)
current=${current:-"-1"}
next=$(( (current + 1) % 5 ))
tmux select-layout "${layouts[$next]}"
tmux set -w @layout_index "$next"
tmux set -w @layout_name "${layouts[$next]}"
