---
name: session
description: Create a tmux session anchored to a given working directory and switch to it
allowed-tools: Bash(tmux *), Bash(basename *), Bash(printenv TMUX)
---

# Session Skill

Create a new tmux session rooted at a user-specified directory and switch to it. Accepts an optional session name — if omitted, derive one from the directory.

## Arguments

- **path** (required) — the working directory for the session
- **name** (optional) — the session name; defaults to the basename of the path

## Steps

1. Verify we are inside tmux:
   ```bash
   printenv TMUX
   ```
   If empty, tell the user this skill requires an active tmux session and stop.

2. Derive the session name:
   - If the user provided a name, use it
   - Otherwise: `basename <path>`
   - Sanitize: replace `.` and `:` with `-` (these characters are special in tmux targets)

3. Check if a session with that name already exists:
   ```bash
   tmux has-session -t "=<name>" 2>/dev/null
   ```
   - If it exists, skip creation and go to step 5

4. Create a detached session:
   ```bash
   tmux new-session -d -s "<name>" -c "<path>"
   ```

5. Optionally switch to the new session:
   - If the user asked to "switch", "open", or "launch" the session — switch to it:
     ```bash
     tmux switch-client -t "<name>"
     ```
   - If the user only asked to "create" the session, or intent is unclear — leave it detached and report that it's available

6. Report the session name and path to the user.

## Rules

- Always use exact-match (`=` prefix) with `has-session` to avoid prefix collisions
- Never attach (`attach-session`) from inside tmux — always use `switch-client`
- If the target path does not exist, tell the user and stop — do not create directories
- If a session already exists with that name, switch to it and inform the user it was already running
