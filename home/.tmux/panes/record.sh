#!/bin/bash
RECORD_FILE="/tmp/tmux-record-$(tmux display-message -p '#{pane_id}' | tr -d '%')"

if [ -f "$RECORD_FILE" ]; then
    tmux pipe-pane
    tmux load-buffer "$RECORD_FILE"
    rm "$RECORD_FILE"
    tmux display-message "Recording saved to paste buffer"
else
    tmux pipe-pane -o "cat >> $RECORD_FILE"
    tmux display-message "Recording started..."
fi
