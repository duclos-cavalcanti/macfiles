# Config Updates

Workflow improvements for `cmux` + `ghostty` + the existing macfiles setup.
Use checkboxes to track what's been applied. Ideas at the bottom — add your own.

> **Stack assumption:** cmux embeds ghostty as the **cell renderer only**. cmux owns the GUI shell (windows, tabs, splits, menus, command palette, keybinds, notifications, surface lifecycle). Ghostty config is honored only for renderer-level concerns (theme, palette, font, cursor, padding, shell integration, link rendering, conditional blocks). Recs that would have lived at the ghostty GUI layer (split keybinds, quick-terminal, ghostty command palette, split-divider-color) have been removed.

**Reference docs**

- cmux: <https://cmux.com/docs> · repo: <https://github.com/manaflow-ai/cmux>
- ghostty: <https://ghostty.org/docs> · repo: <https://github.com/ghostty-org/ghostty>
- Local source-of-truth dumps: `cmux docs api`, `cmux capabilities`, `ghostty +show-config --default --docs`, `ghostty +list-keybinds --default`, `ghostty +list-actions`

---

## ⚠️ Fix first — silent parse error

- [x] **Ghostty config has `Adwaita Dark` on its own line, missing `theme = ` prefix.** Currently a silent parse error.

  Replace the bare line in `home/.config/ghostty/config` with either:

  ```
  theme = Adwaita Dark
  ```

  or a per-appearance split:

  ```
  theme = light:Adwaita,dark:Adwaita Dark
  ```

---

## Agentic / Claude Code

### 1. Use `workspace.prompt_submit` instead of `cmux send` in the agentic plugin · ★ high-ROI

cmux exposes a "submit text into the focused prompt box" RPC — the proper API to talk *into* an agent surface. Safer than `cmux send` for bracketed-paste edge cases.

- [ ] Replace `cmux send --surface <ref> -- <text>` in `agentic/cmux.lua` with:
  ```
  cmux rpc workspace.prompt_submit '{"workspace_id":"<uuid>","text":"<text>","submit":false}'
  ```
  (Confirm exact param shape via `cmux capabilities` → schema for `workspace.prompt_submit`.)

### 2. Native macOS notifications via OSC sequences from claude signal scripts · ★ high-ROI

Your `home/.claude/scripts/{start,prompt,notif,stop}-signal.sh` already fire on lifecycle events. Make them emit OSC 9 / OSC 777 so ghostty surfaces native notifications (no extra daemon).

- [ ] Set `desktop-notifications = true` in ghostty config (likely already on by default).
- [ ] In each signal script, append:
  ```sh
  printf '\033]777;notify;Claude;%s\a' "$EVENT_MESSAGE"
  # or simpler OSC 9 toast:
  printf '\033]9;%s\a' "$EVENT_MESSAGE"
  ```
- [ ] Decide split: cmux's own `cmux notify` (sidebar + banner) for in-cmux events vs. ghostty OSC for terminal-anchored events.

### 3. Live-preview plan files via `cmux markdown open` from agentic

```
cmux markdown open ~/scratch/plan.md --focus false
```

Auto-reloads on file change. Could be a `:AgenticPreview <file>` command in the plugin.

- [ ] Add command to `home/.config/nvim/pack/plugins/start/agentic/lua/agentic/init.lua`.

### 4. Pin your primary claude surface

```
cmux tab-action --action pin --tab <surface_ref>
```

Skipped by `close-others` and accidental `cmd+w`. Combine with a sidebar color for instant visual recognition:

```
cmux workspace-action --action set-color --color "#fabd2f"
```

- [ ] Pin + color the daily-driver claude surface.

### 5. `cmux feed` — permission arbitration UI

Right sidebar panel (`ctrl+4`). Intercepts claude's "may I run this?" prompts as a hotkey-able UI list. Worth a try if you're tired of the in-pane TUI.

- [ ] Open `cmux feed tui` once, see if it fits your workflow.

### 6. `cmux omc` — multi-agent orchestrator

For big refactors: `cmux omc team 3:claude "implement X"` spawns 3 parallel claudes as native cmux splits. `claude-teams` is single-agent; `omc` is the multi-agent variant.

