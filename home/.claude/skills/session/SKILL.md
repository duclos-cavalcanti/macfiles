---
name: session
description: Create a tmux session anchored to a given working directory
allowed-tools: Bash(tmux *), Bash(basename *), Bash(printenv TMUX), Bash(git *), Bash(ls *)
---

# Session Skill

Create a new tmux session rooted at a user-specified directory. Accepts an optional session name — if omitted, derive one from the directory. **Never switch to the session unless the user explicitly asks to switch, open, or launch it.**

## Arguments

- **path** (required) — the working directory for the session
- **name** (optional) — the session name; read the basename of the path, if a ticket-id cannot be inferred by it, use the basename as a default name.

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

5. Split the initial window and launch `claude` in the original (left) pane.

   **Important:** Issue three **separate** Bash calls (each starting with `tmux`) so the existing `Bash(tmux *)` permission rule covers them. Never chain these into one command with variable assignment.

   **Call 1** — discover the original pane ID:
   ```bash
   tmux list-panes -t "<name>" -F "#{pane_id}" | head -1
   ```
   Save the output (e.g. `%42`) for Call 3.

   **Call 2** — split horizontally (new pane appears on the right):
   ```bash
   tmux split-window -h -t "<name>" -c "<path>"
   ```

   **Call 3** — launch claude in the original (left) pane, using the pane ID from Call 1:
   ```bash
   tmux send-keys -t "%42" "claude" C-m
   ```

   This creates pane A (left, original) and pane B (right, new shell).

6. **Do NOT switch to the session by default.** Only switch if the user explicitly asked to "switch", "open", or "launch":
   ```bash
   tmux switch-client -t "<name>"
   ```
   Otherwise, leave it detached and report that it's available.

7. Report the session name and path to the user.

## Rules

- Always use exact-match (`=` prefix) with `has-session` to avoid prefix collisions
- Never attach (`attach-session`) from inside tmux — always use `switch-client`
- If the target path does not exist, tell the user and stop — do not create directories
- If a session already exists with that name, inform the user it's already running — only switch if explicitly asked
