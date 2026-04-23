#!/bin/bash

layout=$(tmux show -wqv @layout_name)
[ -n "$layout" ] && echo "$layout"
