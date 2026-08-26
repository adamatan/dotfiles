---
name: spawn
description: Spawn a Termic agent task to work on a GitHub issue. Use on "/spawn <issue-number>", or bare "/spawn" for the issue just discussed. Extra scope notes optional.
---

# /spawn <issue> [scope notes]

Spawn a Termic task to work the issue. A Termic task is a full interactive
Claude session in its own worktree, so it escapes the background-subagent
limits (secrets, deploys). Use it, not the Agent tool, for real issue work.

No issue number given? Take the issue the conversation just discussed, and name
it in your reply ("Spawning #162: ...") so a wrong guess is caught at once. If
no recent issue is clear, ask.

## Steps

1. **Read the issue.** `gh issue view <n>` is the spec.
2. **Write a brief to a file, never into `--prompt`.** Long `--prompt` briefs
   truncate on every termic-cli delivery path (arg and stdin: ~4.7KB arrives as
   its last ~100 bytes). Use a durable absolute path: `$CLAUDE_JOB_DIR/tmp/brief-<n>.md`
   in a background job, else any durable path. The brief holds:
   - Scope: "Run `gh issue view <n>` first; it is the spec", the milestone,
     the concrete work, and the user's extra scope notes.
   - Ground rules, always:
     - One PR against main when done. Never merge; Adam merges. Rebase onto
       origin/main before opening the PR (main moves).
     - No cloud mutations unless this brief says otherwise. Prepare exact
       commands for Adam to run via `!`.
     - The PR carries the docs update too: the log, the roadmap, and every
       other doc the change touches. Grep for the old name, flag, path or
       number and fix each stale reference; a doc that still describes the
       old behaviour is worse than a missing one. Docs are part of the work,
       not a follow-up.
     - Report back in the task when the PR is open.
3. **Create the task** (the binary is not on PATH):
   ```
   /Applications/Termic.app/Contents/MacOS/termic-cli --no-launch new "<repo>/<n> - <what it does>" --worktree --base main --agent claude --json
   ```
   `<repo>` is the current repo's directory name. Name it `<issue> - <what it does>`
   in plain words; Adam reads the sidebar. Never `is-NNN`.
4. **Hand over with a short pointer prompt** (send queues if the agent is mid-turn):
   ```
   termic-cli send <task> --prompt "Read /abs/path/brief-<n>.md and follow it. Scope: <one line>."
   ```
5. **Report back**: task id and name, and how to check on it:
   `termic-cli result <task>`, `status`, `diff`.
