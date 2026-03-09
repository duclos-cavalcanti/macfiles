---
name: worktree
description: Create a git worktree as a sibling folder for an existing or new branch
allowed-tools: Bash(git *), Bash(ls *), Bash(mkdir *)
---

# Create Git Worktree

Create a worktree as a sibling directory to the current project, optionally on a new branch forked from the default branch.

## Steps

1. Run `git rev-parse --show-toplevel` to get the git root and `git rev-parse --abbrev-ref HEAD` to get the current branch.
2. Ask the user: do they want to use an **existing branch** or create a **new branch**?
3. **If existing branch:**
   - Run `git branch -a --format='%(refname:short)' | sed 's|^origin/||' | grep -v '^HEAD$' | sort -u` to list available branches
   - Ask the user to pick one (exclude any already checked out via `git worktree list --porcelain`)
4. **If new branch:**
   - Ask the user for the new branch name
   - Detect the default branch via `git symbolic-ref refs/remotes/origin/HEAD` (fall back to `main`)
5. Derive the worktree path:
   - Parent directory: `dirname <git-root>` (e.g. git root `/home/user/work/myapp` → parent `/home/user/work`)
   - Project name: `basename <git-root>` (e.g. `myapp`)
   - Branch sanitized: replace every `/` in the branch name with `-` (e.g. `feature/auth` → `feature-auth`)
   - Final path: `<parent>/<project>-<branch-sanitized>` (e.g. `/home/user/work/myapp-feature-auth`)
6. Confirm the worktree path and branch with the user before proceeding
7. Create the worktree:
   - Existing branch: `git worktree add <path> <branch>`
   - New branch: `git worktree add -b <branch> <path> <default-branch>`
8. Report the full path of the created worktree to the user
