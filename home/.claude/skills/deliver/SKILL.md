---
description: End-to-end ticket delivery — spec, implement via subagent, review with confidence gate, remediate or escalate, open MR
argument-hint: <Jira ticket ID> [auto]
---

# Skill: deliver

You are the **orchestrator** of a full ticket-to-MR pipeline. You author the spec collaboratively with the user, dispatch implementation to a fresh subagent, run a structured review with a two-axis confidence gate, remediate mechanical findings or escalate design-level and disputed ones, and only then open the MR.

**Argument:** A Jira ticket ID (e.g. `MADY-72`). Required.

**Optional flag:** `auto` — drafts the entire spec end-to-end without per-section checkpoints. The orchestrator makes its best judgment on every section, annotates non-obvious calls in the spec as `> NOTE (auto): chose X because Y; reverse this if Z.`, and transitions straight from 1e's baseline run into Phase 2. Phases 2–6 are unchanged: 4a's volume pause, Phase 5 escalation, and the user's merge call all still require the human.

**Key principle:** implementation runs in a subagent so the orchestrator's context stays clean for review and remediation. The MR is a publication artifact, not a working surface — review convergence happens locally.

See [PATTERNS.md](./PATTERNS.md) for templates: spec skeleton, subagent dispatch prompts, finding format, escalation summary, and the classification decision table.

---

## Configuration

| Knob | Default | Purpose |
|---|---|---|
| `MAX_ROUNDS` | 3 | Maximum review-and-remediate rounds before forced escalation |
| `VOLUME_THRESHOLD` | 25 | Total finding count that triggers a pause-and-confirm before remediation |

Both are constants in this skill — adjust by editing this file, not by argument.

---

## Archive

Each ticket leaves a paper trail in `~/Work/tickets/<TICKET-ID>/` so you can look back at the spec and review history that produced any given MR/branch state. Layout:

