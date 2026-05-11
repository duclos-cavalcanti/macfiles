---
name: mr-reply
description: Apply reviewer feedback on the current branch's MR — fetch open threads, queue them, apply the suggested fixes, verify, rebase against the upstream target, and push. Lenient posture toward peer reviews; only escalates on strong pushback.
allowed-tools: Bash(git *), Bash(glab *), Bash(cargo *), Bash(python3 *), Bash(./scripts/*), Bash(jq *), Bash(rg *), Bash(printenv *), Read, Edit, Write, Agent
argument-hint: [mr-iid]
---

# Skill: mr-reply

You are the **reply-side counterpart** to `/mr-review`. You fetch the open reviewer findings on the MR for the current branch (or the IID if given), queue them, apply each fix locally, verify the result, rebase against the upstream target, and push.

**Posture:** lenient toward peer reviews. Apply suggestions by default, even when they fall mid-scope. Do **not** propose deferring to a follow-up ticket when the fix is within the MR's logical scope. Escalate to the user only on **strong pushback** — see §3 for the heuristic.

**Argument:** optional MR IID. If omitted, look up the open MR whose `source_branch` matches the current local branch. Fail loudly if zero or more than one match.

---

## Configuration

| Knob | Default | Purpose |
|---|---|---|
| `MAX_APPLY_ROUNDS` | 2 | Apply→verify cycles before forced escalation. Round 2 only fires if the verification gate caught a regression on round 1. |
| `STRONG_PUSHBACK_REQUIRES_USER` | true | Whether to stop on strong-pushback findings (always true unless explicitly overridden by the caller). |

---

## Step 1 — Discover the MR

1. Confirm we're inside a git repo and on a feature branch (not the default branch). Abort if `git symbolic-ref refs/remotes/origin/HEAD` resolves to the current branch.
2. Capture the current branch: `BRANCH=$(git rev-parse --abbrev-ref HEAD)`.
3. Capture the working tree state: `git status --porcelain`. Bail if non-empty — apply on a clean tree only, so the diffs you produce are attributable to this skill alone.
4. **Resolve the MR:**
   - If the user passed an IID: `MR_IID=<arg>`.
   - Else: `glab mr list --source-branch "$BRANCH" --state opened --output json | jq '.[] | .iid'`. Expect exactly one match. Fail with a clear message if zero or many.
5. Capture metadata in one shot:
   ```bash
   glab api "projects/:fullpath/merge_requests/${MR_IID}" \
     | python3 -c '
   import json, sys
   m = json.load(sys.stdin)
   dr = m["diff_refs"]
   print(f"BASE_SHA={dr[\"base_sha\"]}")
   print(f"HEAD_SHA={dr[\"head_sha\"]}")
   print(f"TARGET={m[\"target_branch\"]}")
   print(f"AUTHOR={m[\"author\"][\"username\"]}")'
   ```
6. Confirm the local `HEAD` SHA matches `HEAD_SHA` from the API. If not, the remote branch is ahead — pull (`git pull --ff-only`) or warn the user before continuing. The reviewer findings reference the remote HEAD's diff anchors; applying against an older local tree produces incoherent commits.

## Step 2 — Fetch findings (queue construction)

1. Pull every resolvable, **unresolved** discussion thread:
   ```bash
   glab api "projects/:fullpath/merge_requests/${MR_IID}/discussions" --paginate \
     | jq '[.[]
            | select(.notes[0].resolvable == true)
            | select(.notes[-1].resolved == false)
            | {id: .id,
               author: .notes[0].author.username,
               body: .notes[0].body,
               position: .notes[0].position}]' \
     > /tmp/mr-reply-${MR_IID}-queue.json
   ```
2. For each thread in the queue, parse:
   - **`severity`** — match the body prefix against `**must-fix`, `**should-fix`, `**nit`. Default `nit` if absent.
   - **`anchor`** — `(new_path or old_path)` + `(new_line or old_line)` from `position`. May be null for top-level discussions.
   - **`is_bot`** — author username matches `^group_[0-9]+_bot_`. Bot findings still get applied (lenient posture), but they sort after human findings of the same severity.

   **Mega-review split.** If a thread's body contains multiple discrete findings (numbered list, bullets with distinct severity prefixes, or "and also…" chains), split into one sub-finding per discrete request. All sub-findings share the same `discussion_id` but get sub-indices `<id>.1`, `<id>.2`, etc. Each sub-finding is applied as its own commit and replied to as its own note inside the shared thread; the thread is resolved only after the last sub-finding's reply has been posted.
3. Sort: human must-fix → human should-fix → human nit → bot must-fix → bot should-fix → bot nit. Apply in that order.
4. Confirm the queue size with the user only if it exceeds 10 findings — large queues usually signal the MR has under-converged in earlier review rounds and a human should choose between landing-as-is, rebooting design, or proceeding.

## Step 3 — Classify each finding

For every finding in the queue, label it before applying:

| Label | Trigger | Action |
|---|---|---|
| **apply** | Reviewer suggests a concrete change inside the MR's logical scope. Includes "should we add X test", "rewrite this branch as Y", "rename this variable", "add this docstring", small algorithmic changes the reviewer literally suggests, error-variant additions, lint fixes. | Apply now. Don't defer. Don't propose tracking it elsewhere. |
| **apply-with-research** | Reviewer suggests a fix but the locus or shape isn't fully specified. Examples: "this might be wrong on Windows" (verify, then fix), "consider using X instead" (compare, pick, justify in the reply). | Resolve the underspecification by reading code / running grep / checking docs, then apply. |
| **strong-pushback** | One of: (a) reviewer asserts a fact about the codebase that grep / read disproves; (b) the requested change conflicts with another reviewer's request on the same locus; (c) the requested change would expand scope **outside** the MR's stated goal — in a way the MR description does not cover; (d) the requested change reverses a design decision made in a sister ADD or a prior approved MR. **Tightness ≠ scope expansion.** A reviewer asking for tighter validation, an extra test, or a stronger error message is *inside* scope by default. | Stop the loop, write the disagreement summary, ask the user. |

Notes on the heuristic:

- "Lenient toward peer reviews" means `apply` is the default classification. Reach for `strong-pushback` only when one of the four listed triggers actually fires.
- **Do not classify as `strong-pushback` because the fix is "out of MR scope" if the reviewer's framing of scope is broader than the MR description's.** That's a definitional dispute, not a strong pushback. Apply the fix and let the user adjudicate post-merge if they care.
- **Do not propose ticketing the work.** The user has explicitly disallowed this posture. If applying the fix is wrong, escalate as `strong-pushback`; if it's right, do it now.

## Step 4 — Apply fixes (apply / apply-with-research)

For each finding labelled `apply` or `apply-with-research`, in queue order:

1. **Read the anchored locus.** Open the file at the cited line via `Read`. Read enough surrounding context to apply the fix coherently — usually ±20 lines.
2. **Apply the change** via `Edit`. For multi-locus fixes, fix each locus before moving on; do not interleave with the next finding. Keep the change as narrow as the reviewer's request.
3. **Commit immediately** so each finding maps to one commit:
   ```bash
   git add <touched files>
   git commit -m "<TICKET>: REVIEW r<N> — <short description tied to the finding>"
   ```
   Replace `<TICKET>` with the ticket prefix from the branch name (e.g. `MADY-62`). If the branch has no ticket prefix, use the MR's title prefix instead. Stage files explicitly — never `git add .` or `git add -A` per the user's CLAUDE.md.
4. **Reply on the thread** referencing the commit:
   ```bash
   glab api --method POST \
     "projects/:fullpath/merge_requests/${MR_IID}/discussions/${DISCUSSION_ID}/notes" \
     -f "body=Applied in $(git rev-parse --short HEAD): <one-line summary>."
   ```
   For findings classified as `apply-with-research`, the reply must also state the choice that was made and why — e.g. *"Applied in <sha>: chose `BTreeMap` over the suggested `HashMap` for deterministic ordering across test runs."* The reviewer needs the reasoning, not just the SHA.

   **For mega-review threads** (multiple sub-findings under one discussion), post one reply note *per sub-finding* in the same thread, each citing its own commit SHA. Replies must always go through `discussions/${DISCUSSION_ID}/notes` — never post a standalone MR-level note via `merge_requests/${MR_IID}/notes`, which creates a "floating" comment unattached to any review thread and breaks the reviewer's mental model.
5. **Resolve the thread:**
   ```bash
   glab api --method PUT \
     "projects/:fullpath/merge_requests/${MR_IID}/discussions/${DISCUSSION_ID}?resolved=true"
   ```
   For mega-review threads, only resolve after the *last* sub-finding's reply has been posted.

If a finding requires touching code that another queued finding will also touch, fold them into one commit and reply on both threads with the same commit SHA. Do not split a single-locus rewrite into two commits.

For findings whose body suggests delegating to a subagent (large mechanical batches, cross-file refactors), dispatch a fresh `general-purpose` agent with the curated finding list and instruction to commit per finding using the format above. The subagent runs in the same working tree (no `isolation: worktree`) so commits land directly on the feature branch.

## Step 5 — Verify

After every batch of applies, run the verification gate:

1. **Project-specific verification script** if it exists. Look for, in order:
   - `scripts/verify-<TICKET>.sh` (per the `/deliver` convention; ephemeral)
   - `scripts/verify.sh`
   - `make verify` if a Makefile targets it
   
   Run whichever exists. Exit non-zero is a regression — return to Step 4 for that finding.
2. **Workspace checks** based on the project shape:
   - **Rust** (Cargo.toml at root): `cargo fmt --check`, then `cargo clippy --all-targets -- -D warnings`, then `cargo test`.
   - **Python** (pyproject.toml or requirements.txt): whatever the repo's CI runs — check `.gitlab-ci.yml` or `.github/workflows/` for the canonical command. Common shapes: `ruff check`, `mypy`, `pytest`.
   - **TypeScript / JS**: `package.json`'s `lint` and `test` scripts.
3. If a check fails on code you wrote, fix and amend the *current* commit (`git commit --amend --no-edit`) — don't ask for permission to amend a commit you just authored within this skill's run. The user's "never amend without asking" applies to commits that *predate* the skill invocation.

If `MAX_APPLY_ROUNDS` is exceeded (typically because a fix introduces a regression in another finding's locus), stop and surface the dependency to the user. Do not silently loop.

## Step 6 — Rebase against the upstream target

Before push, ensure the local branch is current against the upstream target.

1. `git fetch origin <TARGET>` (TARGET captured in Step 1, typically `master`).
2. Check divergence:
   ```bash
   git rev-list --left-right --count "origin/${TARGET}...HEAD"
   ```
   The output is `<behind> <ahead>`.
3. **If `behind == 0`:** no rebase needed. Proceed to push.
4. **If `behind > 0` and the branch's local commits are not yet pushed (or were pushed but no other reviewer has commits on top of yours):**
   ```bash
   git rebase "origin/${TARGET}"
   ```
   Resolve any conflicts — this is the kind of obstacle the user wants the skill to handle, not punt on. If conflicts exceed three loci or touch files you haven't edited in this run, stop and surface to the user — that's a tree-shape conflict deserving of human judgement.
5. **Push.** First-time push from this branch:
   ```bash
   git push --set-upstream origin "$BRANCH"
   ```
   Subsequent pushes after a rebase rewrite history; force is required:
   ```bash
   git push --force-with-lease
   ```
   `--force-with-lease` (not `--force`) is non-negotiable — it refuses if a teammate pushed to the same branch behind your back. Per the user's CLAUDE.md, **ask the user explicitly before any force-push**, even with `--force-with-lease`. The skill performs the rebase locally without prompting, but the user owns the push decision when history rewriting is involved.

## Step 7 — Final report

Post a concise summary to the user (not to the MR):

- MR IID, branch, target, base / head SHAs (before & after).
- Findings queue: total, applied, escalated.
- Per-finding: discussion ID prefix, severity, one-line outcome.
- Verification status: which checks ran, any regressions hit during apply.
- Rebase outcome: `clean` / `rebased` / `conflict-resolved`.
- Push outcome: `pushed` / `force-pushed (user approved)` / `unpushed (user declined)`.

If any threads were classified `strong-pushback`, list them with the disagreement summary so the user can post follow-up replies themselves — the skill does not post pushback replies on the user's behalf.

---

## Strong-pushback escalation format

When escalating, write the dispute concisely so the user can decide quickly. One block per finding:

```
[STRONG-PUSHBACK] discussion=<id-prefix-8>
  reviewer: <username>
  severity: <must-fix | should-fix | nit>
  reviewer wrote: <one-line gist>
  why pushback: <(a) factual error | (b) conflicts with finding X | (c) scope expansion | (d) reverses ADD decision>
  evidence: <grep result, file:line, ADD §, prior MR — concrete>
  proposed reply: <a draft reply the user can edit and post, or "user to draft">
```

Do not post the reply — the user owns the rebuttal.

---

## Failure modes to avoid

- **Defaulting to "let's track this in a follow-up ticket."** The user has banned this posture. Apply or escalate; never defer.
- **Dispatching a subagent for a single one-line fix.** Subagent overhead is for batches; small Edits stay in the orchestrator.
- **Rewriting beyond the reviewer's request.** "While I'm here" cleanups expand the diff, surface in re-review, and break attribution between commit and discussion thread.
- **Pushing without rebasing on a stale branch.** The user's instruction is explicit — always check upstream divergence before push.
- **Force-pushing without user approval.** Per CLAUDE.md. The rebase happens silently; the push does not.
- **Chaining commit + push.** Commit per finding lands as a sequence; the push is one user-gated action at the end.
- **Replying on a thread before the commit lands.** The reply cites a SHA — that SHA must already exist when the reply posts.
- **Resolving a thread the reviewer raised as a question, not a fix.** If the body is "is X intentional?" rather than "change X to Y", reply with the answer but do not auto-resolve. Resolution is the reviewer's call on those.
- **Posting replies as floating MR-level comments.** Always use `discussions/${DISCUSSION_ID}/notes` so the reply lives in the originating thread. A note posted via `merge_requests/${MR_IID}/notes` is unattached and breaks the reviewer's mental model — they expect to see "Applied in <sha>" right under their request, not as a stray top-level comment.
- **Conflating a mega-review thread into a single reply.** When one discussion contains multiple discrete findings, treat each as its own sub-finding: own commit, own reply in the same thread, resolve once after all sub-findings are addressed.
