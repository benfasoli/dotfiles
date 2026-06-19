#!/usr/bin/env bash
#
# select-repos.sh — pick repos for a scheduled improve-docs pass.
#
# Scans local clones, fetches each, and emits one line per ELIGIBLE repo:
#
#     <repo-path>\t<base-branch>\t<base-sha>
#
# Eligible means: you authored a commit in it within the recency window AND it
# has no open docs/improve-* PR (so passes don't stack on the same repo). The
# emitted base-sha is freshly-fetched origin/<default-branch> — branch and
# document from that, never the possibly-stale working tree.
#
# Emits nothing (exit 0) when no repo qualifies; that is a successful no-op pass.
#
# Env overrides:
#   REPOS_DIR     directory of clones to scan      (default: ~/repos)
#   WINDOW        git --since recency window        (default: "2 weeks ago")
#   PR_PREFIX     branch prefix that marks a docs PR (default: docs/improve)

set -euo pipefail

REPOS_DIR="${REPOS_DIR:-$HOME/repos}"
WINDOW="${WINDOW:-2 weeks ago}"
PR_PREFIX="${PR_PREFIX:-docs/improve}"

log() { printf '%s\n' "$*" >&2; }

# Reuse one SSH connection across all fetches. A fresh handshake per repo trips GitHub's SSH
# connection rate limit (kex_exchange_identification: Connection reset by peer); multiplexing
# means a single handshake the rest ride on.
if [ -z "${GIT_SSH_COMMAND:-}" ]; then
  SSH_CM_DIR="$(mktemp -d)"
  trap 'rm -rf "$SSH_CM_DIR"' EXIT
  export GIT_SSH_COMMAND="ssh -o ControlMaster=auto -o ControlPersist=120 -o ControlPath=$SSH_CM_DIR/cm-%r@%h:%p"
fi

# Fetch with backoff; transient connection resets under load are common.
fetch_with_retry() {
  local d="$1" n=0
  until git -C "$d" fetch --quiet origin 2>/dev/null; do
    n=$((n + 1))
    [ "$n" -ge 3 ] && return 1
    sleep $((n * 2))
  done
}

[ -d "$REPOS_DIR" ] || { log "REPOS_DIR not found: $REPOS_DIR"; exit 0; }

emitted=0
for dir in "$REPOS_DIR"/*/; do
  dir="${dir%/}"
  git -C "$dir" rev-parse --git-dir >/dev/null 2>&1 || continue

  # Cheap LOCAL filter first — no network. Did you author anything here recently? Checks all
  # refs so unmerged local work counts. Running this before fetch is what keeps us from
  # hitting every clone at once and tripping GitHub's SSH connection rate limit; we only
  # fetch the handful of repos you've actually touched.
  email="$(git -C "$dir" config user.email 2>/dev/null || true)"
  [ -n "$email" ] || { log "skip (no user.email): $dir"; continue; }
  if [ -z "$(git -C "$dir" log --all --since="$WINDOW" --author="$email" --format=%H -n1 2>/dev/null)" ]; then
    continue
  fi

  # Recent work here — now hit the network, reusing the multiplexed SSH connection.
  fetch_with_retry "$dir" || { log "skip (fetch failed): $dir"; continue; }

  # Resolve the remote's default branch (set the ref if it's missing).
  default="$(git -C "$dir" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)"
  default="${default#origin/}"
  if [ -z "$default" ]; then
    git -C "$dir" remote set-head origin --auto >/dev/null 2>&1 || true
    default="$(git -C "$dir" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)"
    default="${default#origin/}"
  fi
  [ -n "$default" ] || { log "skip (no default branch): $dir"; continue; }

  # Don't stack: skip if an open docs PR already exists for this repo.
  open_docs_pr="$(
    (cd "$dir" && gh pr list --state open --json headRefName \
      --jq "[.[].headRefName | select(startswith(\"$PR_PREFIX\"))] | length") 2>/dev/null || echo 0
  )"
  if [ "${open_docs_pr:-0}" -gt 0 ]; then
    log "skip (open docs PR): $dir"
    continue
  fi

  base_sha="$(git -C "$dir" rev-parse "origin/$default" 2>/dev/null || true)"
  [ -n "$base_sha" ] || continue

  printf '%s\t%s\t%s\n' "$dir" "$default" "$base_sha"
  emitted=$((emitted + 1))
done

log "eligible repos: $emitted"