```
~/Work/tickets/<TICKET-ID>/
├── spec.md         # written once at end of 1f, refreshed at Phase 6 only if the live spec was edited later
├── findings.md     # appended at the end of each round, with `## Round N` header + structured findings + resolution per finding
├── escalation.md   # written at Phase 5 if reached (mirror of docs/working/<TICKET>-review-summary.md)
└── mr.md           # written at Phase 6 with the MR URL + review audit trail
```

Create the per-ticket directory lazily: if `~/Work/tickets/<TICKET-ID>/` doesn't exist when the first archive write happens (1f), `mkdir -p` it. If `~/Work/tickets/` itself doesn't exist, abort with a clear error — the user should decide where to place the archive root.

---

## Core principles

Keep these in mind at every step. They are harder to follow than they look.

- **Evidence over assertion.** Before you write a claim about the codebase, verify it — grep, read the file, run the audit. The original ticket's claims may be stale against current code; your job is to reconcile, not parrot.
- **Make decisions, don't park them.** A spec with "TBD" or "decision pending" is not a spec. Open a dialogue with the user to close each open question; never leave a placeholder for a future implementer.
- **Don't repeat.** If Context covers something, Scope should not. If Pattern states a rule, Out-of-Scope should not restate it. Prefer one clear sentence over three variations.
- **Brevity over completeness.** A spec the reader reads cover-to-cover is worth more than an exhaustive one they skim. Cut what isn't load-bearing.
- **Waive nothing.** If the user pushes back on a bullet's necessity, explain the source — where it came from (ticket, MANIFEST, session decision, your own hedging) and what load it bears. Be honest when the answer is "I added it out of caution" and accept deletion.
- **Durable enforcement lives outside the spec.** In-code doc comments, scripts, and MANIFEST survive the spec's deletion. Pointer references in code must anchor to durable sources, not to the spec file.
- **Escalate over remediate when in doubt.** One human ping is cheaper than a wasted round.
- **Orchestrator stays clean.** Implementation and remediation run in subagents. The orchestrator plans, reviews, and classifies.

---

## Phase 1 — Spec

Build the spec collaboratively with the user, one section at a time. Do **not** draft the whole file in one pass — each section is a decision checkpoint.

**Auto mode.** If the user passed `auto`, this whole phase runs without per-section dialogue. Draft the full spec end-to-end, audit each claim per 1d, and annotate any non-obvious choice with `> NOTE (auto):` so the user can audit and override after the fact. The 1f user gate is replaced by an automatic transition to Phase 2 once the 1e baseline is recorded.

*Subagents in auto mode — research, not reflection.* Default to deciding open questions in the orchestrator; spawning a subagent to "reflect" on a judgment call is mostly redundant (same model, same material, added latency). Two narrow exceptions:
- **Factual gaps** — dispatch `Explore` for lookups (precedent search, "where is X handled?", call-graph questions). Cheaper than absorbing grep noise into the orchestrator's context.
- **High-risk design calls** — pre-consult one Phase 3 reviewer agent (`security-auditor`, `architecture-reviewer`, `rust-expert`, etc.) when **all three** hold: (a) the decision is design-level, (b) it sits on that reviewer's axis, (c) getting it wrong would torpedo Phase 3. Use sparingly — this duplicates Phase 3 work, so it pays off only on the gnarliest 1–2 calls per spec.

### 1a. Environment

1. Run `git rev-list --left-right --count origin/master...HEAD`. If the branch is behind, propose a fast-forward (`git merge --ff-only origin/master`). Auditing against a stale tree produces bogus findings.
2. Verify the working directory is on a feature branch (not `master`). If not, ask the user which branch to use or create one via `/worktree`.
3. Verify `glab` is available.

### 1b. Read sources

1. Fetch the ticket via Atlassian MCP: `mcp__claude_ai_Atlassian__getJiraIssue` with the ticket ID. Read end-to-end. Record the Jira `created` timestamp. Do not copy the ticket body into the filesystem — reference it from the spec header and re-fetch via MCP when needed.
2. Read `MANIFEST.md` — the authoritative house-style convention. Every spec claim must align with MANIFEST or explicitly acknowledge it is overriding with rationale.
3. Read precursor ticket(s) the source ticket depends on. For each, fetch the Jira ticket AND find the merge commit (`git log --all --grep="<PRECURSOR>"`). The original ticket may reference artefacts from the precursor's *proposed design* that did not survive implementation — reconcile this drift.
4. Read companion precedent — recent MRs or tickets that set house style for an adjacent problem.

### 1c. Build the spec incrementally

Write the spec at `<TICKET-ID>.md` in the repo root, one section at a time. Use the skeleton in [PATTERNS.md Section 1](./PATTERNS.md) as the starting template. Do **not** draft the whole file in one pass — each section is a decision checkpoint with the user.

**The spec file must never be committed to git.** It is a working artifact for the life of the ticket. Ensure it is gitignored or excluded from staging — the worktree gets cleaned up eventually, so no manual deletion is needed.

#### Section-by-section guidance

**TLDR.** One sentence. If you can't write it in one sentence, the ticket is too broad.

**Context.** Four questions as prose, one paragraph each:
1. What does this ticket follow from?
2. What motivating observation made this ticket exist?
3. Is the source ticket internally consistent with current code? Name reconciliations.
4. What bridges forward to Implementation?

**Implementation.** Three parts, in this order — orient (where), then shape (general how), then detail (specific how):
- *Scope* — silhouette, not prescription of behaviour. Each Within-Scope item: file path, current state with evidence, prescribed change. Outside-of-Scope bullets must be load-bearing: they exist because the ticket asks for the opposite, a reviewer might raise it, or an orthogonal concern surfaced during audit.
- *Pattern* — the canonical shape as literal code from a real exemplar, plus a second snippet applying it to an in-ticket call site. Annotate with inline comments tying each element to its source. Close with "Intentionally absent" — fields/moves that look like they'd belong but don't.
- *Specifics* — per-ticket details the Pattern doesn't cover. Each concern gets its own `####` subsection answering why it exists, the correct shape, and pitfalls to avoid. Omit if the ticket has none.

**Acceptance Criteria.** Each AC: `N. **<label>** — <testable claim>. *Verification: <mode>.*` Prefer: ripgrep/script > cargo test > manual MR evidence > reviewer policy.

**Verification.** Four parts: where it lives, how it's used, AC→verification map, why it is ephemeral.

**Review.** Select 2–3 reviewer agents matching the ticket's surface from `.claude/agents/`. For each, one sentence on why this ticket needs their domain. Then the convergence loop rules and termination criteria (these are executed verbatim in Phase 3).

### 1d. Audit before you write

Before every Scope or AC claim, verify the current state empirically — `rg`, `find`, `cat`, `git log`. If a claim rests on something unverified, either verify it or soften it. Do not guess at line counts, annotation counts, or file contents.

### 1e. Programmatic verification

If one or more ACs are script-checkable, create `scripts/verify-<ticket>.sh`:

- Bash with `set -euo pipefail`
- One function per script-checkable AC
- CLI dispatch: `./scripts/verify-<ticket>.sh [acN|all]`
- Exit 0 if all pass, 1 if any fail
- Header comment naming the script as ephemeral and tied to this ticket only

Run immediately. The baseline should flag exactly the gaps Scope enumerates.

