---
name: unstack
description: Rebase a stacked feature branch onto master after the parent branch has been squash-merged. Drops the parent's now-redundant commits cleanly so the MR diff shows only this branch's own work.
argument-hint: [parent-branch]
allowed-tools: Bash(git *), Bash(glab *)
---

# Unstack

You are unstacking a *stacked branch* — a feature branch that was forked off another feature branch (not master directly) so the work could proceed in parallel before the parent landed. The parent has now squash-merged into master, and the stacked branch needs to be re-anchored on master so its MR diff shows only its own commits.

## The shape of the problem

When the parent squash-merges, master gets **one** new commit that contains all of the parent's work. The stacked branch still has the parent's **N individual commits** in its history. A naïve `git rebase master` walks the N+M commits ahead of master, replays each one — and either no-ops (if git can detect the patch is already in master, which is unreliable) or conflicts messily on each parent commit.

The fix is `git rebase --onto origin/master <REBASE_BASE>` where `REBASE_BASE` is the **last parent-ticket commit in HEAD's history** — i.e. the actual fork point on this branch. That tells git "replay only the commits *after* `REBASE_BASE` onto master," dropping the now-redundant parent commits.

## Three distinct SHAs the skill needs to keep straight

The naming is sloppy if you don't pin them down. The skill identifies all three:

| Concept | What it is | Where it lives | How the skill finds it |
|---|---|---|---|
| **Parent branch name** | The label of the branch this one was forked off (e.g. `feature/MADY-282-...`). Used for documentation, the MR retarget step, and to derive the parent ticket pattern. | Local + sometimes remote (often deleted after merge). | MR's `target_branch` (preferred) or user argument. |
| **Squash commit on master** | The single commit on master whose subject references the parent ticket. **The skill's gate that the parent landed — its presence is sufficient evidence to proceed. Still NOT the rebase base.** | `origin/master`. | `git log origin/master --grep='<PARENT_TICKET>' --oneline`. |
| **Local rebase base** | The last commit in HEAD's history whose subject references the parent ticket. **This is what `git rebase --onto` actually consumes.** | HEAD's history. | `git log master..HEAD --grep='<PARENT_TICKET>' --format='%H %s' \| head -1`. |

Mixing up the squash commit (on master) with the local rebase base (on HEAD) is the silent failure mode of hand-rolling this. They share a ticket pattern but are different SHAs containing the same patch content.

## Argument

Optional `<parent-branch>` — the branch this one was forked off (e.g. `feature/MADY-282-signing-service-per-identity`). If omitted, try to detect it; fall back to asking the user.

## Steps

1. **Pre-flight.**
   - Confirm we're in a git repo: `git rev-parse --is-inside-work-tree`.
   - Get current branch: `BRANCH=$(git rev-parse --abbrev-ref HEAD)`. Abort if it's the default branch (`git symbolic-ref refs/remotes/origin/HEAD | sed 's|refs/remotes/origin/||'`).
   - Confirm working tree is clean: `git status --porcelain` empty. If dirty, abort and tell the user to commit or stash first — rebase on a dirty tree is a footgun.
   - `git fetch origin --prune` to make sure `origin/master` and other remote refs are current.

