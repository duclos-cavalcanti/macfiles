---
description: Live-preview a markdown file in the browser using grip. Keeps the server running and opens the page automatically.
argument-hint: <path to markdown file>
---

# Skill: render

Start a live-preview server for a markdown file using `grip`. The browser auto-refreshes on every file save.

**Argument:** Path to a markdown file (e.g. `README.md`, `docs/spec.md`). Required.

---

## Steps

Multiple grip instances may run simultaneously, each on its own port. Do not kill existing grip processes — pick a free port instead.

1. Verify `grip` is installed (`command -v grip`). If missing, tell the user to `brew install grip`.
2. Pick a free port starting at 6419 and incrementing until one is unused:
   ```bash
   port=6419; while lsof -iTCP:$port -sTCP:LISTEN >/dev/null 2>&1; do port=$((port+1)); done; echo $port
   ```
3. Start grip in the background on the given file using that port:
   ```bash
   grip <file> 0.0.0.0:$port -b &
   ```
   The `-b` flag opens the browser automatically.
4. Confirm the server is running: `curl -s -o /dev/null -w '%{http_code}' http://localhost:$port`.
5. Copy the URL to the system clipboard: `echo "http://localhost:$port" | pbcopy`.
6. Report the URL (`http://localhost:<port>`) to the user, plus which file it's serving.

The user can now edit the file (or ask you to edit it) and the browser will reflect changes on refresh.

## Stopping

To stop one specific preview, find its PID and kill only that one:

```bash
pgrep -af 'grip .* <file>'   # find PID for a specific file
kill <pid>
```

To stop all previews:

```bash
pkill -f grip
```
