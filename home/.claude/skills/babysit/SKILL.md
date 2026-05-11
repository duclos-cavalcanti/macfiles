---
description: One-pass MR babysit — UI-rebase if divergent, run /mr-reply if reviews are up, run /ci-failures on a broken pipeline, hit auto-merge if approved with green CI and no open threads.
allowed-tools: Bash(git *), Bash(glab *), Bash(jq *), Bash(python3 *), Bash(printenv *), Read, Skill
argument-hint: [mr-iid]
---

# Skill: babysit

A one-shot pass over the current branch's open MR:

1. **Rebase if divergent against target.** Hit GitLab's UI rebase via the API (server-side, no local force-push), then `git fetch && git reset --hard origin/$BRANCH` to mirror.
2. **Reply to reviews.** If the MR has any unresolved resolvable threads, invoke `/mr-reply`. Surface any `STRONG-PUSHBACK` or force-push prompt to the user and stop.
3. **Pipeline gate.** If the MR's latest pipeline is failed/canceled, invoke `/ci-failures` to investigate and surface findings; do not proceed to auto-merge. Pass-through on success / running / pending.
4. **Auto-merge when ready.** If the MR has at least one approval AND zero open resolvable threads (re-checked after `/mr-reply`), hit "merge when pipeline succeeds".

**Argument:** optional MR IID. If omitted, look up the open MR whose `source_branch` matches the current local branch.

**Bash invariants:** every snippet below assumes `set -euo pipefail` is in effect — start the skill body with that so transient `glab` failures (401, 404, network) abort cleanly instead of silently continuing on default values.

**JSON parsing convention:** parse `glab api` responses with `python3 -c 'import json; ...'` reading from a `/tmp/babysit-*.json` tempfile, **not** with `jq`. MR descriptions, note bodies, and discussion threads routinely carry literal newlines and other U+0000–U+001F control characters that break `jq`'s strict-mode parser (`Invalid string: control characters … must be escaped`). Python's `json` module is permissive about embedded control chars and produces identical-shape access. Boolean fields parse as Python `True`/`False`/`None`; wrap with `json.dumps(...)` when the bash comparison expects jq's `true`/`false`/`null` literal form. The single bash snippet below shows the canonical pattern; every Step uses it.

```bash
glab api "projects/:fullpath/merge_requests/${MR_IID}" > /tmp/babysit-mr.json
STATE=$(python3 -c 'import json; print(json.load(open("/tmp/babysit-mr.json"))["state"])')
MERGING=$(python3 -c 'import json; print(json.dumps(json.load(open("/tmp/babysit-mr.json")).get("merge_when_pipeline_succeeds")))')
# STATE  → "opened" / "merged" / "closed"     (string, compare with [ ... = "opened" ])
# MERGING → "true" / "false" / "null"          (jq-compatible literal, compare with [ ... = "true" ])
```

**Authorization scope:** the user's invocation of `/babysit` constitutes explicit authorization for the Step 5 `merge_when_pipeline_succeeds` PUT. The agent **must not** pause to re-ask before issuing that call — the skill's contract names auto-merge as the terminal step, and the invocation is the authorization. This satisfies auto-mode rule 5 in spirit: the user has already directed the agent to merge. **Harness layer is separate.** The Bash permission layer (in `~/.claude/settings.json`) is enforced independently of this clause; if `Bash(glab api --method PUT projects/:fullpath/merge_requests/*/merge:*)` is not allow-listed there, the call is intercepted regardless of skill text. Add that allow-rule once per machine; subsequent runs fire MWPS without prompting.

**Project preconditions** (b2b-api, verified):
- `reset_approvals_on_push=true` — Step 4's correctness depends on this. After `/mr-reply` pushes a fix, GitLab cancels both auto-merge AND existing approvals; Step 4 only re-enables auto-merge once reviewers re-approve, so reviewers always get a fresh look at fix-up commits before the merge train picks the MR back up. Porting this skill to a project where `reset_approvals_on_push=false` would silently merge code reviewers haven't seen — fix Step 4 first if you do that.
- `only_allow_merge_if_all_discussions_are_resolved=true` — informs the "review thread blocks but doesn't cancel auto-merge" reasoning between Steps 1 and 2.

---

## Step 1 — Discover the MR

