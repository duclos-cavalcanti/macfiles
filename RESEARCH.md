# Agentic Cycle → MADY Kit Mapping

**Companion, not a fork.** The canonical research already lives in the kit and is deeper + fully cited:
- `~/Work/mady/b2b-api-claude-skills-dev/tooling/mady/RESEARCH.md` — F1–F5 findings (lean=capability, positional degradation, intent/env/mechanics split, script-the-routine, 3–5 fan-out), SDD framing, Caprock contrast.
- `…/tooling/mady/SIMPLIFICATION.md` — 4-pass debloat roadmap (Pass 4 = escalation collapse / diagnosis-at-the-cog).
- `…/tooling/mady/PEER-COMPARISON.md` — Caprock + Hive fleets, takeable directives.

This doc adds the one lens those don't use explicitly: the **plan → decompose → retrieve → act → verify** cycle, mapped onto the real cogs/files. Per your own F3/SDD rule (single source of truth), nothing here restates a contract — it points.

---

## The cycle is a context-engineering problem, not a workflow diagram

Each of the five moves exists to keep the *act* step's context lean and correct. The loop degrades when the window fills with noise, not when the model gets dumb. Your kit already encodes this — below is where each stage lives and how strong it is.

### Plan — externalize intent to disk (STRONG)
- **Where:** foreman L1 → `/mady-evaluate-ticket` (clarity + dependency scan + complexity, emits `VERDICT`) → `bin/agents/foreman/classify.py` (dependency DAG) → **dispatch packet** (`schemas/dispatch.schema.json`).
- The packet *is* the externalized spec. This is SDD done right (your RESEARCH.md: "the dispatch packet is a spec the worker derives from"). It survives compaction and seeds the worker at birth (`worker.md:19`).
- Foreman writes intent, mutates nothing else (README §2) — clean intent/actuation split.

### Decompose — atomic, isolated, independently verifiable (STRONG)
- **Where:** foreman classifies `READY-CLEAN`/`READY-STACKED` + `block_on`; one ticket → one worker → one worktree (`worker.md:18` "no cross-ticket reasoning").
- This is F5 (specialization + context isolation) made physical: git worktrees give each cog a wall it can't see past. Matches the literature's "3–5 specialist fan-out, isolate context to prevent hallucination."

### Retrieve — just-in-time, not upfront (STRONG, with one known weak edge)
- **Where:** ticket derived from `git branch --show-current` (`worker.md:55`); packet/status read on first tick; jira/glab CLIs fetch on demand; auditor reviews **by SHA in the master mirror — checkout-free** (README §2). Restart Awareness re-derives state from disk (`worker.md:100`), never from memory.
- **Weak edge you've already flagged:** the perpetual singletons (foreman/overseer/auditor) accumulate their own transcript in-session — the Hive measured this shape at ~85% cache-read, quadratic in tick count (`SIMPLIFICATION.md` #19 cold-tick). That's a context-*lifespan* leak. The cogs are already disk-stateless (Restart Awareness), so the fix — fresh cold `claude` per tick, paced by a bash supervisor — is unblocked once cost instrumentation (#18) confirms the exposure.

### Act — minimal, recoverable, committed (STRONG)
- **Where:** worker `/mady-implement` (shape-routed logic/infra/docs/claude); commits + draft MR (**"the draft MR is the resume container"**, `worker.md:120`); `snapshot.sh` writes atomic status drops + append-only `.jsonl` per tick.
- **git history + status JSONL = the agent's undo stack** — this is exactly Anthropic's long-running-harness trick ("git + progress file let the agent detect a broken state and revert"). Your Restart Awareness branch (`worker.md:112`) is the recovery procedure, more disciplined than the blog's `claude-progress.txt`.

### Verify — adversarial, independent, default-to-skeptical (STRONG — your real edge)
- **Where:** three independent layers.
  1. `/mr-review` loop until nits-only (worker, in-context).
  2. **auditor** — a *separate* singleton reviewing by SHA, posts what the SME fleet would catch (README §2). Independent context = real verification, not self-report theater.
  3. **inspector** — ephemeral pre-escalation refuter, `subagent_type: inspector`, mandate **"refute, default to GENUINE"** (`worker.md:200`, `SIMPLIFICATION.md` Pass 4). This is the adversarial-verify / "default-to-refuted" pattern as a custody guard — *stronger* than the cold-overseer auto-drain it replaced, because the refute runs where the live context is.
- The literature's headline ("the bottleneck moved from generation to verification; fast output isn't trustworthy output") is the thing your kit invests most in. Most setups skip it.
- **The one genuine gap vs. the harness paper:** it pushes *behavioral* verification — exercise the artifact as a user would (e2e / browser-drive), mark done only after an observed green run. Your verify is review + CI + tests. For a Rust `b2b-api` that's largely covered by integration tests in CI — but it's worth a conscious check: does any MR land "reviewed + CI-green" without the running service ever being exercised end-to-end? If yes, that's the only stage where you trail the 2026 best practice.

---

## How "empowering the cycle" maps to your open roadmap

The external 2026 idioms aren't new asks for you — they're already tickets:

| Idiom (external) | Your kit's stage it strengthens | Already tracked as |
|---|---|---|
| Lean prompts are a *capability* lever (not style); positional degradation | Plan/Act — unbury judgment | Pass 2 (thin agents); overseer 452→~250L |
| Schema = single source of truth (SDD) | Plan — contract integrity | Pass 2 P0 (contracts → `schemas/*.json` descriptions) |
| Reasoning lives with the data | Verify — diagnosis at the cog | Pass 4 (escalation collapse; `auto_resolve` deleted) |
| Context lifespan / JIT retrieval | Retrieve — stop transcript bloat | #18 cost ledger → #19 cold-tick singletons |
| Script the routine, keep the judgment | all stages — determinism boundary | F4; the "resist" list (conflict resolution, diagnosis stay LLM) |

**Verdict:** you don't need to *adopt* the frontier — you're at or ahead of it on plan/decompose/act/verify, and the two real frontiers (cold-tick the singletons, optional behavioral-verify) are already on the board. The highest-leverage move is finishing the dedup passes (Tier 1 removals) so the cogs' judgment stops sitting under contract-paraphrase where attention is weakest — which is precisely what `SIMPLIFICATION.md` ranks first.

If you want, I can: (a) sanity-check the behavioral-verify gap by tracing whether any `/mady-finish` path lands an MR without an e2e exercise, or (b) take the next unticked Tier-1 removal in `SIMPLIFICATION.md` and draft the diff. Say which.
