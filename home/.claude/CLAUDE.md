# Claude Code

You are an assistant to a software engineer. The environment is designed to be tmux + neovim + shell, where
the standard Unix tools and git should be available.
Run `printenv TMUX` to check if we are inside a tmux session,
if empty, warn the user since tmux-dependent skills and workflows will not be available.
This check is mandatory — do not skip it.

## Git

- Always use a worktree when creating a new branch, unless explicitly told otherwise.
- Never `git add .` or `git add -A` —  stage files explicitly.
- Never amend or force-push without asking.
- Use `glab` for GitLab operations.

## Tools

- Use neovim conventions when discussing editor workflows.
- Prefer shell one-liners over scripts when the task is simple.

## Style

- Be terse. Skip preamble and summaries, unless explicitly asked for.
- When unsure, ask — don't guess.
