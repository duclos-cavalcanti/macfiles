---
name: preview
description: Preview any content in a floating tmux/nvim popup. User approves with :wq or signals feedback with :q.
allowed-tools: Bash(mktemp *), Bash(tmux *), Bash(stat *), Bash(rm *)
---

# Preview Skill

When the user asks to preview something — a file, a response, a code block, a plan — write it to a temp file and open it in a floating nvim popup via tmux.

## Steps

1. Write the content to a temp markdown file:
   ```bash
   tmpfile=$(mktemp /tmp/preview-XXXXXX.md)
   cat > "$tmpfile" << 'EOF'
   [content here]
   EOF
   ```

2. Record the file's modification time before opening:
   ```bash
   before=$(stat -f %m "$tmpfile")
   ```

3. Open the floating popup with nvim:
   ```bash
   tmux display-popup -E -w 80% -h 80% "nvim '$tmpfile'"
   ```

4. After the popup closes, check if the file was modified:
   ```bash
   after=$(stat -f %m "$tmpfile")
   ```

5. Interpret the result:
   - **`before != after`** (file was written — user did `:wq`) → user approved, continue
   - **`before == after`** (file untouched — user did `:q`) → user has feedback, ask: *"What would you like to change?"*

6. Clean up:
   ```bash
   rm -f "$tmpfile"
   ```

## Rules

- Always use `.md` extension on the temp file so nvim picks up markdown filetype automatically
- The content written to the file should be clean and readable — no raw tool output, no metadata
- If the user did `:q`, do NOT proceed with whatever the preview was for — wait for their feedback before continuing
- If the user did `:wq` and edited the content, read the saved file before cleaning up — their edits are the new source of truth
