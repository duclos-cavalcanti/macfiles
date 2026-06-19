# Neovim Power-User Landscape (mid-2026)

Research snapshot of current trends among Neovim power users. Folke and
tj-devries used as reference points for "expert" practice.

## The biggest shift: native core is eating plugins

Neovim **0.12** (released 2026-03-29) moves a lot of former plugin territory
into core:

- **`vim.pack`** — built-in plugin manager with lockfile support. Reproduce
  exact plugin versions across machines without `lazy.nvim` / `packer.nvim`.
- **Native insert-mode autocompletion** via the new `'autocomplete'` option.
- **Treesitter is built-in.**
- Expanded built-in LSP: `selectionRange`, `inlineCompletion`,
  `linkedEditingRange`, `documentLink`, viewport-only semantic tokens.

Neovim **0.11** already introduced native LSP config: drop a file in your
`lsp/` directory, call `vim.lsp.enable()` with a list of servers — no
`nvim-lspconfig` intermediary needed. Standard API is `vim.lsp.config()` /
`vim.lsp.enable()`.

**Trend:** experts are moving config *toward* core and trimming dependencies.
echasnovski (author of `mini.nvim`) wrote the canonical `vim.pack` guide.

## Folke is consolidating the ecosystem into `snacks.nvim`

`snacks.nvim` is one collection of ~40+ QoL modules (picker, explorer,
dashboard, bigfile handling, lazygit, animations, debugging utils) that
replaces many single-purpose plugins.

- `snacks.picker` and `snacks.explorer` are now **LazyVim defaults**,
  displacing Telescope (and the earlier move to fzf-lua).
- Folke's core stack: `lazy.nvim`, **LazyVim** (most popular distro),
  `which-key.nvim`, `tokyonight`, `trouble.nvim`, `noice.nvim`.

## Completion: `blink.cmp` beat `nvim-cmp`

`blink.cmp` (saghen) is the new default in **LazyVim** and **kickstart.nvim**.
Rust-backed fuzzy matching, batteries-included, near-zero config, typo-resistant.
`blink-copilot` adds a GitHub Copilot source into the menu.

## tj-devries

Now a full-time educator (Boot.dev courses, YouTube/streaming), still a Neovim
core contributor and the original **Telescope** author. Focus is on core
interfaces (LSP, treesitter) that let people extend their editors. Telescope
still huge but no longer the only fuzzy-finder default — fzf-lua and
snacks.picker compete.

## AI is the loudest 2026 trend — converging on ACP

ACP = **Agent Client Protocol**. Key plugins:

- **`codecompanion.nvim`** — multi-backend, ACP-based, multi-step task
  execution (auto-repair, unit-test generation).
- **`avante.nvim`** — Cursor-style AI sidebar; inline refactor, chat.
- **`agentic.nvim`** — ACP chat for Claude Code / Codex / Gemini / OpenCode /
  Cursor-agent. Zero-config auth (reuses terminal auth, MCP servers, skills,
  sub-agents); sessions interchangeable between terminal and editor.
- **`minuet-ai.nvim`** — as-you-type completion from OpenAI/Gemini/Claude/Ollama.
- **`copilot.lua`** — GitHub Copilot completions.

Claude Code ↔ Neovim integration is now a first-class power-user workflow.

## Stable bedrock (unchanged)

treesitter, LSP, `mini.nvim`, Mason, Tokyo Night / Kanagawa colorschemes.
Awesome-neovim lists ~2,800 maintained plugins. Starter distros (LazyVim,
AstroNvim, NvChad, LunarVim, kickstart.nvim) turned a 6-hour config job into a
one-command install.

## Sources

- https://dotfyle.com/neovim/plugins/trending
- https://github.com/folke/snacks.nvim
- https://github.com/folke/lazy.nvim
- https://github.com/saghen/blink.cmp
- https://dotfiles.substack.com/p/whats-new-in-neovim-012
- https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack
- https://linkarzu.com/posts/neovim/snacks-picker/
- https://github.com/carlos-algms/agentic.nvim
- https://changelog.com/podcast/457
- https://github.com/tjdevries