```bash
set -euo pipefail

BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Working tree must be free of uncommitted *tracked* changes — Step 2's
# `git reset --hard` discards those. Untracked files (porcelain `??`)
# are allowed: `reset --hard` leaves them alone unless a tracked file
# being written collides with them. This is important when /deliver has
# left ephemeral artifacts in the tree:
#   - `<TICKET-ID>.md` at the repo root (the spec file)
#   - `scripts/verify-<ticket>.sh` (the verification script)
# Both are documented as "never committed; gitignored or untracked."
# If they're gitignored, porcelain doesn't list them. If they're plain
# untracked, the `^??` filter below tolerates them.
DIRTY_TRACKED=$(git status --porcelain | grep -v '^??' || true)
if [ -n "$DIRTY_TRACKED" ]; then
  echo "working tree has uncommitted tracked changes; commit or stash first"
  echo "$DIRTY_TRACKED"
  exit 1
fi

# Local branch must not have unpushed commits — those would be discarded
# by the reset --hard in Step 2 after a UI rebase.
git fetch origin "$BRANCH" 2>/dev/null || true
if git rev-parse --verify "origin/$BRANCH" >/dev/null 2>&1; then
  AHEAD=$(git rev-list --count "origin/$BRANCH..HEAD")
  [ "$AHEAD" = "0" ] || { echo "local branch has $AHEAD unpushed commit(s); push or discard before babysitting"; exit 1; }
fi

if [ -n "${ARG_MR_IID:-}" ]; then
  MR_IID="$ARG_MR_IID"
else
  glab mr list --source-branch "$BRANCH" --state opened --output json > /tmp/babysit-mrlist.json
  MR_IID=$(python3 -c 'import json; mrs=json.load(open("/tmp/babysit-mrlist.json")); print(mrs[0]["iid"] if mrs else "")')
  [ -n "$MR_IID" ] || { echo "no open MR for $BRANCH"; exit 1; }
fi

# State + target + auto-merge flag captured up-front so we never
# operate on a closed/merged MR or interfere with a merge train.
# Fetch once into /tmp and read fields with python3 — see the JSON
# parsing convention at the top of this file.
glab api "projects/:fullpath/merge_requests/${MR_IID}" > /tmp/babysit-mr.json
STATE=$(python3 -c 'import json; print(json.load(open("/tmp/babysit-mr.json"))["state"])')
TARGET=$(python3 -c 'import json; print(json.load(open("/tmp/babysit-mr.json"))["target_branch"])')
MERGING=$(python3 -c 'import json; print(json.dumps(json.load(open("/tmp/babysit-mr.json")).get("merge_when_pipeline_succeeds")))')

case "$STATE" in
  merged|closed) echo "MR !${MR_IID} is ${STATE} — nothing to do"; exit 0 ;;
  opened) ;;
  *) echo "unexpected MR state: $STATE"; exit 1 ;;
esac
```

`MERGING` flags "auto-merge already enabled" — i.e. a previous `/babysit` pass (or the user) hit "merge when pipeline succeeds" and the MR is now queued. **It does NOT bail the skill.** Step 2 short-circuits the rebase (the train serialises rebases for us), but Steps 3 and 4 still run because:

- A new reviewer thread does **not** auto-cancel `merge_when_pipeline_succeeds`. The flag persists and the train silently stalls behind the discussion-resolution gate (this project has `only_allow_merge_if_all_discussions_are_resolved=true`). If we don't run `/mr-reply`, the train waits forever.
- `/mr-reply`'s resulting push *will* cancel auto-merge (any push to the source branch does). That's expected — Step 4 re-enables auto-merge once the reply lands and `OPEN == 0` again.
- If no new threads exist (`OPEN == 0`), Step 3 is a no-op and Step 4's re-enable is also a no-op (`merge_when_pipeline_succeeds=true` is idempotent on an already-true MR).

## Step 2 — Rebase if divergent

```bash
# Skip rebase if the MR is already auto-merging — GitLab's merge train
# (or basic auto-merge) handles rebases serially, and re-rebasing here
# would cancel auto-merge or fight the train's serialisation.
if [ "$MERGING" = "true" ]; then
  echo "MR !${MR_IID} is already auto-merging — skipping rebase"
else
  glab api "projects/:fullpath/merge_requests/${MR_IID}?include_diverged_commits_count=true" \
    > /tmp/babysit-mr-divergence.json
  DIVERGED=$(python3 -c 'import json; print(json.load(open("/tmp/babysit-mr-divergence.json")).get("diverged_commits_count", 0))')

  if [ "$DIVERGED" -gt 0 ]; then
    glab mr rebase "${MR_IID}" >/dev/null  # PUT /merge_requests/:iid/rebase under the hood
    # Poll until rebase finishes (typically <30s). Note `rebase_in_progress`
    # is a JSON boolean → python3 emits "true"/"false" via json.dumps().
    for _ in $(seq 1 20); do
      sleep 3
      glab api "projects/:fullpath/merge_requests/${MR_IID}?include_rebase_in_progress=true" \
        > /tmp/babysit-mr-poll.json
      REBASE_DONE=$(python3 -c 'import json; print(json.dumps(json.load(open("/tmp/babysit-mr-poll.json")).get("rebase_in_progress")))')
      [ "$REBASE_DONE" = "false" ] && break
    done
    glab api "projects/:fullpath/merge_requests/${MR_IID}" > /tmp/babysit-mr-postrebase.json
    REBASE_ERR=$(python3 -c 'import json; print(json.load(open("/tmp/babysit-mr-postrebase.json")).get("merge_error") or "")')
    if [ -n "$REBASE_ERR" ]; then
      handle_rebase_conflict "$REBASE_ERR"
      exit 1
    fi
    git fetch origin "$BRANCH"
    git reset --hard "origin/$BRANCH"
  fi
fi
```

