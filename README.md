# Dotfiles — cross-platform dev environment (macOS · Ubuntu · Fedora)

[![CI](https://github.com/clarriu97/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/clarriu97/dotfiles/actions/workflows/ci.yml) [![OS: macOS](https://img.shields.io/badge/OS-macOS-black)](#) [![OS: Linux](https://img.shields.io/badge/OS-Linux-blue)](#) [![Tiling WM](https://img.shields.io/badge/tiling-i3%20%2F%20AeroSpace-brightgreen)](#) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](#)

![ScreenRecord](images/screenrecord.gif)

One installer for a consistent, keyboard-driven setup on **macOS, Ubuntu/Debian and Fedora**: zsh with powerlevel10k, Warp and Ghostty, i3-style tiling (i3 on Linux, AeroSpace on macOS) with the **same keys on both**, and Claude Code (CLI + Desktop) with a versioned configuration.

Everything is tested before it reaches a real machine: lint and unit tests, full installs in Linux containers and on macOS runners in CI, and end-to-end scenarios in disposable macOS VMs (see [Testing](#testing)).

---

## Install

```bash
git clone https://github.com/clarriu97/dotfiles
cd dotfiles
./install.sh --dry-run        # see exactly what would happen, changes nothing
./install.sh                  # interactive: pick components
```

Unattended: `./install.sh --yes --only terminal,claude`. Components:

| Component | macOS | Linux |
|---|---|---|
| `terminal` | zsh + p10k, CLI tools (fzf, zoxide, bat, lsd, ripgrep, fd…), Warp + Ghostty, Nerd Font | same, Warp |
| `apps` | VS Code, Brave, Raycast, Stats + Caffeine in the menu bar (started at login) | VS Code, Brave |
| `wm` | AeroSpace + JankyBorders; native menu bar kept, showing every occupied workspace | i3 + polybar |
| `keyboard` | Karabiner-Elements: Left Option = window-manager key | — |
| `desktop` | Dock auto-hide, Finder extensions/path bar, key repeat | — |
| `claude` | Claude Code CLI + Desktop + config ([details](claude/README.md)) | CLI (+ Desktop on Ubuntu/Debian) |

Configuration is **symlinked** from the repo (edit the repo, the change is live). Any file it replaces is backed up as `*.bak-<date>`. Machine-specific shell settings go in `~/.zshrc.local` (not versioned).

## Safety net (macOS)

The installer never hides the menu bar, never starts the window manager by itself, and every macOS setting it changes is recorded first.

| Command | What it does |
|---|---|
| `dotfiles doctor` | Health check of everything installed (PASS / WARN / FAIL) |
| `dotfiles rescue` | Stock keyboard (Karabiner "Plain" profile), AeroSpace stopped (windows come back on screen) and kept from starting, every macOS setting restored to its previous value |
| `dotfiles uninstall` | `rescue` + remove every link and restore the backed-up files. Apps stay installed |
| **Dotfiles Rescue** app | Same as `dotfiles rescue`, from Spotlight or a double click, without the keyboard layer or a terminal |

The Karabiner menu-bar icon switches to the **Plain** profile at any time, without a terminal.

**First run on a real Mac**: take a local snapshot first (`tmutil localsnapshot`), then go component by component: `--only terminal,claude`, then `--only wm` (approve AeroSpace under *Privacy & Security → Device Control and Data Access*, the macOS 27 name of Accessibility), then `--only keyboard` (approve Karabiner's *Privileged Daemons* under *Login Items & Extensions → Background App Activity*, its driver extension, and Karabiner-Core-Service under *Device Control and Data Access*). `dotfiles doctor` shows which approval is still missing. The installer walks you through each one (step-by-step guide with screenshots: [guides/macos-permissions.md](guides/macos-permissions.md)); run it again with `dotfiles permissions`.

---

## Window manager keys

The modifier is **Super/Win** on i3 and **LEFT Option** on macOS (same physical spot on a PC keyboard). On macOS the **RIGHT Option** key is untouched, so `@ # | [ ] { } \ ~` keep working like AltGr on Linux. Only the exact combinations below are taken; every other Left Option combination still types or reaches the terminal as Alt.

| Action | i3 (Linux) | AeroSpace (macOS) |
|---|---|---|
| Terminal (Warp) | `Win`+`Enter` | `L⌥`+`Enter` |
| Ghostty | — | `L⌥`+`Shift`+`Enter` |
| Launcher | `Win`+`d` (rofi) | `L⌥`+`d` (Raycast) |
| Focus | `Win`+`j/k/l/ñ`, arrows | `L⌥`+`j/k/l/ñ`, arrows |
| Move window | `Win`+`Shift`+`j/k/l/ñ`, arrows | `L⌥`+`Shift`+`j/k/l/ñ`, arrows |
| Workspace *n* / send window to *n* | `Win`+`n` / `Win`+`Shift`+`n` | `L⌥`+`n` / `L⌥`+`Shift`+`n` |
| Previous workspace | `Win`+`Tab` | `L⌥`+`Tab` |
| Workspace to other monitor | `Win`+`Ctrl`+`<` / `>` | `L⌥`+`⌘`+`j/ñ` or arrows |
| Fullscreen / floating | `Win`+`f` / `Win`+`Shift`+`Space` | `L⌥`+`f` / `L⌥`+`Shift`+`Space` |
| Stacking / tabbed / toggle split | `Win`+`s` / `w` / `e` | `L⌥`+`s` / `w` / `e` (accordion / tiles) |
| Close window | `Win`+`Shift`+`q` | `L⌥`+`Shift`+`q` |
| Resize mode (j/k/l/ñ, Esc) | `Win`+`r` | `L⌥`+`r` |
| Shrink / grow / balance | — | `L⌥`+`-` / `L⌥`+`+` / `L⌥`+`b` |
| Reload config | `Win`+`Shift`+`c` | `L⌥`+`Shift`+`c` |
| VS Code / Brave | `Win`+`Shift`+`v` / — | `L⌥`+`Shift`+`v` / `b` |
| Screenshot | `Win`+`Ctrl`+`s` (flameshot) | `L⌥`+`⌘`+`s` (to clipboard) |
| Home folder | `Win`+`Ctrl`+`e` | `L⌥`+`⌘`+`e` |
| Lock | `Win`+`Shift`+`x` | `L⌥`+`Shift`+`x` |

At login AeroSpace opens **Brave on 1, Warp on 2, Claude on 3 and VS Code on 4** and lands on workspace 1. Brave, Claude and VS Code always go to their workspace; Warp only at startup, so `L⌥`+`Enter` still opens a terminal where you are.

`$mod+Ctrl` on i3 becomes `L⌥`+`⌘` on macOS. Karabiner's rules are generated from `.aerospace.toml` (`wm/macos/karabiner/generate.sh`), and a test fails if they drift apart.

Spanish keyboard on macOS: the input source must be **Spanish - ISO** (System Settings → Keyboard → Text Input).

## Terminal keys and navigation

| Action | Linux | macOS (Warp / Ghostty) |
|---|---|---|
| Jump word | `Ctrl`+`←/→` | `Ctrl`+`←/→` (freed from Mission Control) |
| Line start / end | `Alt`+`←/→` | `⌘`+`←/→` |
| Fuzzy file / history / cd | `Ctrl`+`T` / `Ctrl`+`R` / `Alt`+`C` | same (`Alt` = Left Option in Ghostty) |
| Smart cd | `z <part of path>`, `zi` | same |
| cd without `cd`, recent dirs | `..`, `cd -<Tab>` | same |

## Aliases and functions

- `l` → `ls -al` (lsd) · `cat` → `bat` (`batcat` on Debian/Ubuntu)
- `gs` `gd` `ga` · `gp` → push current branch · `gtree` → log graph
- `update` (apt/dnf/brew) · `reload` · `mkcd <dir>` · `sizeof <path>` · `ss` (screenshot)

---

## Testing

| Command | What it covers | Where |
|---|---|---|
| `just lint` | shellcheck, zsh syntax, JSON, TOML, Claude settings schema, `i3 -C` | local, CI |
| `just test-unit` | bats: installer CLI and dry run, links, OS detection, Claude hook/status line, AeroSpace ↔ Karabiner consistency | local, CI (Ubuntu + macOS) |
| `just test-linux ubuntu:24.04` | unattended install as a sudo user in a fresh container, idempotency, `doctor` | local (Docker), CI: Ubuntu 22.04/24.04/26.04, Debian 12, Fedora |
| CI `macos-install` | every component on GitHub's macOS 26 and 15 runners, idempotency, `doctor` | CI |
| `just test-vm <scenario>` | disposable macOS 27 VMs ([tart](https://github.com/cirruslabs/tart)): real keystrokes, reboots, screenshots | local (Apple Silicon) |

VM scenarios (`tests/vm/scenarios/`):

- `smoke` — the harness itself: boot, desktop, Spanish ISO keystrokes.
- `fresh` — what once broke a real Mac: install everything with **no permission approved**, reboot, keyboard and desktop must be untouched; then `rescue` and `uninstall`.
- `golden` — permissions approved: `L⌥`+digits switch workspaces, `R⌥` still types `@ # |`, windows move, AeroSpace starts at login, `rescue` restores the stock keyboard.

```bash
tests/vm/vm.sh base             # once: vanilla macOS -> dotfiles-base
tests/vm/vm.sh golden           # once: install everything in dotfiles-golden
tests/vm/vm.sh approve          # once: approve permissions by hand in the VM window
just test-vm fresh              # from dotfiles-base
just test-vm golden golden
```

## Repository layout

```
install.sh              entry point (components, --dry-run, --yes, --only)
bin/dotfiles            doctor / rescue / uninstall
lib/                    common, detect, macos (+ defaults recorder), ubuntu, fedora, claude, rescue
packages/               Brewfiles per component, apt / dnf lists
shell/                  .zshrc + per-OS fragments, p10k, vendored plugins (Linux)
terminal/               Ghostty config, Warp theme
wm/linux/               i3, polybar
wm/macos/               AeroSpace (+ rescue config), Karabiner (generated)
claude/                 CLAUDE.md, settings, status line, hooks, skills
tests/                  lint, bats, verify (doctor), Linux containers, macOS VMs
```

## License

[MIT](LICENSE)
