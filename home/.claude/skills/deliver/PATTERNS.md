# deliver Patterns

Concrete templates for the `/deliver` orchestrator. Linked from [SKILL.md](./SKILL.md).

**Guiding principle:** the orchestrator's value is faithful execution of a structured pipeline, not creativity. When in doubt, copy the format here verbatim — drift causes downstream parsing breakage and weakens the human-decision summary.

---

## 1. Spec skeleton (`<TICKET-ID>.md`)

Written in Phase 1, read by the implementation subagent in Phase 2 and by every review agent in Phase 3.

```markdown
# <TICKET-ID> — <short title>

- **Status:** DRAFT — building up incrementally.
- **Ticket:** <Jira URL>
- **Precursor:** <PRECURSOR-ID> (what it established)
- **Companion precedent:** <MR-ID / TICKET-ID> (what house style it set)

---

## TLDR
<one sentence>

---

## Context
<2–4 paragraphs>

---

## Implementation

### Scope

#### Within-Scope
- **<Layer>** — **`<file/crate>`** (<current state with evidence>) — <prescribed change>.

#### Outside-of-Scope
- <load-bearing exclusion with reason>

### Pattern
<literal code from exemplar + second snippet applying the rule to this ticket's surface>

**Intentionally absent:**
- <field/move that looks like it'd belong but doesn't — one-phrase reason>

### Specifics
<omit this subsection entirely if the ticket has none>

#### <Concern name>
<why, correct shape, pitfalls>

---

## Acceptance Criteria

1. **<label>** — <testable claim>. *Verification: <mode>.*
2. ...

### Verification

**Where it lives.** `scripts/verify-<ticket>.sh`
**How it's used.** `./scripts/verify-<ticket>.sh all` or `./scripts/verify-<ticket>.sh ac1`
**AC → verification map:**

| AC | Mechanism | Invocation |
|---|---|---|
| 1 | script | `./scripts/verify-<ticket>.sh ac1` |
| 2 | cargo test | `cargo test <test_name>` |

**Ephemerality.** This script is tied to the spec. When conventions change, the script changes or dies. Durable source of truth: MANIFEST.

---

## Review

**Reviewers:**
- `<agent>` — <one-sentence relevance to this ticket>
- `<agent>` — <one-sentence relevance>

**Convergence loop.** The orchestrator drives the loop locally on the branch diff — no MR yet. Launch reviewers in parallel, consolidate findings, address mechanical findings via remediation subagent, re-run verification, re-launch reviewers. Repeat until zero findings for a full pass.

**Termination.** Loop terminates on a zero-finding pass. Escalate if: two consecutive passes produce the same findings, reviewers conflict on direction, or round count exceeds MAX_ROUNDS.
```

---

## 2. Implementation subagent dispatch (Phase 2)

Substitute `<TICKET>` and verify the spec path.

```
You are implementing Jira ticket <TICKET>. The orchestrator has produced a spec at <TICKET>.md with acceptance criteria, a test inventory, and implementation patterns.

Read these files first, in order:
1. <TICKET>.md — your spec (Scope, Pattern, ACs)
2. .claude/skills/tdd/SKILL.md — the TDD workflow you must follow
3. .claude/skills/tdd/PATTERNS.md — copy-paste-ready test examples per layer
4. MANIFEST.md — architecture, error handling, observability, and style conventions

Follow the /tdd skill for <TICKET>. Skip its Step 0 user-confirmation — the orchestrator already confirmed the spec with the user. Walk each Scope bullet as a separate TDD unit.

Commit RED/GREEN/REFACTOR per layer:
- <TICKET>: RED — <layer> tests for <feature>
- <TICKET>: GREEN — <layer> implementation for <feature>
- <TICKET>: REFACTOR — <layer> cleanup

Do not open a merge request. Do not modify files outside the spec's Scope.

When complete, report back:
- List of commits (git log master..HEAD --oneline)
- Layers touched
- Any deviations from the spec and why
- AC sign-off: `./scripts/verify-<ticket>.sh all` exit code (must be 0)
- Final state of: cargo test --workspace, cargo clippy -- -D warnings, cargo fmt --check
- Any tests that failed unexpectedly or were skipped, with rationale
```

---

## 3. Review-agent dispatch (Phase 3c)

Each reviewer gets this shape. Only the **Focus** line differs per agent.

