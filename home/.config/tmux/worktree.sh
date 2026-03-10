#!/bin/bash

print_and_exit() {
    local text="$1"
    local ret="${2}"
    tmux display-message "${text}"
    exit $ret
}

get_git_root() {
    local path=$(tmux display-message -p '#{session_path}')
    local git_folder_path=$(git -C "$path" rev-parse --show-toplevel 2>/dev/null)
    [[ -z "$git_folder_path" ]] && print_and_exit "Not a git repository" 1
    echo "$git_folder_path"
}

create_worktree() {
    local git_folder_path=$(get_git_root)
    local project=$(basename "$git_folder_path")
    local parent_path=$(dirname "$git_folder_path")
    local new_branch_label="[+ new branch]"
    local selection=$( { echo "$new_branch_label"; git -C "$git_folder_path" branch -a --format='%(refname:short)' \
        | sed 's|^origin/||' \
        | grep -v '^HEAD$' \
        | sort -u; } \
        | fzf --layout=reverse --tmux center,60%,border-native --exit-0 --prompt="worktree > ")

    [[ -z "$selection" ]] && print_and_exit "No branch selected" 0

    local branch
    local session

    if [[ "$selection" == "$new_branch_label" ]]; then
        branch=$(echo "" | fzf --layout=reverse --tmux center,60%,border-native \
            --print-query --prompt="new branch name > " 2>/dev/null | head -1)
        [[ -z "$branch" ]] && print_and_exit "No branch name entered" 0

        local default_branch="master"
        local branch_sanitized="${branch//\//-}"
        local worktree="${parent_path}/${project}-${branch_sanitized}"
        session="${project}-${branch_sanitized}"

        local err
        err=$(git -C "$git_folder_path" worktree add -b "$branch" "$worktree" "$default_branch" 2>&1)
        [[ $? -ne 0 ]] && print_and_exit "Failed: $err" 1
    else
        branch="$selection"
        local branch_sanitized="${branch//\//-}"
        local worktree="${parent_path}/${project}-${branch_sanitized}"
        session="${project}-${branch_sanitized}"

        local already_checked_out
        already_checked_out=$(git -C "$git_folder_path" worktree list --porcelain \
            | awk -v b="refs/heads/$branch" '/^worktree /{wt=substr($0,10)} $0=="branch " b {print wt}')

        if [[ -z "$already_checked_out" ]]; then
            local err
            err=$(git -C "$git_folder_path" worktree add "$worktree" "$branch" 2>&1)
            [[ $? -ne 0 ]] && print_and_exit "Failed: $err" 1
        fi
    fi

    if ! tmux has-session -t "$session" 2>/dev/null; then
        tmux new-session -d -s "$session" -c "$worktree"
    fi

    tmux switch-client -t "$session"
}

delete_worktree() {
    local git_folder_path=$(get_git_root)

    local worktree
    worktree=$(git -C "$git_folder_path" worktree list --porcelain \
        | awk '/^worktree /{wt=substr($0,10)} /^branch /{print wt}' \
        | grep -v "^$git_folder_path$" \
        | fzf --layout=reverse --tmux center,60%,border-native --exit-0 --prompt="delete worktree > ")

    [[ -z "$worktree" ]] && print_and_exit "No worktree selected" 0

    local session=$(basename "$worktree")

    local err
    err=$(git -C "$git_folder_path" worktree remove "$worktree" 2>&1)
    [[ $? -ne 0 ]] && print_and_exit "Failed: $err" 1

    if tmux has-session -t "$session" 2>/dev/null; then
        tmux kill-session -t "$session"
    fi

    print_and_exit "Deleted worktree: $session" 0
}

case "$1" in
    delete) delete_worktree ;;
    *)      create_worktree ;;
esac
