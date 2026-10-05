---
name: handoff
description: Write HANDOFF.md before ending a session or running /clear, so the next session (or /catchup) can continue without re-discovering context.
disable-model-invocation: true
---

Write `HANDOFF.md` at the repository root (create or overwrite) with these sections, keeping it short and factual:

- **Goal** — what this work is for, one or two lines.
- **Done** — what is finished and verified, and how it was verified.
- **In progress** — what is half-done, with file paths.
- **Next steps** — concrete, ordered.
- **Gotchas** — dead ends already tried, decisions made and why, commands that matter.

Make sure `HANDOFF.md` is ignored by git (add it to `.git/info/exclude` if the repository does not already ignore it). Do not commit it.
