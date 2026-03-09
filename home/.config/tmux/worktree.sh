#!/bin/bash

print() {
    local text="$1"
    tmux display-message "${text}"
    echo "${text}" >> /tmp/worktree.log
}

print_and_exit() {
    local text="$1"
    local ret="${2}"
    print "${text}"
    exit $ret
}

main() {
    local path=$(tmux display-message -p '#{session_path}')
    local git_folder_path=$(git -C "$path" rev-parse --show-toplevel 2>/dev/null)

    [[ -z "$git_folder_path" ]] && print_and_exit "Not a git repository" 1

    local project=$(basename "$git_folder_path")
    local parent_path=$(dirname "$git_folder_path")
    local branch=$(git -C "$git_folder_path" branch -a --format='%(refname:short)' \
        | sed 's|^origin/||' \
        | grep -v '^HEAD$' \
        | sort -u \
        | grep -vxFf <(git -C "$git_folder_path" worktree list --porcelain \
            | grep '^branch' \
            | sed 's|branch refs/heads/||') \
        | fzf --layout=reverse --tmux center,60%,border-native --exit-0 --prompt="worktree > ")

    [[ -z "$branch" ]] && print_and_exit "No branch selected" 0
    local branch_sanitized="${branch//\//-}"

    local worktree="${parent_path}/${project}-${branch_sanitized}"
    local session="${project}-${branch_sanitized}"

    print "worktree: $worktree | session: $session"
    sleep 2

    if [[ ! -d "$worktree" ]]; then
        print "creating worktree at: $worktree"
        sleep 2
        if ! git -C "$git_folder_path" worktree add "$worktree" "$branch" 2>/dev/null; then
            print_and_exit "Failed to create worktree for '$branch'" 1
        fi
    else
        print "worktree already exists, skipping creation"
        sleep 2
    fi

    if ! tmux has-session -t "$session" 2>/dev/null; then
        print "creating session: $session"
        sleep 2
        tmux new-session -d -s "$session" -c "$worktree"
    else
        print "session already exists, attaching"
        sleep 2
    fi

    tmux switch-client -t "$session"
}

main $@
