# Claude Code setup

`./install.sh --only claude` installs and configures Claude Code the same way on macOS, Ubuntu/Debian and Fedora. The CLI and the Desktop app (Code tab) read the same `~/.claude/`, so everything below applies to both.

## What gets installed

| Piece | macOS | Ubuntu / Debian | Fedora |
|---|---|---|---|
| CLI | native installer (`~/.local/bin/claude`, auto-updates) | native installer | native installer |
| Desktop | `brew install --cask claude` | Anthropic apt repo (`claude-desktop`, beta) | not available yet, use the CLI |

A Homebrew `claude-code` cask, if present, is removed: two installs on `PATH` means the older one silently wins.

## What gets linked into `~/.claude/`

| File | Purpose |
|---|---|
| `CLAUDE.md` | Personal rules applied to every project |
| `settings.json` | Attribution off, permissions, hooks, status line, plugins |
| `statusline.sh` | `model · dir · branch · ctx % · 5h limit %`, turns yellow/red at 50/80 % |
| `hooks/guard-bash.sh` | Blocks `rm -rf /` or `~`, force pushes (use `--force-with-lease`), disk formatting, `csrutil disable` |
| `skills/catchup` | `/catchup`: rebuilds context on the current branch after `/clear` |
| `skills/handoff` | `/handoff`: writes an untracked `HANDOFF.md` before ending a session |

`settings.json` is a symlink into this repo. When you approve "always allow" or change `/config`, Claude writes through the link, so the change shows up in `git diff`: commit what you want to keep. Machine-specific settings go in `~/.claude/settings.local.json` (not versioned). The file is stored in the key order Claude writes, so installing plugins does not create a diff (CI checks this).

## Plugins enabled by default

| Plugin | How it is used | Example |
|---|---|---|
| `commit-commands` | You type the command | `/commit` after a change: stages, writes a Conventional Commit. `/commit-push-pr` opens the PR. `/clean_gone` deletes local branches already merged and gone on the remote |
| `pr-review-toolkit` | You type the command, or ask for a review | `/pr-review-toolkit:review-pr` before merging: specialised agents check tests, silent failures, comments, types and simplifications |
| `security-guidance` | Automatic (hook) | While Claude edits, it warns about risky patterns (shell injection, `eval`, secrets in code…) without being asked |
| `claude-md-management` | You type the command | `/revise-claude-md` at the end of a session: proposes updates to the repo's CLAUDE.md with what was learned |
| `context7` | Automatic (MCP tool), or ask for it | "How do I configure X in library Y? use context7": Claude reads the current docs of the version you use instead of guessing |

To add one: put `"name@claude-plugins-official": true` in `enabledPlugins` and re-run `./install.sh --only claude`.

`.env` files: `settings.json` denies the **Read** tool on `.env*`, so secrets never end up in the conversation. Commands still get the variables (`set -a; . ./.env; set +a; <command>` or a `just` recipe with `set dotenv-load`), because the deny only applies to reading the file into the context.

## Opt-in, per project

Enable these in the project's `.claude/settings.json` rather than globally, so they only load where they help:

- **Flutter app**: `dart-flutter` (already used in `1rm-mobile-app`), plus `swift-lsp` / `kotlin-lsp` when touching native code.
- **Web / landing page**: `typescript-lsp`, `frontend-design`, `playwright` (lets Claude drive a browser for end-to-end checks).
- **Larger features**: `feature-dev` (explore → design → implement workflow with dedicated agents).
- **Writing your own guardrails**: `hookify` turns "never do X again" into a hook.

## Workflow tips

- **Plan first on anything non-trivial**: plan mode (Shift+Tab) for a reviewed plan before edits; it fits the "think before coding" rule in `CLAUDE.md`.
- **One task per session**: `/clear` between unrelated tasks; `/handoff` before clearing, `/catchup` after.
- **Parallel work**: separate git worktrees (one per Desktop session) so sessions never edit the same checkout.
- **Review before you push**: built-in `/code-review` and `/security-review` on the diff.
- **Project memory**: `/init` once per repo for a project `CLAUDE.md`; keep it short and factual.
- **Verify, don't trust**: give Claude a command that proves the change (tests, `just doctor`), like this repo does.

## Security notes

- Prefer `gh auth login` (token kept in the macOS keychain) over tokens in plain `.env` files, and use fine-grained tokens limited to the repos you need.
- `settings.json` denies reading `.env*`, `~/.ssh`, `~/.aws` and `~/.gnupg` with the Read tool.
