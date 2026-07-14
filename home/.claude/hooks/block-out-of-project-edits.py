#!/usr/bin/env python3
"""PreToolUse guard: block edits into a worktree's parent checkout.

Reads the hook payload on stdin. When the session root (CLAUDE_PROJECT_DIR) is a
git worktree — i.e. its path contains "/.claude/worktrees/" — this denies
Edit/Write/MultiEdit whose target resolves into the *parent checkout* (under the
repo root but outside every worktree). That is the specific footgun where edits
silently land in the main checkout instead of the worktree branch.

Everything else is allowed: if the session is not in a worktree the hook is a
no-op, and edits to sibling worktrees (other checkouts under
"/.claude/worktrees/"), sibling repos, multi-repo trees, or any other path
proceed untouched. Also fails open when the payload can't be parsed or
CLAUDE_PROJECT_DIR is unset.
"""

import json
import os
import sys

WORKTREE_MARKER = "/.claude/worktrees/"


def _under(child: str, parent: str) -> bool:
    parent = os.path.abspath(parent).rstrip("/") + "/"
    return (child + "/").startswith(parent)


def main() -> int:
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return 0  # can't parse -> don't block

    file_path = (data.get("tool_input") or {}).get("file_path", "")
    if not file_path:
        return 0

    proj = os.environ.get("CLAUDE_PROJECT_DIR")
    if not proj:
        return 0  # no session root to compare against -> don't block

    proj = os.path.abspath(proj)
    marker_idx = proj.find(WORKTREE_MARKER)
    if marker_idx == -1:
        return 0  # not a worktree session -> no parent-checkout trap to guard

    parent_repo = proj[:marker_idx]  # repo root that owns the worktree
    worktrees_root = parent_repo + WORKTREE_MARKER  # where this and all sibling worktrees live

    abs_path = file_path if os.path.isabs(file_path) else os.path.join(proj, file_path)
    abs_path = os.path.abspath(abs_path)

    # Only the parent checkout is off-limits: under the repo root, but in neither this
    # worktree nor a sibling worktree (those are legitimate separate branch checkouts).
    in_parent_checkout = (
        _under(abs_path, parent_repo) and not _under(abs_path, proj) and not _under(abs_path, worktrees_root)
    )
    if not in_parent_checkout:
        return 0

    reason = (
        f"Blocked: {abs_path} is in the parent checkout ({parent_repo}), but this "
        f"session is running in the worktree {proj}. Edits here would land on the "
        "main checkout instead of the worktree branch. Re-target the path under the "
        "worktree root and retry."
    )
    print(
        json.dumps(
            {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "deny",
                    "permissionDecisionReason": reason,
                }
            }
        )
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