`reset --hard` is safe because Step 1 enforces both invariants: working tree is clean AND local has no unpushed commits ahead of `origin/$BRANCH`.

### Conflict handling — small attempt before surfacing

When the GitLab UI rebase reports `merge_error`, the remote branch is unchanged and the conflict has not been resolved. The skill makes a **small, bounded attempt** to characterise the conflict locally before surfacing — it does **not** auto-resolve.

```bash
handle_rebase_conflict() {
  local err="$1"
  echo "─── babysit: rebase conflict ───"
  echo "GitLab merge_error: $err"

  # Drop into a local rebase against the same target to enumerate
  # the conflicting paths. Working tree is clean by invariant.
  git fetch origin "$TARGET"
  if git rebase "origin/$TARGET" >/dev/null 2>&1; then
    # Local rebase succeeded where UI failed — likely transient
    # state on GitLab (e.g. stale ref). Push the local result.
    echo "local rebase clean; push it manually if you trust the diff:"
    echo "  git push --force-with-lease"
  else
    echo "conflicting paths:"
    git diff --name-only --diff-filter=U | sed 's/^/  /'
    git rebase --abort
    echo "local tree restored. Resolve in the foreground:"
    echo "  git fetch origin $TARGET && git rebase origin/$TARGET"
    echo "  # …resolve conflicts…"
    echo "  git rebase --continue && git push --force-with-lease"
  fi
  echo "─────────────────────────────────"
}
```

Posture: **enumerate, abort, surface** — never auto-resolve. The skill exits and the user picks it up in the foreground.

## Step 3 — Reply to reviews

```bash
count_open() {
  glab api "projects/:fullpath/merge_requests/${MR_IID}/discussions" --paginate \
    > /tmp/babysit-discussions.json
  python3 - <<'PY'
import json
data = json.load(open("/tmp/babysit-discussions.json"))
# A discussion is "open" if ANY of its resolvable notes is unresolved.
# Do NOT use `notes[-1].resolved == false`: GitLab appends non-resolvable
# system notes after a rebase (e.g. "changed this line in version 2 of
# the diff") with resolvable=false, resolved=null, which makes the
# last-note check falsely report a fully-resolved discussion as open.
open_count = sum(
    1 for d in data
    if any(n.get("resolvable") and not n.get("resolved") for n in d["notes"])
)
print(open_count)
PY
}

OPEN=$(count_open)
```

