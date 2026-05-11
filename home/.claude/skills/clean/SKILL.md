---
name: clean
description: Generic cleanup of stale local artifacts. Each cleanup type is a sub-mode invoked by name. Currently supports `worktrees` (remove worktrees whose ticket is Done or MR is merged).
argument-hint: <type>
allowed-tools: Bash(git *), Bash(glab *), mcp__claude_ai_Atlassian__getJiraIssue
---

# Clean

Generic cleanup of stale local artifacts in the current repo. Each cleanup type is a separate sub-mode below; new types can be added as their own `## <type>` section without changing the skill's invocation pattern.

## Invocation

- `/clean <type>` — run the named cleanup type.
- `/clean` (no argument) — list the available types and ask which to run.

## Available types

| Type | What it cleans |
|---|---|
| `worktrees` | Worktrees of the current repo whose branch's Jira ticket is Done or whose MR is merged. Forces removal regardless of dirty state. |

When adding a new type, register it in this table and add a matching `## <type>` section below.

---

## worktrees

Inspect every worktree of the current repo, decide which are "retired" (Jira ticket Done OR MR merged), and force-remove them — even if the working tree is dirty.

A worktree retires if **either** condition is met:
- Its branch name contains a Jira ticket ID whose status is in the done set: `Done, Closed, Resolved, Won't Do, Released, Cancelled` (case-insensitive).
- It has at least one merged MR with the worktree's branch as source.

A worktree with no Jira match and no merged MR is preserved.

### Steps

1. Confirm we're inside a git repo: `git rev-parse --show-toplevel`. Abort if not.
2. List worktrees: `git worktree list --porcelain`. Identify the main worktree (matches `git rev-parse --show-toplevel` from inside it, or is the first entry without a `detached` flag whose path equals the repo's primary). **Never act on the main worktree.**
3. For each non-main worktree, capture: `path`, `branch` (strip `refs/heads/` prefix). Skip detached worktrees (no branch to check).
4. Extract Jira ticket ID from each branch name with regex `[A-Z]+-[0-9]+` (first match).
5. For each candidate, in parallel where possible:
   - **Jira:** if ticket ID found, call `mcp__claude_ai_Atlassian__getJiraIssue` and read `fields.status.name`. Mark `jira_done = true` if the status is in the done set.
   - **MR:** `glab mr list --source-branch <branch> --state merged --output json`. Mark `mr_merged = true` if the array is non-empty. (Fall back to `gh pr list --head <branch> --state merged --json url` if the remote is GitHub.)
6. Build a plan table — one row per non-main worktree:
   ```
   path | branch | ticket | jira status | mr merged? | action
   ```
   `action` = `purge` if `jira_done || mr_merged`, else `keep`. If both checks failed (network error, missing creds), mark `unknown` and treat as `keep`.
7. Show the plan to the user and require explicit confirmation before any deletion. Even in auto mode, force-removing worktrees with potentially dirty state warrants a confirm.
8. For each row marked `purge`:
   ```bash
   git worktree remove --force <path>
   ```
   `--force` handles dirty trees and locked worktrees. If the directory is already gone, `git worktree prune` after the loop cleans stale metadata.
9. Optionally offer to delete the local branch too (`git branch -D <branch>`) for any purged worktree — ask once, batch the deletions.
10. Report: counts of purged, kept, unknown — with one-line reason per kept/unknown row.

### Notes

- `--force` is intentional. The user has already accepted that uncommitted work in retired worktrees is forfeit.
- Branch-name → ticket extraction is best-effort. Branches without a `<PROJECT>-<NUM>` shape only retire via the MR check.
- The skill is read-only on Jira/GitLab — it never transitions tickets or closes MRs.
- If `glab` is unauthenticated, prompt the user to run `glab auth login` rather than guessing MR state from `git log`.
