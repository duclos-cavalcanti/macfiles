#!/usr/bin/env bash
input=$(cat)

folder=$(echo "$input" | jq -r '.workspace.current_dir // .cwd' | xargs basename)
model=$(echo "$input" | jq -r '.model.display_name')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

if [ -n "$used" ]; then
  printf "%s | %s | ctx: %s%%" "$folder" "$model" "$used"
else
  printf "%s | %s" "$folder" "$model"
fi
