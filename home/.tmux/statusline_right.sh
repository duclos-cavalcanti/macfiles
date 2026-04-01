#!/bin/bash

sessions=$(tmux list-sessions -F '#{session_name}' | paste -sd ' ' -)
host=$(hostname -s)
echo "$sessions"
