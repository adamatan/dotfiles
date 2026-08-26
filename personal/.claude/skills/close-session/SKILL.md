---
name: close-session
description: End-of-session close-out checklist for a work branch. Verifies git health (uncommitted work, unpushed commits, whether the branch merged into the default branch, PR state, forgotten private keys or secrets in the worktree, secrets committed by mistake), confirms documentation was written and existing docs updated to match the work, and surfaces open questions, undecided calls, and anything to hand off to another agent or person. Use when the user says "close session", "close out", "wrap up", "am I done here", "safe to leave this branch", "end of session", or is finishing work on a branch and wants a clean-desk check before walking away.
---

# /close-session — Clean-desk check before leaving a branch

Goal: make it safe to walk away. Catch the things a tired engineer forgets — work
that was never committed, a private key left in the worktree, a doc that now lies,
a decision nobody wrote down. Report findings; only change things the user approves.

Work the three areas in order. Give a short verdict per area, then one overall
**SAFE TO CLOSE** / **NOT YET** line at the end.

**SAFE TO CLOSE means the work has landed.** A branch whose PR is still open —
however clean, pushed and mergeable — is **NOT YET**: the blocker is "PR #N not
merged". Un-merged work is the thing most likely to rot, conflict, or be
forgotten; a clean worktree does not make it safe.

## 1. Git health

Run the scan (read-only, never mutates):

```bash
bash ~/.claude/skills/close-session/scripts/git_health.sh [default-branch] [remote]
# defaults: default-branch auto-detected, remote=origin
```

Read the labelled sections and judge each:

- **WORKING_TREE** — `CLEAN: no` means uncommitted work. Show the files. Decide with
  the user: commit, stash, or discard. This is the #1 cause of "my work vanished."
- **UNTRACKED** — new files git isn't tracking. Are any of them work that should be
  committed? Or junk that should be gitignored / deleted?
- **SUSPICIOUS_FILENAMES** — keys, certs, `.env`, credential dumps, keystores. For each:
  confirm it is gitignored, and that the real secret lives in a secret manager (SSM,
  1Password, etc.) — **not** left only in this worktree where it dies with the machine.
  A private key that exists nowhere else is a data-loss risk; move it somewhere durable.
- **UNPUSHED** — commits not on the remote. If the branch has value, push it (allowed
  without asking per the user's git rules) so the work survives. `UPSTREAM: (none)` on a
  branch worth keeping → push it. An upstream marked "gone" is not "never pushed":
  check REMOTE_BRANCH.
- **REMOTE_BRANCH** — live `ls-remote` check: does the branch still exist on the remote?
  `no` alongside a merged PR is normal (GitHub auto-deletes merged branches) and means
  the local branch is safe to delete. `no` with an open PR or unmerged commits means the
  work has no remote copy: push it.
- **VS_DEFAULT** — `MERGED_INTO_DEFAULT: yes` → work landed; the branch is safe to leave
  or delete. `no` with a high cherry-equivalence ratio usually means a squash-merge
  already landed (common with PR merges) — confirm via PR state before worrying.
  `LIVE_DEFAULT` compares the local default ref with the remote tip: when it says the
  local view is stale, trust it (and the PR state) over `MERGED_INTO_DEFAULT`, and
  fetch before re-judging.
- **PULL_REQUEST** — merged PR + landed commits = done. Open PR = **NOT YET**; say so,
  note review state, and offer to merge it now (if the user says yes, merge, then
  `git pull --ff-only` local main). No PR on unmerged work → **NOT YET**: nothing is
  tracking this change; offer to open one.
- **SECRET_SCAN** — any `POSSIBLE SECRETS` hit: inspect the exact line. A real secret in
  a commit means **stop** — it must be scrubbed from history (not just deleted in a new
  commit) and the credential rotated. Treat this as the highest-severity finding.

If a PR merged and local `main` isn't updated, remember the standing rule to
`git pull --ff-only` local main after a merge.

## 2. Documentation

The work is not done until the docs match reality. Check, in the repo's own terms:

- **New behaviour, new docs?** New feature/flag/endpoint/command → is it written down
  where a reader would look (README, module docs, CLAUDE.md, roadmap, issue)?
- **Changed behaviour, changed docs?** Grep for the old name/flag/path/number the work
  touched and confirm no doc still describes the old behaviour. A stale doc is worse than
  a missing one — it actively misleads.
- **Decisions worth keeping** — non-obvious choices, tradeoffs, gotchas discovered this
  session. Do they belong in a durable note (project docs, or memory per the memory
  guidance) rather than dying with the conversation?

List concretely what is documented, what is stale, and what is missing. Offer to fix
the gaps; don't silently rewrite docs.

## 3. Open questions & handoffs

Surface anything unfinished so it isn't lost:

- **Open questions** — anything you or the user left unanswered, assumptions made under
  uncertainty, "we'll confirm later" items.
- **Undecided calls** — decisions deferred or made provisionally that someone should ratify.
- **Handoffs** — work that belongs to another agent, person, or a later session: follow-up
  issues to file, a deploy to run, a review to request, a background task still running.
- **TODOs / task list** — reconcile against any TaskList and TODO/FIXME markers added this
  session. Anything still `in_progress` or pending?

Propose filing the durable ones as issues (there is an `/issue` skill) or memory notes so
they outlive the session.

## Output

End with a compact summary:

```
Git:   <one line>   e.g. "clean, merged via PR #61, nothing unpushed"
Docs:  <one line>   e.g. "roadmap updated; SKILL.md still names old flag — needs fix"
Open:  <one line>   e.g. "1 handoff: deploy branch on the box (IS-63)"

VERDICT: SAFE TO CLOSE  |  NOT YET — <blocker>
```

SAFE TO CLOSE only when all of: tree clean, nothing unpushed, no secrets, the
branch's PR merged (or the branch merged into the default branch some other way),
docs current. Anything else is NOT YET with the blocker named — an open PR is a
blocker, not a note.

Keep it terse. The point is a fast, honest clean-desk check, not a report.
