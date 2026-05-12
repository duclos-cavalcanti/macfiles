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

5. Launch `claude` in the session's single pane.

   **Important:** Issue two **separate** Bash calls (each starting with `tmux`) so the existing `Bash(tmux *)` permission rule covers them. Never chain these into one command with variable assignment.

   **Call 1** — discover the pane ID:
   ```bash
   tmux list-panes -t "<name>" -F "#{pane_id}" | head -1
   ```
   Save the output (e.g. `%42`) for Call 2.

   **Call 2** — launch claude in the pane, using the pane ID from Call 1:
   ```bash
   tmux send-keys -t "%42" "claude" C-m
   ```

6. **Do NOT switch to the session by default.** Only switch if the user explicitly asked to "switch", "open", or "launch":
   ```bash
   tmux switch-client -t "<name>"
   ```
   Otherwise, leave it detached and report that it's available.

7. Report the session name and path to the user.

## Sending a prompt to the launched Claude (context handoff)

If the user asks you to seed the newly-launched Claude with context from
the current session, be aware of a paste-detection gotcha in the Claude
TUI: when `send-keys` delivers a long burst (~180+ chars empirically),
the TUI treats the input as a pasted block and strips the trailing Enter
to protect against accidental submission. The text lands in the prompt
but the child Claude sits idle waiting for a real keystroke.

Short prompts (under ~20 chars) submit fine in a single call. For
anything longer, or when the length is uncertain, **always split the
text and Enter into separate `send-keys` calls** with a sleep between
them:

```bash
# Call 1 — type the text (no Enter)
tmux send-keys -t "%42" "Read CONTEXT-TICKET.md for the handoff."

# Call 2 — small sleep so the paste-detection window closes
sleep 1

# Call 3 — explicit Enter as a separate keystroke
tmux send-keys -t "%42" C-m
```

Prefer **sending a short pointer** ("read `CONTEXT-<ticket>.md`") rather
than pasting the full context inline — a persisted file survives
accidents (mistimed Enter, session restart, etc.) and keeps the actual
handoff decoupled from the send-keys mechanics. Write the full context
file first, then point at it.

Verify the prompt landed with `tmux capture-pane -t "%42" -p | tail`
after sending. The Claude TUI's rendered content IS captured by
`capture-pane` — if a capture comes back blank, retry after a brief
sleep (likely a mid-redraw timing artefact).

## Rules

- Always use exact-match (`=` prefix) with `has-session` to avoid prefix collisions
- Never attach (`attach-session`) from inside tmux — always use `switch-client`
- If the target path does not exist, tell the user and stop — do not create directories
- If a session already exists with that name, inform the user it's already running — only switch if explicitly asked
- When sending prompts into another Claude's pane, split text and Enter into separate `send-keys` calls with a sleep between them (see "Sending a prompt to the launched Claude" above)
