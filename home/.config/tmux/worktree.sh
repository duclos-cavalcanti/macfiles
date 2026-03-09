#!/bin/bash

print_and_exit() {
    local text="$1"
    local ret="${2}"
    tmux display-message "${text}"
    exit $ret
}

main() {
    local path=$(tmux display-message -p '#{session_path}')
    local git_folder_path=$(git -C "$path" rev-parse --show-toplevel 2>/dev/null)

    [[ -z "$git_folder_path" ]] && print_and_exit "Not a git repository" 1

    local project=$(basename "$git_folder_path")
    local parent_path=$(dirname "$git_folder_path")
    local new_branch_label="[+ new branch]"
    local selection=$( { echo "$new_branch_label"; git -C "$git_folder_path" branch -a --format='%(refname:short)' \
        | sed 's|^origin/||' \
        | grep -v '^HEAD$' \
        | sort -u \
        | grep -vxFf <(git -C "$git_folder_path" worktree list --porcelain \
            | grep '^branch' \
            | sed 's|branch refs/heads/||'); } \
        | fzf --layout=reverse --tmux center,60%,border-native --exit-0 --prompt="worktree > ")

    [[ -z "$selection" ]] && print_and_exit "No branch selected" 0

    local branch
    if [[ "$selection" == "$new_branch_label" ]]; then
        branch=$(echo "" | fzf --layout=reverse --tmux center,60%,border-native \
            --print-query --prompt="new branch name > " 2>/dev/null | head -1)
        [[ -z "$branch" ]] && print_and_exit "No branch name entered" 0

        local default_branch=$(git -C "$git_folder_path" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null \
            | sed 's|refs/remotes/origin/||')
        [[ -z "$default_branch" ]] && default_branch="main"

        local branch_sanitized="${branch//\//-}"
        local worktree="${parent_path}/${project}-${branch_sanitized}"
        local session="${project}-${branch_sanitized}"

        if ! git -C "$git_folder_path" worktree add -b "$branch" "$worktree" "$default_branch" 2>/dev/null; then
            print_and_exit "Failed to create branch '$branch'" 1
        fi
    else
        branch="$selection"
        local branch_sanitized="${branch//\//-}"
        local worktree="${parent_path}/${project}-${branch_sanitized}"
        local session="${project}-${branch_sanitized}"

        if [[ ! -d "$worktree" ]]; then
            if ! git -C "$git_folder_path" worktree add "$worktree" "$branch" 2>/dev/null; then
                print_and_exit "Failed to create worktree for '$branch'" 1
            fi
        fi
    fi

    if ! tmux has-session -t "$session" 2>/dev/null; then
        tmux new-session -d -s "$session" -c "$worktree"
    fi

    tmux switch-client -t "$session"
}

main $@
