# Versioning AI Agent Assets as Dotfiles — Research

*Snapshot: June 2026. Deep-research pass (24 sources fetched, 112 claims extracted, 25 adversarially verified, 21 confirmed / 4 refuted).*

**Question:** Are power developers now storing their AI coding agent assets — Claude Code skills, subagents, slash commands, hooks, CLAUDE.md / AGENTS.md, MCP configs, and multi-agent "swarm" systems — in dotfiles repos the same way they historically version-controlled vimrc, tmux.conf, and wm rc files?

**Answer: Yes — emphatically.** It's now a recognized, named practice with dedicated tooling, mapping almost one-to-one onto the old dotfiles culture.

---

## 1. The trend: `~/.claude` is the new `~/.vimrc`

Two dominant patterns, confirmed across multiple independent repos:

- **Track `~/.claude` directly as a Git repo** — often with a shell wrapper that auto-pulls on session open and auto-commits/pushes on close.
- **Selective symlinking from a dotfiles repo** — version only the *portable* assets (`settings.json`, `agents/`, `commands/`, `skills/`) and exclude runtime junk (`history.jsonl`, `cache/`, `projects/`, session state). The cleaner pattern.

Key shift: people commit the *whole asset set* now (subagents, slash commands, hooks, skills, settings), not just `CLAUDE.md`. Storage format is the rc-file idiom: **markdown + YAML frontmatter, auto-discovered from directory layout**, with project-vs-global precedence (`.claude/agents/` overrides `~/.claude/agents/`) mirroring local-rc-beats-global-rc.

Links:
- https://github.com/elizabethfuentes12/claude-code-dotfiles — auto-sync `~/.claude` via Git (pull on open, push on exit)
- https://github.com/vsbuffalo/dotfiles/blob/main/docs/claude-code.md — selective symlink pattern; tracks `settings.json`/`agents/`/`commands/`/`skills/`, ignores runtime data
- https://felipeelias.github.io/2026/02/27/version-your-claude-files.html — "You Should Be Versioning Your ~/.claude Config" (Feb 2026)
- https://github.com/zircote/.claude — real-world `.claude` dotfiles repo
- https://github.com/citypaul/.dotfiles — real-world dotfiles repo with agent assets
- https://code.claude.com/docs/en/sub-agents — official docs: subagents = markdown + YAML frontmatter; check into version control
- https://drmowinckels.io/blog/2026/dotfiles-coding-agents/
- https://github.com/mfmezger/ai_agent_dotfiles
- https://alexop.dev/posts/claude-code-customization-guide-claudemd-skills-subagents/
- https://github.com/atxtechbro/dotfiles

## 2. Agent swarms: a real, public category

Multi-agent orchestration setups shared on GitHub like elaborate tmux/i3 configs. All store config as declarative, file-based, version-controlled artifacts (`swarm.yaml`, per-plugin `.claude/` dirs) auto-discovered from layout.

- https://github.com/ruvnet/ruflo — `claude-flow` (~53K stars). Queen-led hierarchy; hierarchical/mesh/adaptive topologies; Raft/Byzantine/Gossip consensus; HNSW vector memory across sessions; 19 plugins / 64 skills. The heavyweight.
- https://github.com/wshobson/agents — 192 subagents, 156 skills, 102 commands, 16 multi-agent orchestrators across 84 plugins.
- https://github.com/affaan-m/claude-swarm — decomposes a task into a dependency graph, runs independent subtasks as parallel agents via the Claude Agent SDK.
- https://github.com/dsifry/metaswarm — self-improving orchestration running across Claude Code + Gemini CLI + Codex CLI.
- https://github.com/VoltAgent/awesome-claude-code-subagents — catalog of 154+ subagents (22K stars); "awesome-list" pattern for agents.
- https://github.com/modu-ai/moai-adk — orchestrates 24 agents + 52 skills.
- https://codex.danielvaughan.com/2026/04/11/agentmaxxing-parallel-multi-cli-orchestration/

## 3. Portability — two standards, doing different jobs

Don't conflate these — they operate at different layers:

