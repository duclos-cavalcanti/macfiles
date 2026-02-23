---
name: commit
description: Stage and commit changes with a well-formatted message
disable-model-invocation: true
allowed-tools: Bash(git *)
---

# Commit Changes

Stage all modified files and create a commit.

## Steps

1. Run `git status` to see what has changed
2. Run `git diff` to understand the nature of the changes
3. Stage the relevant files with `git add`
4. Write a concise, imperative commit message summarizing *why* the change was made
5. Commit with that message
