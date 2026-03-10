#!/bin/bash

pane=$(tmux display-message -p '#{pane_id}')
tmpfile=$(mktemp /tmp/scratch-XXXXXX.md)

tmux display-popup -E -w 80% -h 80% "nvim '$tmpfile'"

if [[ -s "$tmpfile" ]]; then
    tmux load-buffer "$tmpfile"
    tmux paste-buffer -t "$pane" -p
fi

rm -f "$tmpfile"
