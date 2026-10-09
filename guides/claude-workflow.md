# Developing with Claude Code and agent-skills

How to build software with this setup: [agent-skills](https://github.com/addyosmani/agent-skills) for the workflow, plan mode for reviewed plans, and the personal rules in [`claude/CLAUDE.md`](../claude/CLAUDE.md). Setup and updates are in [`claude/README.md`](../claude/README.md#agent-skills-vendored).

## How the pieces load

- **`CLAUDE.md`** is read in full in every session: your conventions and the behavioral guidelines always apply.
- **Skills** show only their name and description at startup. Claude opens a skill when your request matches its description, or when you run its command. That is why plain requests ("fix this typo") stay light, and bigger ones pull in a workflow.
- **Commands** (`/agent-skills:<name>`) force a workflow when you do not want to rely on triggering.

## The lifecycle

```
interview-me → /agent-skills:spec → /agent-skills:plan → /agent-skills:build → /agent-skills:review → /commit-push-pr
   (what)          (docs/specs/)        (tasks/, local)      (test → code → commit)   (five axes)
```

| Step | Prompt | What happens |
|---|---|---|
| Clarify | `I want X. Interview me first.` | `interview-me`: writes its hypothesis with a confidence %, then asks one question at a time (who, why, what success looks like, what constrains it) until ~95 % |
| Specify | `/agent-skills:spec` | Writes `docs/specs/YYYY-MM-DD-<slug>.md`: objective, commands, structure, code style, testing, boundaries (always / ask first / never). Waits for your OK |
| Plan | `/agent-skills:plan` | Plan mode, no edits. Writes `tasks/plan.md` and `tasks/todo.md`: vertical slices, each with acceptance criteria and a verification step |
| Build one task | `/agent-skills:build` | Next task: failing test → minimal code → full test suite → build → commit → mark done → stop |
| Build everything | `/agent-skills:build auto` | Same loop for every task after one approval; stops on failures or risky steps |
| Review | `/agent-skills:review` | Correctness, readability, architecture, security, performance; Critical / Important / Suggestion with `file:line` |
| Simplify | `/agent-skills:code-simplify` | Reduces complexity without changing behavior, running tests after each change |
| Guard the bar | `/agent-skills:constraints guard` | Flags a weakened bar in the diff: skipped tests, new suppressions, lowered thresholds, stubs |
| Ship | `/commit-push-pr`, then `/agent-skills:ship` for production | Opens the PR; `ship` runs code, security and test reviewers in parallel and gives a go/no-go with a rollback plan |

Specs are committed with the change and never rewritten after implementation: a later change gets a new spec and the old one is marked `superseded`. `tasks/` is scratch space, excluded from git.

## Worked example: CSV export in a Python project

```
I want to export the workout history to CSV. Interview me.
```
Claude: *"Hypothesis: you want to open it in a spreadsheet for your own charts. Confidence ~40 %. Who will read the CSV?"* A few questions later it knows: all sets, ISO dates, CLI only, no other users' data.

```
/agent-skills:spec
```
Creates `docs/specs/2026-10-09-csv-export.md` (`Status: draft`) and asks for approval.

```
/agent-skills:plan
```
`tasks/todo.md`:
1. Serialize one session to a CSV row. Verify: unit test.
2. `export --csv` command. Verify: CLI test.
3. Date range filter. Verify: test with an empty range.

```
/agent-skills:build auto
```
On `feat/csv-export`: three red-green cycles, `just check-task` after each, three commits (`feat(export): serialize session to CSV row`, …).

```
/agent-skills:review
/agent-skills:constraints guard
/commit-push-pr
```
The PR carries the code, the tests and the spec, which now says `Status: implemented`.

## Other everyday prompts

| Situation | Prompt | What triggers |
|---|---|---|
| Bug | `install.sh fails on Fedora 41 with "pkg_install: command not found". Reproduce it with a bats test before changing anything.` | `debugging-and-error-recovery` (reproduce, localize, reduce, fix, guard) and the Prove-It pattern: the test must fail first |
| Bug, explicit | `/agent-skills:test` + the bug description | Same, forced |
| Risky change | `I'm changing guard-bash.sh to block git reset --hard. Apply doubt-driven development before editing.` | `doubt-driven-development`: a fresh-context reviewer tries to break the decision before it stands |
| Library code | `Set up nested routes with go_router. Use source-driven development with context7 and cite the docs.` | `source-driven-development` + context7: decisions grounded in the docs for your version |
| Rough idea | `Refine this idea: a weekly summary of my training load.` | `idea-refine`: diverge into variants, then converge on one |
| New repo, no standards | `/agent-skills:constraints` | Up to four questions, `CONSTRAINTS.md`, and the checks as `just` recipes |
| Docs / decision | `Write an ADR for moving the API from REST to gRPC.` | `documentation-and-adrs` |
| Small or mechanical | `Rename foo to bar.` | Nothing: skills stay out of trivial work |
| Pause and resume | `/handoff` → `/clear` → `/catchup` | Your own skills, kept from before |

## Quality bar in a Python project

`/agent-skills:constraints` writes `CONSTRAINTS.md` and wires each rule to a tool. With the `CLAUDE.md` rule, the checks end up as `just` recipes and thresholds stay in `pyproject.toml`:

```toml
[tool.coverage.report]
fail_under = 85

[tool.ruff.lint]
select = ["E", "F", "I", "B", "S"]
```

```just
# Seconds, while editing
check-fast:
    uv run ruff check .
    uv run ruff format --check .
    uv run mypy src

# End of each task, under 90 s
check-task: check-fast
    uv run pytest --cov

# PR and CI
check-full: check-task
    gitleaks detect --redact
    uv run pip-audit
```

`/agent-skills:constraints guard` then looks for new `# noqa`, `# type: ignore`, `@pytest.mark.skip` / `xfail`, deleted assertions and a lowered `fail_under`.

## Tips

- Use the namespaced commands (`/agent-skills:plan`, `/agent-skills:review`) so they never clash with built-in ones.
- `/context` shows what the skill descriptions cost; the full skill text only loads when used.
- Built-in `/code-review` and `/security-review` still work on any diff, alongside `/agent-skills:review`.
