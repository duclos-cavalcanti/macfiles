# TODO — macfiles workflow improvements

Workflow improvements for `cmux` + `ghostty` + macfiles. cmux owns the GUI shell (windows, tabs, splits, menus, palette, keybinds, notifications); ghostty is the cell renderer only (theme, font, cursor, padding, shell integration, conditional blocks).

Refs: [cmux docs](https://cmux.com/docs) · [ghostty docs](https://ghostty.org/docs) · local dumps: `cmux capabilities`, `ghostty +show-config --default --docs`, `ghostty +list-keybinds --default`.

## Fix first

- [x] Ghostty config: fix bare `Adwaita Dark` line missing `theme = ` prefix (silent parse error).

## Agentic / Claude Code

- [ ] Replace `cmux send` in `agentic/cmux.lua` with `cmux rpc workspace.prompt_submit` (safer bracketed-paste; confirm schema via `cmux capabilities`).
- [ ] Emit OSC 9 / OSC 777 from `home/.claude/scripts/{start,prompt,notif,stop}-signal.sh` for native ghostty notifications; set `desktop-notifications = true`.
- [x] Add `:AgenticPreview [path]` live markdown preview via `cmux markdown open` to `agentic/init.lua`.
- [ ] Pin + color the daily-driver claude surface (`cmux tab-action --action pin` + `cmux workspace-action --action set-color`).
- [ ] Try `cmux feed tui` — permission-arbitration sidebar panel (`ctrl+4`).
- [ ] Try `cmux omc team 3:claude "implement X"` multi-agent orchestrator on a parallelizable task.

## Navigation / search

- [ ] Bind `cmux find-window --content --select "<query>"` (content search across all surfaces) to an alias/keybind.

## Appearance / themes

- [ ] Add per-appearance ghostty `[appearance=dark]` / `[appearance=light]` conditional blocks (padding-color, minimum-contrast).
- [ ] Add `font-codepoint-map = U+E000-U+F8FF=Symbols Nerd Font Mono` for icon-font glyph routing.
- [ ] Switch ghostty to light/dark auto-switch theme: `theme = light:Adwaita,dark:Adwaita Dark`.

## Shell integration & performance

- [ ] Set ghostty `shell-integration = detect` and `shell-integration-features = cursor,sudo,title,ssh-env,ssh-terminfo`.
- [ ] Add optional host-specific include `config-file = ?work.conf` to ghostty config.
- [ ] Run `cmux config doctor` once and fix flagged keys in `cmux.json`.

## Workflow / dotfiles polish

- [ ] Set up `~/.config/cmux/dock.json` to pin TUIs (lazygit, log tail, test watcher) to the sidebar.

## Ideas / TBD

- [ ] _add your own here_