2. **Identify the parent branch name.** Detection order:
   1. **Explicit argument** — if the user passed `<parent-branch>`, use it.
   2. **Open MR's `target_branch`** — *authoritative when an MR exists.* `glab mr list --source-branch ${BRANCH} --state opened --output json | jq -r '.[0].target_branch // empty'`. If non-empty and not the default branch, that's the parent. A stacked branch's MR targets the parent precisely so reviewers see only this branch's diff, so the field is correct by construction.
   3. **Fallback prompt** — if no MR is open (the stack hasn't been published yet), ask the user. Optional hint: `git log --oneline master..HEAD --first-parent | tail -5` may show ticket IDs in commit subjects.

   Save: `PARENT_BRANCH` (the label) and `PARENT_TICKET` (extract from the branch name — e.g. `feature/MADY-282-foo` → `MADY-282`). The skill's grep patterns key off `PARENT_TICKET`.

3. **Find the squash commit on `origin/master` — this is the gate that the parent landed.**

   ```
   git log origin/master --grep="${PARENT_TICKET}" --oneline | head -3
   ```

   Expected: at least one commit on master whose subject starts with the parent's ticket (e.g. `MADY-282: SigningService port reshape — per-identity KeyAlias parameter (!138)`). The topmost match is the squash. Show the user; if zero matches, abort — the parent hasn't merged yet, or the merge used a different message convention.

   **Why this is the gate, not a per-commit `git cherry` check.** When a parent squash-merges, the N parent commits collapse into a single commit on master with a *new cumulative* patch-id. The N original patch-ids never appear on master. So `git cherry` (which matches per-commit patch-id) reports `+` for each of the N — even though their content is plainly in master under the squash. The squash commit's existence on master is the only reliable signal for squash-merge workflows. (See step 5 for the rebase-merge fallback.)

4. **Find the local rebase base — the last parent-ticket commit in HEAD's history.** **This is the SHA the rebase actually consumes.**

   ```
   git log master..HEAD --grep="${PARENT_TICKET}" --format='%H %s' | head -1
   ```

   The topmost result's SHA is `REBASE_BASE`. Every commit *after* `REBASE_BASE` in HEAD is this branch's own work; everything at-or-before is parent-ticket work that has been squashed into master.

   This step is what protects against the common footgun: using a parent branch ref (`refs/heads/<parent>` or `origin/<parent>`) directly. Local refs go stale when the parent branch keeps moving on its own worktree after this branch was forked. The "last parent-ticket commit in our history" is always correct because it's read from HEAD's actual ancestry, not from a tracked branch ref.

5. **(Optional) Rebase-merge fallback validation.** *Skip if the team uses squash-merge — step 3's squash detection is already the gate.* If the parent landed via rebase-merge or cherry-pick instead of squash, each parent commit's individual patch-id appears on master under a different SHA. To confirm:

   ```
   git cherry origin/master ${REBASE_BASE}
   ```

   For rebase-merge: every line should start with `-` (per-commit patch-id matches master under a different SHA).

   For squash-merge: every line will start with `+` — *this is expected and not a failure*, because squash collapses N patch-ids into one cumulative patch-id that the per-commit comparison cannot see. Step 3 has already gated this case via the squash-commit lookup.

   Mixed results (some `-`, some `+`) on a non-squash workflow: a parent commit hasn't landed. Abort.

6. **Detect already-unstacked state.**
   - `BASE=$(git merge-base origin/master HEAD)`.
   - If `BASE == $(git rev-parse origin/master)`, the branch is already anchored on master — nothing to do. Exit clean.

7. **Preview the rebase.** Show the user:
   - The exact command: `git rebase --onto origin/master ${REBASE_BASE}`.
   - The squash commit(s) on master from step 3 — *"this is what landed in master."*
   - The commits that will be **replayed**: `git log --oneline ${REBASE_BASE}..HEAD` — should all be this branch's own work, no parent-ticket subjects.
   - The commits that will be **dropped**: `git log --oneline master..${REBASE_BASE}` — parent's commits, now redundant.
   - Reminder: this rewrites history. The next `git push` requires `--force-with-lease`.

   Get explicit user confirmation before proceeding.

8. **Run the rebase.**
   - `git rebase --onto origin/master ${REBASE_BASE}`.
   - If conflicts: stop. Tell the user what file(s) conflict and how to abort (`git rebase --abort`) or continue (`git rebase --continue` after resolving). Do **not** auto-resolve conflicts.
   - If clean: report `git rev-list --count origin/master..HEAD` — should equal the count of replayed commits from step 7.

9. **Post-rebase verification.**
   - Run any local fast checks the project provides — for Rust workspaces this is typically `cargo fmt --check` and `cargo clippy -- -D warnings`. If a `scripts/verify-*.sh` exists for the active ticket, suggest running it.
   - Do **not** auto-push. Tell the user the push command they'll need: `git push --force-with-lease origin <branch>`. Per project convention, separate commit/push from rebase — let the user verify locally first.

10. **Retarget the MR (if it exists).**
    - Detect the open MR for the branch: `glab mr list --source-branch <branch> --state opened --output json | jq '.[0].iid'`.
    - If an MR exists and its `target_branch` is `${PARENT_BRANCH}`, suggest:
      ```
      glab mr update <iid> --target-branch master
      ```
    - If no MR exists yet, just remind the user that when they create the MR (e.g. via `/create-mr`), the target should now be `master`, not `${PARENT_BRANCH}`.

## What this skill does NOT do

- **Does not push.** Per project convention, separate commit/push — the user pushes after they verify locally.
- **Does not force-push silently.** When they're ready, `--force-with-lease` is the safe form.
- **Does not auto-resolve conflicts.** Conflicts during the rebase are surfaced to the user with the abort command handy.
- **Does not delete the parent branch locally.** That's a separate `/clean worktrees` concern.

## Recovery

If the rebase goes sideways, `git rebase --abort` puts the branch back exactly where it was. If the user has already force-pushed and regrets it, `git reflog` shows the pre-rebase HEAD and `git reset --hard <reflog-sha>` restores it (then re-push). Tell them this if asked, but don't preemptively run `--abort` without permission.

## Common variations

- **Parent branch deleted from origin after merge** (`force_remove_source_branch: true` in the MR settings). Common — and the skill handles it. The local ref usually still exists; step 3's resolution falls through to it. If the local ref is also gone, ask the user for the parent's last-known SHA and use that as `PARENT_BASE`.
- **Local parent ref is stale** (the parent branch had review iterations on its own worktree after this branch was forked, but the local ref here never followed). Step 4 side-steps this by deriving `REBASE_BASE` from HEAD's own ancestry (last parent-ticket commit in `master..HEAD`), not from a branch ref. The branch name is only used for the MR-retarget step.
- **Multiple stacked layers.** If branch C is stacked on B which is stacked on A, and only A has merged, this skill rebases C onto B (B is now A-free). Then B-merge-and-rebase happens separately, then C rebases onto master. Don't try to flatten the whole stack in one go.

- **Why `git cherry` doesn't help with squash merges.** `git cherry` matches commits by *individual* patch-id. A squash merge collapses N patch-ids into one new cumulative patch-id, so the originals never appear on master. The skill therefore uses step 3's squash-commit-on-master lookup as the gate, with step 5's `git cherry` retained only as an optional fallback for rebase-merge workflows.