**Verification scripts must never be committed to git.** They are local working artifacts — used to confirm completion and re-verify after review remediation. Ensure they are gitignored or excluded from staging — the worktree gets cleaned up eventually, so no manual deletion is needed.

### 1f. User gate

**Present the complete spec to the user and require explicit approval before proceeding.** This is the mandatory gate between planning and implementation. The user may stop here if they only wanted a spec.

**Auto-mode override.** If invoked with `auto`, skip the explicit-approval step — passing `auto` is the approval. Show the user the completed spec for visibility, then proceed directly to Phase 2.

Update the spec status to `APPROVED`.

**Archive snapshot.** `mkdir -p ~/Work/tickets/<TICKET-ID> && cp <TICKET-ID>.md ~/Work/tickets/<TICKET-ID>/spec.md`. This is the frozen approved state — Phase 6 only refreshes it if the live spec was edited later (e.g. after a Phase 5 resolution).

---

## Phase 2 — Implementation (fresh subagent)

Dispatch a `general-purpose` subagent. The subagent runs in the same working tree with a fresh context — it does not see this conversation. Its commits land directly on the current feature branch.

**Dispatch prompt** (see PATTERNS.md for the full template):

The subagent receives:
- The ticket ID
- Pointers to: the spec, `/tdd` skill, MANIFEST
- Instruction to follow `/tdd` per Scope bullet, skipping its user-confirmation (the orchestrator already confirmed)
- Convergence target: `scripts/verify-<ticket>.sh all` exits 0 **and** `cargo test`, `cargo fmt --check`, `cargo clippy --all-targets -- -D warnings` are clean. Iterate `/tdd` until both hold, or stop and report if genuinely blocked.
- Commit format: `<TICKET>: RED/GREEN/REFACTOR — <layer> <feature>`
- Instruction to NOT open an MR
- Required report: commits produced, layers touched, deviations from plan, final check status

Do not run with `isolation: worktree` — commits should land on the feature branch directly.

If the subagent reports failing checks, treat as Phase 2 complete with caveats — failures will surface as findings in Phase 3.

---

## Phase 3 — Review

Run a structured multi-agent review against the local diff. 

- Operates pre-MR.
- Phase 3 runs once per review round, up to `MAX_ROUNDS`. 
- The goal is convergence to a zero-finding pass; each round's findings feed Phase 4, which either remediates (returning here for round N+1) or escalates. 
- The verification gate in 3b therefore acts both as a pre-flight on round 1 and as a double-check on the prior round's fixes on every subsequent round.

### 3a. Capture the diff

```bash
ROUND=<n>  # starts at 1, increments each iteration
git diff master...HEAD > /tmp/deliver-<TICKET>-r${ROUND}.diff
git diff master...HEAD --stat
git log master..HEAD --oneline
```

### 3b. Verification gate

Before each review pass:
1. `scripts/verify-<ticket>.sh` — must exit 0
2. `cargo test` — must be green
3. `cargo fmt --check` — must be clean
4. `cargo clippy --all-targets -- -D warnings` — must be clean

If any fail, fix before proceeding. Do not waste reviewer cycles on regressions the gate catches.

### 3c. Dispatch reviewer agents (parallel)

Launch the reviewer agents named in the spec's Review section as parallel `Agent` calls in a single message. Each receives:

- Ticket ID and one-line summary
- Path to the diff file
- The `--stat` output inline
- Source branch and target branch (`master`)
- Pointers to: MANIFEST, the spec, relevant ADDs
- Instruction to return findings as text only — no MR notes

**Required finding format:**

```
[FINDING-<agent>-<n>]
file: <path>:<line>
severity: must-fix | should-fix | nit
problem: <one-line description>
suggestion: <concrete fix>
self_class: mechanical | design-level
```

**Skip rules:** don't dispatch an agent whose domain isn't touched by the diff.

### 3d. Consolidate findings

Aggregate across agents:
- Deduplicate overlaps (preserve per-agent attribution)
- Total count, per-agent counts by severity
- Full finding list in structured format

---

## Phase 4 — Confidence gate

Classify every finding and decide the round outcome.

### 4a. Volume check

If total findings > `VOLUME_THRESHOLD`: pause, show the user the round summary, ask whether to proceed, escalate, or revise the plan. High volume usually signals a planning miss.

### 4b. Resolution-class classification

For each finding, assign `resolution_class`:

- **mechanical** — fix is deterministic and self-contained. The agent's `self_class: mechanical` is the starting signal, but verify — agents under-flag design implications.
- **disputed** — two or more agents take contradictory positions on the same locus or conceptual surface. Even at nit severity, disputed findings escalate.
- **design_level** — fix changes a public contract, picks between valid options, or expands scope. Override a `mechanical` classification upward if the fix conflicts with another finding or the plan.

