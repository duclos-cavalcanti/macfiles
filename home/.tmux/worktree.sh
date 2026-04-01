#!/bin/bash

print_and_exit() {
    local text="$1"
    local ret="$2"
    tmux display-message "${text}"
    exit $ret
}

get_git_root() {
    local path=$(tmux display-message -p '#{session_path}')
    local git_root=$(git -C "$path" rev-parse --show-toplevel 2>/dev/null)
    [[ -z "$git_root" ]] && print_and_exit "Not a git repository" 1
    echo "$git_root"
}

list_worktrees() {
    local git_root="$1"
    local output=$(git -C "$git_root" worktree list --porcelain \
        | awk '/^worktree /{wt=substr($0,10)} /^branch /{print wt}' \
        | grep -v "^$git_root$")
    echo "$output"
}

find_session_by_path() {
    local path="$1"
    tmux list-sessions -F '#{session_name}|#{session_path}' 2>/dev/null \
        | awk -F'|' -v p="$path" '$2 == p {print $1}'
}

create_worktree() {
    local git_root=$(get_git_root)

    local worktree
    worktree=$(list_worktrees "$git_root" \
        | fzf --layout=reverse --tmux center,60%,border-native --exit-0 --prompt="worktree > ")

    [[ -z "$worktree" ]] && print_and_exit "No worktree selected" 0

    local session
    session=$(find_session_by_path "$worktree")

    if [[ -n "$session" ]]; then
        tmux switch-client -t "$session"
    else
        session=$(basename "$worktree")
        tmux new-session -d -s "$session" -c "$worktree"
        tmux switch-client -t "$session"
    fi
}

delete_worktree() {
    local git_root=$(get_git_root)

    local worktree
    worktree=$(list_worktrees "$git_root" | fzf --layout=reverse --tmux center,60%,border-native --exit-0 --prompt="delete worktree > ")

    [[ -z "$worktree" ]] && print_and_exit "No worktree selected" 0

    local err
    err=$(git -C "$git_root" worktree remove "$worktree" 2>&1)
    [[ $? -ne 0 ]] && print_and_exit "Failed: $err" 1

    local session
    session=$(find_session_by_path "$worktree")
    [[ -n "$session" ]] && tmux kill-session -t "$session"

    print_and_exit "Deleted: $(basename "$worktree")" 0
}

case "$1" in
    delete) delete_worktree ;;
    *)      create_worktree ;;
esac