- **`AGENTS.md` + Anthropic Agent Skills (`SKILL.md`)** → portability of the *prompt/skill content*. `SKILL.md` (YAML frontmatter + markdown, spec published Dec 18 2025) designed to work across 30+ tools (Gemini CLI, Codex/ChatGPT, Cursor, VS Code/Copilot, JetBrains Junie, AWS Kiro, Block Goose) without modification. The **asset-level** standard.
- **Agent Client Protocol (ACP)** → portability of the *editor↔agent connection*. JSON-RPC over stdio (local) / HTTP+WebSocket (remote), "LSP for coding agents." Decouples any ACP agent from any ACP editor. The **transport** layer — *not* skill portability. Created by Zed (Aug 2025); adopted by JetBrains, VS Code, OpenCode; 25+ agents.

Rule: ACP makes your agent pluggable into any editor; AGENTS.md/SKILL.md makes your prompts and skills readable by any agent.

Links:
- https://agentclientprotocol.com/get-started/introduction — ACP spec
- https://github.com/agentclientprotocol/agent-client-protocol
- https://zed.dev/acp
- https://www.morphllm.com/agents-md-guide
- https://hivetrail.com/blog/agents-md-vs-claude-md-cross-tool-standard
- https://codersera.com/blog/agents-md-vs-claude-md-cursor-rules-comparison-2026/
- https://codex.danielvaughan.com/2026/05/27/agent-instruction-files-agents-md-claude-md-cross-tool-portability-codex-cli/
- https://ossinsight.io/blog/agent-skills-explosion-2026

## 4. Best practices for tool-agnostic porting

Winning pattern: **one source of truth → sync/translate into each runtime's native format**, instead of maintaining parallel per-tool files.

- https://github.com/numman-ali/openskills — "universal skills loader"; generates an `<available_skills>` XML block into `AGENTS.md` so any AGENTS.md-reading agent invokes a Claude-style skill via `npx openskills read <skill>` — no Claude Code required.
- https://github.com/PMelch/agentdots — define rules/skills/commands/mcp once; emit native configs (`.claude/`, `.cursor/`, `copilot-instructions.md`, `GEMINI.md`). Two-tier global + project layout. *(Flagged early-development, not usable yet.)*
- https://github.com/yelmuratoff/agent_sync — "Write AI rules once → sync to Claude, Cursor, Copilot, Gemini and 10 more tools."

Conventions that hold up:
- Markdown + YAML frontmatter for every asset; directory-based auto-discovery (`agents/`, `commands/`, `skills/`).
- Two-tier precedence: global (`~/.claude/`, `~/.agentdots/`) + project (`.claude/`, `.agentdots/`), project wins.
- `.gitignore` runtime state (history, cache, sessions); version only declarative config.
- Treat `AGENTS.md` as the lowest-common-denominator interop layer; let a sync tool fan it out.

## Caveats (the verifier killed 4 claims)

- **"Power users do this" is asserted, not surveyed.** No telemetry quantifies adoption. The *practice* is well-documented; *prevalence* is inferred.
- **Cross-runtime portability is interface-level, not behavior-tested.** No independent compatibility matrix proves a skill behaves identically across Claude Code, Cursor, Aider, Codex, Gemini. The claim "one markdown source is natively consumed unmodified across 5 non-Claude runtimes" was **refuted 0-3**.
- **No single directory naming convention has converged.** Per-tool layouts persist; sync tools *are* the interop layer, not a shared standard.
- Several swarm/sync projects are single-author, design-intent repos, not independently benchmarked.
- Everything is a **June 2026 snapshot** of a fast-moving field (Agent Skills spec Dec 2025, ACP from Aug 2025).

## Open questions

- What share of developers actually version-control agent assets vs. traditional dotfiles? No survey data found.
- How reliable is cross-runtime portability in practice? Interfaces defined; no tested end-to-end compatibility matrix.
- Will one naming/directory convention converge, or will per-tool layouts + sync tools persist?
- **Secrets / MCP credential handling when configs are committed/shared publicly** — underspecified in sources. `.gitignore` the cache, never commit secrets, but the safe pattern for sharing MCP config across machines/teams was not detailed. Worth nailing down before publishing any `~/.claude` config.
