---
name: terminal-organizer-direction
description: Terminal stack decisions — ghostty SETTLED as standalone emulator; wezterm trialed & rejected; zellij RE-TRIALING (2026-06-22) as organizer with a lean locked-first config; tmux kept for agentic; cmux fate open
metadata:
  type: project
---

**Settled (2026-06-21): ghostty is the terminal emulator**, run standalone — un-bundled from cmux via `brew install --cask ghostty`, now a `cask "ghostty"` Brewfile entry (replaced the short-lived `cask "wezterm"`). The existing stowed `~/.config/ghostty/config` drives it; `ghostty +validate-config` passes.

**Zellij — RE-TRIALING (reopened 2026-06-22).** First trial (2026-06-20, removed @ `ead3ad1`) was rejected as "too much ceremony / really hard to get in." Now back: reinstalled (`brew "zellij"` in Brewfile), config dumped fresh and aggressively slimmed to deltas-only (545→~30 lines): `session_serialization false`, `pane_frames false`, `default_mode "locked"`, tmux-compat layer removed. Building keybinds incrementally — flat Alt-binds in `locked {}` for the daily 90%, `Ctrl g` unlock for the long tail (see [[flat-locked-keybind-preference]]). Role: zellij owns the OUTER layer (tabs=projects, sessions, floats); tmux owns inner panes. The "hard to get in" complaint is being addressed by the lean-from-the-start approach this time.

**wezterm — trialed & REJECTED.** Resurrected from tag `wezterm-config` (@ `d16604e`) for a re-trial, then dropped in favor of ghostty. Tag still exists if ever wanted again (`wezterm.lua` + `config/{tab,theme,workspace}.lua`, Lua-configured tabs/workspaces).

**Still true:** tmux stays — it owns headless/server sessions + the agentic send-keys leverage (MADY kit). cmux is still installed; its fate is open, but standalone ghostty makes dropping cmux viable since ghostty was always cmux's renderer. Operator barely uses cmux's browser surfaces (its main GUI-only differentiator).

**How to apply:**
- Terminal-emulator question is CLOSED: ghostty. Do NOT re-pitch wezterm — hands-on rejected.
- Organizer/multiplexer is OPEN and active: zellij is being re-trialed on top of tmux. tmux stays as the kept inner/agentic layer; zellij is the outer organizer on trial. Build the zellij config lean (deltas-only) — the prior rejection was about ceremony/bloat, so resist re-growing it toward the full default dump.
- Terminal.app was rejected as the emulator (no OSC 9/777; binary-plist config breaks reproducibility) even though macOS 26 Tahoe added truecolor.

**Gotchas learned (Homebrew 6.x + cached casks):**
- `brew uninstall <formula>` auto-sweeps orphaned deps (autoremove-on-uninstall). Uninstalling zellij swept `gcc` (Brewfile-declared, reinstalled) + undeclared orphans `llvm@20`/`isl`/`libmpc`. Always check `brew bundle check` + `brew missing` after an uninstall.
- Resurrecting a *cached* cask (wezterm) deployed an old bundle not registered with LaunchServices → invisible to Spotlight. Fix: `lsregister -f <app>` + clear `com.apple.quarantine`. ghostty's cask was already registered; only needed quarantine cleared.
