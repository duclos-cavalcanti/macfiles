#!/bin/bash

current=$(tmux display-message -p '#{session_name}')
sessions=""

while read -r name; do
    color="#[fg=brightblack]"
    sessions="${sessions}${color} $name #[default]"
done < <(tmux list-sessions -F '#{session_name}')

echo "#[align=left]$sessions"
