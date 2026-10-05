---
name: catchup
description: Rebuild context on the current branch after a /clear or a new session — what changed versus the base branch, what is uncommitted, and what is left to do.
disable-model-invocation: true
---

Current branch and status:

!`git status --short --branch`

Commits on this branch that are not on the base branch:

!`git log --oneline "$(git merge-base HEAD "$(git rev-parse --abbrev-ref origin/HEAD 2>/dev/null || echo origin/main)" 2>/dev/null || echo HEAD~10)"..HEAD`

Files changed versus the base branch:

!`git diff --stat "$(git merge-base HEAD "$(git rev-parse --abbrev-ref origin/HEAD 2>/dev/null || echo origin/main)" 2>/dev/null || echo HEAD~10)"`

Read the changed files that matter, and any HANDOFF.md at the repository root. Then summarize in a few lines: the goal of this branch, what is done, what is uncommitted, and the next concrete step. Do not change anything.
