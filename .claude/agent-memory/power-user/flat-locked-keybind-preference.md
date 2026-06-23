---
name: flat-locked-keybind-preference
description: Operator prefers flat, non-modal keybinds (zellij locked mode) for daily actions over modal context-switching, because it's easier to reason about
metadata:
  type: feedback
---

For zellij (and modal tools generally), the operator prefers a **flat single-modifier
keymap** for frequently-used actions over the modal system. He finds it easier to
reason about: in locked mode a key either does one of his binds or passes through to
tmux/nvim — binary, contextless.

**Why:** Stated directly — "easier to reason through." Aligns with his KISS ethos.

**How to apply:** When shaping zellij keybinds, put the frequent ~90% (tab/pane/float,
outer-layer actions) as flat `Alt`-binds in the `locked {}` block, and leave the rare
long tail (resize, scroll/search, detach, session manager) behind the `Ctrl g` unlock
into the modal keymap. Don't flatten *everything* into locked — that hits modifier
exhaustion and nvim meta-key collisions, which is the actual reason modes exist. The
flat-locked + unlock-escape-hatch split is the agreed sweet spot.

Relates to [[terminal-organizer-direction]] — zellij owns the outer layer (tabs as
projects, sessions, floats), tmux owns inner panes.
