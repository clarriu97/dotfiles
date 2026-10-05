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

| Plugin | Why |
|---|---|
| `commit-commands` | `/commit`, `/commit-push-pr`, `/clean_gone` |
| `pr-review-toolkit` | Specialised review agents (tests, error handling, types, comments) |
| `security-guidance` | Warns on insecure patterns while Claude edits |
| `claude-md-management` | Audits CLAUDE.md files and captures session learnings |
| `context7` | Up-to-date library docs over MCP, so answers match the version you use |

To add one: put `"name@claude-plugins-official": true` in `enabledPlugins` and re-run `./install.sh --only claude`.

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
- **Verify, don't trust**: give Claude a command that proves the change (tests, `make doctor`), like this repo does.

## Security notes

- Prefer `gh auth login` (token kept in the macOS keychain) over tokens in plain `.env` files, and use fine-grained tokens limited to the repos you need.
- `settings.json` denies reading `.env*`, `~/.ssh`, `~/.aws` and `~/.gnupg` with the Read tool.
