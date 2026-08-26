#!/usr/bin/env bash
# Close-session git health scan.
# Read-only: gathers branch/dirty/untracked/unpushed/merged/PR state plus a
# secret & private-key scan of everything not yet on the remote default branch.
# Prints labelled sections for the caller (Claude) to interpret. Never mutates.
set -uo pipefail

MAIN="${1:-}"
REMOTE="${2:-origin}"

section() { printf '\n=== %s ===\n' "$1"; }

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "STATUS: NOT_A_GIT_REPO"
  exit 0
fi

# --- resolve default branch ---
if [ -z "$MAIN" ]; then
  MAIN=$(git symbolic-ref --quiet --short "refs/remotes/$REMOTE/HEAD" 2>/dev/null | sed "s#^$REMOTE/##")
  [ -z "$MAIN" ] && { git show-ref --verify --quiet refs/heads/main && MAIN=main; }
  [ -z "$MAIN" ] && { git show-ref --verify --quiet refs/heads/master && MAIN=master; }
  [ -z "$MAIN" ] && MAIN=main
fi

BRANCH=$(git branch --show-current 2>/dev/null)
[ -z "$BRANCH" ] && BRANCH="(detached HEAD)"

section "OVERVIEW"
echo "BRANCH: $BRANCH"
echo "DEFAULT: $MAIN"
echo "REMOTE: $REMOTE"
if [ "$BRANCH" = "$MAIN" ]; then echo "ON_DEFAULT: yes"; else echo "ON_DEFAULT: no"; fi

# --- working tree ---
section "WORKING_TREE"
PORCELAIN=$(git status --porcelain 2>/dev/null)
if [ -z "$PORCELAIN" ]; then
  echo "CLEAN: yes"
else
  echo "CLEAN: no"
  echo "$PORCELAIN"
fi

# --- untracked files ---
section "UNTRACKED"
UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null)
if [ -z "$UNTRACKED" ]; then echo "(none)"; else echo "$UNTRACKED"; fi

# --- files whose NAME looks sensitive (tracked, staged, or untracked) ---
# Things that must not be forgotten in a worktree or committed by mistake:
# keys, certs, env files, credential dumps, keystores.
section "SUSPICIOUS_FILENAMES"
ALLFILES=$( { git ls-files 2>/dev/null; echo "$UNTRACKED"; } | sort -u )
SUSPECT=$(printf '%s\n' "$ALLFILES" | grep -Ei \
  '(^|/)(\.env($|\.)|id_rsa|id_dsa|id_ecdsa|id_ed25519)|\.(pem|key|p12|pfx|pkcs12|keystore|jks|asc|ppk)$|(^|/)(credentials|secrets?|service[-_]account.*\.json)|\.npmrc$|\.pypirc$' \
  2>/dev/null | grep -Eiv '\.(example|sample|template|dist)$|\.env\.(example|sample|template)' || true)
if [ -z "$SUSPECT" ]; then echo "(none)"; else
  echo "$SUSPECT"
  echo "-- note: verify each is gitignored & stored in a secret manager, not left in the worktree --"
fi

# --- upstream / unpushed ---
section "UNPUSHED"
UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)
if [ -n "$UPSTREAM" ]; then
  echo "UPSTREAM: $UPSTREAM"
  AHEAD=$(git rev-list --count "$UPSTREAM"..HEAD 2>/dev/null || echo "?")
  BEHIND=$(git rev-list --count HEAD.."$UPSTREAM" 2>/dev/null || echo "?")
  echo "AHEAD_OF_UPSTREAM: $AHEAD"
  echo "BEHIND_UPSTREAM: $BEHIND"
  [ "$AHEAD" != "0" ] && git log --oneline "$UPSTREAM"..HEAD 2>/dev/null
else
  CFG=$(git config "branch.$BRANCH.merge" 2>/dev/null || true)
  if [ -n "$CFG" ]; then
    echo "UPSTREAM: (configured as $CFG but the tracking ref is gone: remote branch likely deleted, see REMOTE_BRANCH)"
  else
    echo "UPSTREAM: (none: branch was never pushed)"
  fi
fi

# --- live remote check: does the branch still exist on the remote? ---
section "REMOTE_BRANCH"
if [ "$BRANCH" = "(detached HEAD)" ]; then
  echo "EXISTS_ON_REMOTE: n/a (detached HEAD)"
else
  LSR=$(git ls-remote --heads "$REMOTE" "refs/heads/$BRANCH" 2>/dev/null); LSRC=$?
  if [ "$LSRC" -ne 0 ]; then
    echo "EXISTS_ON_REMOTE: unknown (cannot reach $REMOTE)"
  elif [ -n "$LSR" ]; then
    echo "EXISTS_ON_REMOTE: yes (tip $(printf '%s' "$LSR" | cut -f1 | cut -c1-12))"
  else
    echo "EXISTS_ON_REMOTE: no (deleted on $REMOTE, or never pushed; PR merges often auto-delete the branch)"
  fi