- [ ] Try it on a parallelizable task.

---

## Navigation / search

### 7. Content search across all cmux surfaces

```
cmux find-window --content --select "TODO(critical)"
```

Walks every surface's buffer. Way faster than `cmd+f` × N workspaces.

- [ ] Bind to a shell alias / keybind if useful.

---

## Appearance / themes

### 8. Conditional ghostty config blocks

Per-appearance/per-OS overrides in one file:

- [ ] Add to `home/.config/ghostty/config`:
  ```
  [appearance=dark]
  window-padding-color = extend
  minimum-contrast      = 1.05

  [appearance=light]
  minimum-contrast      = 1.1
  ```

### 9. `font-codepoint-map` for icon fonts

Routes Powerline / Nerd-Font glyph ranges to a dedicated icon font without changing your primary font:

- [ ] Add to ghostty config:
  ```
  font-codepoint-map = U+E000-U+F8FF=Symbols Nerd Font Mono
  ```

### 10. Theme: light/dark auto-switch

If you don't already split, follow macOS appearance:

- [ ] Replace the current `theme = Adwaita Dark` with:
  ```
  theme = light:Adwaita,dark:Adwaita Dark
  ```
  (or any pair from `ghostty +list-themes`).

---

## Shell integration & performance

### 11. Tighten `shell-integration-features`

- [ ] Add to ghostty config:
  ```
  shell-integration          = detect
  shell-integration-features = cursor,sudo,title,ssh-env,ssh-terminfo
  ```
  `sudo` re-injects terminfo so remote `xterm-ghostty` survives. `ssh-env`/`ssh-terminfo` does the same for SSH to non-ghostty-aware hosts. `title` puts the current command in the window title.

### 12. Optional include for host-specific config

Keep the stowed file public/portable; load host-specific bits via optional include:

- [ ] Append to ghostty config:
  ```
  config-file = ?work.conf
  ```
  Then put per-machine secrets/keybinds in `~/.config/ghostty/work.conf` (not stowed).

### 13. Validate `cmux.json`

```
cmux config doctor
```

Flags unknown / experimental keys.

- [ ] Run once, fix anything it complains about.

---

## Workflow / dotfiles polish

### 14. cmux Dock — pin TUIs to the sidebar

Pin lazygit, a test watcher, log tail, etc. as always-on surfaces in the right sidebar. Spec at `~/.config/cmux/dock.json` (or `.cmux/dock.json` per-project, which can be committed for the team).

- [ ] Example `~/.config/cmux/dock.json`:
  ```json
  {
    "items": [
      { "id": "lazygit", "title": "git",  "command": "lazygit",          "cwd": "$PROJECT_ROOT" },
      { "id": "logs",    "title": "logs", "command": "tail -F /tmp/dev.log" }
    ]
  }
  ```
  Refine ids/commands to match your daily set.

---

## Ideas / TBD (your turn)

- [ ] _add your own here_

---

## Removed (cmux-owned — no-op in this stack)

Documented for the record; would only fire if you launched `ghostty.app` standalone instead of cmux:

- ghostty leader-key sequences (`ctrl+a>c=new_tab` etc.) — cmux owns input routing
- ghostty `quick-terminal` slide-in HUD — cmux doesn't expose this surface
- ghostty `command-palette-entries` — cmux has its own command palette (`cmd+shift+p`)
- ghostty `split-divider-color` / `unfocused-split-opacity` — cmux owns splits and their chrome
- ghostty `link` regex for clickable Jira/MR IDs — unclear whether cmux delegates click hit-testing to ghostty's renderer; not safe to assume it works

Equivalents in cmux:
- For shortcuts: `cmux.json` → `shortcuts.bindings` (supports two-step chords as `["prefix_stroke", "following_key"]` arrays).
- For sidebar/window appearance: `cmux.json` → `sidebar`, `sidebarAppearance`, `workspaceColors`, `browser.theme`.
- For surface close-confirmation: cmux-side setting (not `confirm-close-surface` in ghostty config — which is also a no-op inside cmux).