If `OPEN > 0`, **invoke `/mr-reply` via the Skill tool** (not as a shell command — `Skill(skill="mr-reply", args="$MR_IID")` from Claude's tool layer). The skill is idempotent: already-resolved threads are filtered out, so re-firing on a strong-pushback iteration is harmless.

After `/mr-reply` returns, inspect its outcome and propagate accordingly:

| `/mr-reply` outcome | This skill's action |
|---|---|
| Posted replies, all threads resolved, push succeeded | Continue to Step 4 (re-count open below). |
| Returned a `STRONG-PUSHBACK` block | Print the block to the user and `exit 1` — do not proceed to auto-merge. |
| Blocked asking for force-push approval | Print mr-reply's prompt to the user and `exit 1`. The user can approve manually in the foreground; a subsequent `/babysit` run will pick up from the now-pushed state. |
| Failed (verification gate, push error, etc.) | Print the error and `exit 1`. |

After mr-reply runs, **always re-count** before the pipeline gate / auto-merge — the post-reply state is what gates Step 4 and Step 5:

```bash
OPEN=$(count_open)
```

## Step 4 — Pipeline gate

After any push from Step 2 (rebase) or Step 3 (`/mr-reply`), the MR has a fresh pipeline. Before re-enabling auto-merge, ensure the latest pipeline isn't failed — otherwise we'd hand a broken MR to the merge train.

```bash
glab api "projects/:fullpath/merge_requests/${MR_IID}/pipelines" > /tmp/babysit-pipelines.json
PIPELINE_STATUS=$(python3 -c 'import json; ps=json.load(open("/tmp/babysit-pipelines.json")); print(ps[0]["status"] if ps else "none")')
PIPELINE_ID=$(python3 -c 'import json; ps=json.load(open("/tmp/babysit-pipelines.json")); print(ps[0]["id"] if ps else "")')

case "$PIPELINE_STATUS" in
  failed|canceled)
    echo "MR !${MR_IID} latest pipeline (${PIPELINE_ID}) is ${PIPELINE_STATUS}"
    # Delegate investigation to /ci-failures via the Skill tool.
    # /ci-failures recursively scans child pipelines and reports the
    # failing job(s); babysit surfaces those findings to the user
    # and exits without auto-merging.
    # Skill(skill="ci-failures", args="$PIPELINE_ID")
    exit 1
    ;;
  success|running|pending|created|preparing|manual|scheduled|none)
    # success    — green, ready for auto-merge in Step 5.
    # running/pending/created/preparing — auto-merge will gate on completion.
    # manual/scheduled — merge_when_pipeline_succeeds still respects these.
    # none — no pipeline yet; Step 5's API call will surface the issue.
    ;;
  *)
    echo "unexpected pipeline status: $PIPELINE_STATUS"
    exit 1
    ;;
esac
```

The pipeline check is unconditional on `MERGING` — even on an already-auto-merging MR, a failed pipeline means the train has stalled and someone (or a re-trigger) needs to act.

`/ci-failures` is read-only investigation; it does not push fixes. The user reviews its output and either fixes manually or re-triggers a transient failure. Either action lets the next `/babysit` pass continue.

## Step 5 — Auto-merge when green

```bash
APPROVED=$(glab api "projects/:fullpath/merge_requests/${MR_IID}/approvals" | jq '.approved')

if [ "$APPROVED" = "true" ] && [ "$OPEN" -eq 0 ]; then
  # GitLab requires an active pipeline for merge_when_pipeline_succeeds=true.
  # If no pipeline is running (e.g. CI was skipped on the latest push), the
  # call returns 405 / "Method Not Allowed" and the merge does not happen.
  # That's surfaced as a non-zero exit from glab; let it bubble up.
  glab api --method PUT "projects/:fullpath/merge_requests/${MR_IID}/merge" \
    -f "merge_when_pipeline_succeeds=true" \
    -f "should_remove_source_branch=true" >/dev/null
  echo "auto-merge enabled — MR is on the merge train"
  exit 0
fi
```

`should_remove_source_branch=true` is a deliberate default — drop the feature branch on merge. If the project policy requires retaining branches, override this skill in a fork or pass `false` via a future config knob.

---

## Caveat — `/mr-reply` force-push handshake

`/mr-reply`'s §6 stops and asks the user before any force-push (rebase aftermath, self-amend after a verification regression).

**This skill's posture:** if `/mr-reply` blocks on force-push, exit non-zero and surface to the user. The user can approve manually in the foreground session.

The Step 2 rebase here is **server-side via the UI button** — GitLab rewrites the remote, and the local `git reset --hard origin/$BRANCH` is a fast-forward, no force-push. So the force-push concern only fires inside `/mr-reply` when its verification gate triggers a self-amend.

---

## Failure modes to avoid

- **Hitting auto-merge with stale OPEN.** Always re-count `OPEN` after `/mr-reply` returns; do not reuse the pre-reply count.
- **Hitting auto-merge over a failed pipeline.** Step 4's gate prevents this — if the latest pipeline is `failed`/`canceled`, delegate to `/ci-failures` and exit. Auto-merge is only safe when CI is green or actively pending.
- **Trying to auto-fix CI breakages.** `/ci-failures` is read-only investigation; the user owns the actual fix or re-trigger.
- **Pulling mid-rebase.** Wait for `rebase_in_progress=false` before `git fetch`.
- **Local force-push.** Never. Server-side rebase + clean local mirror only.
- **Auto-resolving conflicts.** Enumerate, abort, surface — let the user decide.
- **Running on a dirty tree.** Step 1 invariant — bail before doing anything. *Tracked* dirtiness only; untracked files (e.g. `/deliver`'s spec + verify-script artifacts) are tolerated because `git reset --hard` doesn't touch them.
- **Discarding unpushed commits.** Step 1 invariant — bail if the local branch is ahead of origin.
- **Operating on a closed/merged MR.** Step 1 invariant — bail unless state is `opened`.
- **Rebasing while the MR is on the merge train.** Step 1 captures `merge_when_pipeline_succeeds`; Step 2 short-circuits when it's true. Re-rebasing would cancel auto-merge (basic case) or fight the train's serialisation (merge-train case).
- **Treating `invoke /mr-reply` as a shell command.** It is a Skill-tool invocation; the bash blocks here describe pre/post-conditions, not the dispatch itself.
- **Silent `glab` failures.** `set -euo pipefail` makes auth/network/HTTP errors stop the skill instead of poisoning downstream JSON parses.