fi

# --- relationship to default branch ---
section "VS_DEFAULT"
DEFREF=""
if git show-ref --verify --quiet "refs/remotes/$REMOTE/$MAIN"; then
  DEFREF="$REMOTE/$MAIN"
elif git show-ref --verify --quiet "refs/heads/$MAIN"; then
  DEFREF="$MAIN"
fi
if [ -z "$DEFREF" ]; then
  echo "DEFAULT_REF: (not found — cannot compare)"
else
  echo "DEFAULT_REF: $DEFREF"
  # live check: is the local view of the default branch current?
  LIVE_MAIN=$(git ls-remote "$REMOTE" "refs/heads/$MAIN" 2>/dev/null | cut -f1)
  LOCAL_MAIN=$(git rev-parse "$DEFREF" 2>/dev/null)
  if [ -z "$LIVE_MAIN" ]; then
    echo "LIVE_DEFAULT: unknown (cannot reach $REMOTE); the merged check below uses the local $DEFREF"
  elif [ "$LIVE_MAIN" = "$LOCAL_MAIN" ]; then
    echo "LIVE_DEFAULT: local $DEFREF matches the live remote tip"
  elif git cat-file -e "$LIVE_MAIN" 2>/dev/null && git merge-base --is-ancestor HEAD "$LIVE_MAIN" 2>/dev/null; then
    echo "LIVE_DEFAULT: local $DEFREF is stale, but HEAD IS an ancestor of the live $REMOTE/$MAIN tip: merged (fetch to update local view)"
  else
    echo "LIVE_DEFAULT: local $DEFREF is stale (live tip ${LIVE_MAIN}); the merged check below may be wrong until a fetch"
  fi
  UNMERGED=$(git rev-list --count "$DEFREF"..HEAD 2>/dev/null || echo "?")
  echo "COMMITS_NOT_IN_DEFAULT: $UNMERGED"
  if [ "$UNMERGED" = "0" ]; then
    echo "MERGED_INTO_DEFAULT: yes (HEAD is an ancestor of $DEFREF)"
  else
    # squash/rebase merges leave commits present-but-different; report cherry equivalence
    EQUIV=$(git cherry "$DEFREF" HEAD 2>/dev/null | grep -c '^-' || echo 0)
    TOTAL=$(git cherry "$DEFREF" HEAD 2>/dev/null | grep -c '^' || echo 0)
    echo "MERGED_INTO_DEFAULT: no"
    echo "  ($EQUIV of $TOTAL branch commits already have an equivalent in $DEFREF — high ratio can mean a squash-merge landed)"
    git log --oneline "$DEFREF"..HEAD 2>/dev/null
  fi
fi

# --- pull request state ---
section "PULL_REQUEST"
if command -v gh >/dev/null 2>&1; then
  PR=$(gh pr view "$BRANCH" --json number,state,mergedAt,url,title 2>/dev/null || true)
  if [ -n "$PR" ]; then
    echo "$PR"
  else
    echo "no PR found for branch $BRANCH (gh pr view returned nothing)"
  fi
else
  echo "gh not installed — cannot check PR state"
fi

# --- secret scan of the pending diff (uncommitted + unpushed) ---
section "SECRET_SCAN"
BASE="$DEFREF"
[ -z "$BASE" ] && BASE="$UPSTREAM"
if [ -n "$BASE" ]; then
  PENDING=$(git diff "$BASE"...HEAD 2>/dev/null; git diff HEAD 2>/dev/null)
else
  PENDING=$(git diff HEAD 2>/dev/null)
fi
# include untracked file contents (bounded)
while IFS= read -r f; do
  [ -z "$f" ] && continue
  if [ -f "$f" ] && [ "$(wc -c <"$f" 2>/dev/null || echo 0)" -lt 1000000 ]; then
    PENDING="$PENDING"$'\n'"$(sed 's/^/+/' "$f" 2>/dev/null)"
  fi
done <<< "$UNTRACKED"

PATTERNS='-----BEGIN [A-Z ]*PRIVATE KEY-----|AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|aws_secret_access_key|gh[pousr]_[A-Za-z0-9]{36,}|xox[baprs]-[A-Za-z0-9-]{10,}|-----BEGIN OPENSSH PRIVATE KEY-----|(secret|token|passwd|password|api[_-]?key|access[_-]?key)["'"'"' ]*[:=]["'"'"' ]*[A-Za-z0-9/+_.-]{12,}'
HITS=$(printf '%s\n' "$PENDING" | grep -nEi "$PATTERNS" 2>/dev/null | grep -v '^[0-9]*:-' | head -40 || true)
if [ -z "$HITS" ]; then
  echo "no obvious secrets in pending diff (patterns: private keys, AWS/GitHub/Slack tokens, key=value secrets)"
  echo "-- heuristic only; still eyeball the diff for anything sensitive --"
else
  echo "POSSIBLE SECRETS in added/pending lines:"
  echo "$HITS"
fi

echo
echo "STATUS: DONE"
