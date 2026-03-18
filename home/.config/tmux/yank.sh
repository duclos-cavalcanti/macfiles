#!/bin/bash

file=$(fd --follow --hidden --type f \
    --exclude .git \
    --exclude .cache \
    --exclude .local \
    --exclude node_modules \
    --exclude target \
    --exclude dist \
    . "$HOME" \
    | fzf --layout=reverse --tmux center,80%,border-native --exit-0 --prompt="yank > ")

[[ -z "$file" ]] && exit 0

echo "$file" | pbcopy