### 4c. Gate decision

| | mechanical | disputed | design_level |
|---|---|---|---|
| **must-fix** | remediate | escalate | escalate |
| **should-fix** | remediate | escalate | escalate |
| **nit** | remediate | escalate | escalate |

Then:

- **Any disputed or design_level findings** → ESCALATE (Phase 5). Mechanical findings wait.
- **All findings mechanical** and round ≤ `MAX_ROUNDS` → REMEDIATE (Phase 4d).
- **Round > MAX_ROUNDS** → ESCALATE regardless.
- **No findings** → append `## Round <N> — Clean pass (zero findings)` to `~/Work/tickets/<TICKET-ID>/findings.md`, then PASS → Phase 6.

### 4d. Remediate (mechanical only)

Dispatch a fresh `general-purpose` subagent with the curated mechanical finding list. This is targeted remediation, not redevelopment.

The subagent receives:
- Pointers to MANIFEST and the spec
- The full mechanical finding list with instruction to apply exactly — no redesign, no scope expansion
- Instruction to stop and report if a finding is ambiguous or conflicts with another
- Required: run checks, commit as `<TICKET>: REVIEW r<N> — remediate <count> mechanical findings`, report back

Before returning, append `## Round <N>` to `~/Work/tickets/<TICKET-ID>/findings.md` with the round's full structured findings list and `resolution: remediated in r<N>` on each. Increment ROUND, return to Phase 3. If the subagent reports a conflict, treat as disputed and escalate.

---

## Phase 5 — Escalation (human decision required)

Reached when disputed/design-level findings exist or `MAX_ROUNDS` exhausted.

Write `docs/working/<TICKET>-review-summary.md` (see PATTERNS.md for full template):

- Rounds run / MAX_ROUNDS
- Status: ESCALATED
- Disputed findings: locus, both positions, question for human
- Design-level findings: locus, problem, why it's design-level, question for human
- Outstanding mechanical findings (deferred)
- Round history table

**Archive.** Mirror the summary to `~/Work/tickets/<TICKET-ID>/escalation.md`. Append `## Round <N>` to `~/Work/tickets/<TICKET-ID>/findings.md` with the round's structured findings and `resolution: escalated — see escalation.md` on each.

**Stop here.** Do not open the MR. Tell the user the summary path and ask how to proceed.

When the user resolves the escalation:
- Apply their decisions
- Re-run from Phase 3 with the updated code
- **If the resolution changes the ticket's fundamental design or goal** — a different architectural approach, a major Scope shift, an AC redefined — edit `<TICKET-ID>.md` to reflect the new state. Most resolutions are code-only; only update the spec when the *plan itself* has changed. Phase 6's mtime check will refresh the archived `spec.md` automatically.

---

## Phase 6 — Open the MR

Reached only when a review round passes with zero findings.

1. Invoke `/create-mr` with target branch `master`.
2. Ensure the MR description embeds the review audit trail:

   ```markdown
   ## Review Rounds

   - **Reviewers:** <comma-separated list>
   - **Rounds run:** <count>
   - **Total findings remediated:** <count across all rounds>
   - **Final round:** clean (zero findings)
   - **Deferred non-blocking items:** <list with rationale, or "none">
   ```

3. Remove draft status.
4. Display the MR URL and summarise: convergence passes, reviewers used, final AC state, deferred items.
5. **Archive.** Write `~/Work/tickets/<TICKET-ID>/mr.md` with the MR URL, reviewers used, rounds run, total findings remediated, and any deferred items. If the live `<TICKET-ID>.md` mtime is newer than the archived `spec.md`, refresh `spec.md` (the spec was edited post-1f, e.g. after Phase 5 resolution).
6. Stop. The user owns the merge decision.

---

## Failure modes to avoid

- **Drafting the whole spec in one pass.** Section-by-section lets the user correct course.
- **"Decision pending" placeholders.** Close every question before moving on.
- **Inventing facts to fill sections.** Verify before claiming.
- **Opening the MR before convergence.** The MR is a publication of converged work.
- **Batching Scope items into one TDD run.** TDD scales by unit, not by ticket.
- **Running review with no verification gate.** Reviewers waste cycles on regressions.
- **Picking reviewers at execution time.** The spec picked them for reasons tied to the ticket's surface.
- **Auto-fixing disputed or design-level findings.** Always escalate.
- **Silently looping past MAX_ROUNDS.** Escalate — continuing is a red flag.
- **Referring to the spec file from in-code comments.** The spec dies; anchor to MANIFEST or permanent URLs.