```
You are reviewing local commits for <TICKET> (<one-line summary>) on the project. There is no MR yet — this is a pre-MR pipeline review. Do NOT post to GitLab.

Source branch: <branch>
Target branch: master
Files changed: <paste --stat output>

Read in order:
1. The diff at <DIFF_FILE_PATH>
2. <TICKET>.md — the spec (Scope, Pattern, ACs)
3. MANIFEST.md
4. Any ADDs in docs/ relevant to the changed files

Focus: <agent-specific focus>

For each finding, return EXACTLY this format (one block per finding, separated by a blank line):

[FINDING-<your-agent-name>-<n>]
file: <path>:<line>
severity: must-fix | should-fix | nit
problem: <one-line description>
suggestion: <concrete fix>
self_class: mechanical | design-level

If you find no issues in your domain, return literally: "NO FINDINGS — <agent-name>"

Severity definitions:
- must-fix: correctness, security, data integrity. Cannot ship.
- should-fix: observability, maintainability, design deviations. Blocks unless deferred.
- nit: style, naming, minor improvements.

self_class definitions:
- mechanical: deterministic fix, no design judgement, no contract change.
- design-level: changes a public contract, picks between valid options, expands scope, or contradicts the spec.
```

**Per-agent focus lines:**

| Agent | Focus |
|---|---|
| `rust-expert` | Ownership, async, trait design, error handling, performance, idiom |
| `architecture-reviewer` | Dependency direction, port/adapter integrity, Lambda thinness, ring leakage |
| `security-auditor` | OWASP API Top 10, IAM, crypto, secrets, input validation, audit trail |
| `aws-architect` | CDK stacks, Lambda config, Step Functions, DynamoDB, EventBridge, cost |
| `doc-generator` | Documentation gaps introduced by this change (ADDs, runbooks, API docs) |
| `design-advisor` | PRD/API-contract compatibility, role model, policy engine, integration patterns |

---

## 4. Remediation subagent dispatch (Phase 4d)

```
You are applying review-round remediation for ticket <TICKET>. Round <ROUND> of <MAX_ROUNDS>.

Read in order:
1. MANIFEST.md
2. <TICKET>.md

Apply the following findings exactly. Each is mechanical — do not redesign, do not expand scope, do not refactor beyond what each finding asks for. If a finding is ambiguous or its fix would conflict with another finding in this list, STOP and report the conflict instead of guessing — the orchestrator will re-classify it as disputed.

Findings:

<paste full structured finding list — mechanical only>

After applying:
- Run cargo test --workspace, cargo clippy -- -D warnings, cargo fmt --check
- Commit with message: "<TICKET>: REVIEW r<ROUND> — remediate <N> mechanical findings"
- Report back the commit hash, files touched, and final check status. If any tests now fail, list which and why.
```

---

## 5. Escalation summary (`docs/working/<TICKET>-review-summary.md`)

Phase 5 output. The header captures state; the body names the question the human needs to answer.

```markdown
# <TICKET>: Review Escalation Summary

**Rounds run:** <count> / <MAX_ROUNDS>
**Status:** ESCALATED — human decision required before MR
**Branch:** <branch>

## Disputed Findings

### [DISPUTE-<n>] <one-line summary>
- **Locus:** `<file>:<line>`
- **Severity:** <severity>
- **<agent-a>:** <position + suggestion>
- **<agent-b>:** <position + suggestion>
- **Question for human:** <the choice to make>

## Design-Level Findings

### [DESIGN-<n>] <one-line summary>
- **Locus:** `<file>:<line>`
- **Severity:** <severity>
- **Raised by:** <agent>
- **Problem:** <what the agent flagged>
- **Why it's design-level:** <classification rationale>
- **Question for human:** <the design call to make>

## Outstanding Mechanical Findings (deferred pending human decision)

<list — will be auto-applied after human resolves above, unless invalidated>

## Round History

| Round | Total | Mechanical | Disputed | Design-level | Outcome |
|---|---|---|---|---|---|
| 1 | N | N | N | N | <remediated / escalated> |
```

---

## 6. Orchestrator classification decision table

Quick reference for Phase 4b.

| Signal | Class |
|---|---|
| Agent flagged `mechanical` and suggestion is one localised edit | mechanical |
| Agent flagged `mechanical` but suggestion contradicts the spec's out-of-scope | design-level (override) |
| Two agents make opposing claims on the same locus or conceptual surface | disputed |
| Finding requires changing a port trait, adding/removing a `kind_label`, or modifying a CDK stack identity | design-level |
| Finding requires a new MR (key policy, ADD update, IAM policy on a separate stack) | design-level |
| Finding is rename/refactor with no contract change | mechanical |
| Finding is add `?` propagation / drop `.unwrap()` / fix clippy lint | mechanical |
| Remediation subagent reports it could not apply without a judgement call | re-classify as disputed |

**When in doubt: prefer escalate over remediate.** One human ping is cheaper than a wasted round.
