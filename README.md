<div align="center">

# ⌨️ dotfiles

**One command. Same keyboard-driven setup on macOS, Ubuntu, Debian and Fedora.**

Tiling windows · a fast, good-looking terminal · Claude Code ready to go

[![CI](https://img.shields.io/github/actions/workflow/status/clarriu97/dotfiles/ci.yml?branch=master&style=for-the-badge&logo=githubactions&logoColor=white&label=CI)](https://github.com/clarriu97/dotfiles/actions/workflows/ci.yml)
[![macOS](https://img.shields.io/badge/macOS-13%E2%86%9227-000000?style=for-the-badge&logo=apple&logoColor=white)](#-macos)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%20%C2%B7%2024.04%20%C2%B7%2026.04-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](#-ubuntu--debian)
[![Debian](https://img.shields.io/badge/Debian-12-A81D33?style=for-the-badge&logo=debian&logoColor=white)](#-ubuntu--debian)
[![Fedora](https://img.shields.io/badge/Fedora-latest-51A2DA?style=for-the-badge&logo=fedora&logoColor=white)](#-fedora)

[![zsh](https://img.shields.io/badge/shell-zsh-89e051?style=flat-square&logo=gnubash&logoColor=white)](shell/.zshrc)
[![Tiling](https://img.shields.io/badge/tiling-i3%20%C2%B7%20AeroSpace-7aa2f7?style=flat-square)](#-window-manager-keys)
[![Theme](https://img.shields.io/badge/theme-Tokyo%20Night-bb9af7?style=flat-square)](terminal/)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-ready-D97757?style=flat-square&logo=anthropic&logoColor=white)](claude/README.md)
[![Tested in VMs](https://img.shields.io/badge/tested%20in-real%20macOS%20VMs-success?style=flat-square)](#-tested-before-it-touches-your-machine)
[![just](https://img.shields.io/badge/runner-just-f2b866?style=flat-square)](justfile)
[![License: MIT](https://img.shields.io/badge/license-MIT-yellow?style=flat-square)](LICENSE)

<img src="images/readme/macos-desktop.png" alt="macOS with AeroSpace: Ghostty, Brave and Finder tiled, workspaces in the menu bar" width="900">

</div>

---

## ✨ What you get

| | |
|---|---|
| 🪟 **Tiling windows** | Windows arrange themselves. Move, resize and switch workspaces from the keyboard. i3 on Linux, AeroSpace on macOS, **same keys on both**. |
| 🐚 **A terminal you'll like** | zsh + powerlevel10k prompt, smart `cd`, fuzzy search for files and history, colored `ls` and `cat`. Warp and Ghostty, Tokyo Night theme. |
| 🤖 **Claude Code** | CLI + Desktop installed and configured: safe defaults, status line, plugins, your personal rules. [Details](claude/README.md) |
| 🛟 **Safe to try** | Dry run first, everything it replaces is backed up, and there is a panic button that puts your Mac back to stock. |

## 🚀 Quick start

```bash
git clone https://github.com/clarriu97/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh --dry-run    # shows what would happen, changes nothing
./install.sh              # pick what to install
```

<img src="images/readme/installer.gif" alt="Installer in dry-run mode" width="800">

Pick only some parts, without questions:

```bash
./install.sh --yes --only terminal,claude
```

| Part | macOS | Linux |
|---|---|---|
| `terminal` | zsh, powerlevel10k, CLI tools, Warp + Ghostty, Nerd Font | same, with Warp |
| `apps` | VS Code, Brave, Raycast, Stats + Caffeine in the menu bar | VS Code, Brave |
| `wm` | AeroSpace tiling + window borders | i3 + polybar |
| `keyboard` | Left Option becomes the window-manager key | — |
| `desktop` | Dock auto-hide, Finder tweaks, fast key repeat | — |
| `claude` | Claude Code CLI + Desktop + config | CLI (+ Desktop on Ubuntu/Debian) |

## 💻 Install on your OS

### 🍎 macOS

Needs nothing but `git` (macOS asks to install it the first time you type `git`). Homebrew is installed for you.

```bash
tmutil localsnapshot      # optional: a restore point, just in case
./install.sh
```

macOS doesn't let scripts approve some permissions, so the installer **walks you through them**: it opens the right settings page, tells you which switch to turn on, and continues by itself when it's done. Step-by-step with screenshots: [guides/macos-permissions.md](guides/macos-permissions.md). Run it again any time with `dotfiles permissions`.

After a restart you get **Brave on workspace 1, Warp on 2, Claude on 3 and VS Code on 4**. The menu bar shows every workspace that has windows, next to Stats (CPU, RAM, disk) and Caffeine.

### 🐧 Ubuntu / Debian

```bash
sudo apt install -y git
git clone https://github.com/clarriu97/dotfiles ~/dotfiles && cd ~/dotfiles
./install.sh
```

Log out and pick **i3** on the login screen.

<img src="images/readme/linux-i3.gif" alt="i3 on Ubuntu" width="800">

### 🎩 Fedora

```bash
sudo dnf install -y git
git clone https://github.com/clarriu97/dotfiles ~/dotfiles && cd ~/dotfiles
./install.sh
```

Log out and pick **i3** on the login screen.

## ⌨️ Window manager keys

**Mod** = `Win` on Linux, **left** `Option` on macOS (same place on the keyboard). The **right** `Option` key still types `@ # | [ ] { }` on a Spanish keyboard.

| Do this | Press |
|---|---|
| Open a terminal | `Mod` + `Enter` |
| App launcher (rofi / Raycast) | `Mod` + `d` |
| Move focus | `Mod` + `j` `k` `l` `ñ` or arrows |
| Move the window | `Mod` + `Shift` + `j` `k` `l` `ñ` or arrows |
| Go to workspace 1–10 | `Mod` + `1` … `0` |
| Send window to workspace | `Mod` + `Shift` + `1` … `0` |
| Previous workspace | `Mod` + `Tab` |
| Fullscreen / floating | `Mod` + `f` / `Mod` + `Shift` + `Space` |
| Close window | `Mod` + `Shift` + `q` |
| Resize | `Mod` + `r`, then arrows, `Esc` to finish |
| Lock screen | `Mod` + `Shift` + `x` |

<details>
<summary>All keys, side by side</summary>

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
| Stacking / tabbed / toggle split | `Win`+`s` / `w` / `e` | `L⌥`+`s` / `w` / `e` |
| Close window | `Win`+`Shift`+`q` | `L⌥`+`Shift`+`q` |
| Resize mode (j/k/l/ñ, Esc) | `Win`+`r` | `L⌥`+`r` |
| Shrink / grow / balance | — | `L⌥`+`-` / `L⌥`+`+` / `L⌥`+`b` |
| Reload config | `Win`+`Shift`+`c` | `L⌥`+`Shift`+`c` |
| VS Code / Brave | `Win`+`Shift`+`v` / — | `L⌥`+`Shift`+`v` / `b` |
| Screenshot | `Win`+`Ctrl`+`s` (flameshot) | `L⌥`+`⌘`+`s` (to clipboard) |
| Home folder | `Win`+`Ctrl`+`e` | `L⌥`+`⌘`+`e` |
| Lock | `Win`+`Shift`+`x` | `L⌥`+`Shift`+`x` |

</details>

## 🐚 Terminal

<img src="images/readme/shell.gif" alt="Terminal tour: z, lsd, bat, fzf" width="800">

| Try this | What it does |
|---|---|
| `z weather` | Jump to a folder you visited before, typing only part of its name |
| `zi` | Same, but pick from a list |
| `..` | Go up one folder (no `cd` needed) |
| `cd -` | Back to the previous folder |
| `Ctrl` + `T` | Fuzzy-find a file and paste its path |
| `Ctrl` + `R` | Fuzzy-search your command history |
| `Alt` + `C` | Fuzzy-find a folder and go there |
| `Ctrl` + `←` / `→` | Jump word by word |

Handy aliases:

| Alias | Runs |
|---|---|
| `l` | `ls -al` with icons and colors (lsd) |
| `cat` | `bat`: syntax highlighting and line numbers |
| `gs` · `gd` · `ga` · `gp` | git status · diff · add · push the current branch |
| `gtree` | git log as a graph |
| `update` | update all packages (brew, apt or dnf) |
| `mkcd <dir>` | create a folder and go into it |
| `ss` | screenshot (clipboard on macOS, flameshot on Linux) |

Your own tweaks go in `~/.zshrc.local` (not versioned, loaded last).

## 🛟 The `dotfiles` command

```console
$ dotfiles doctor
PASS link ~/.zshrc
PASS command fzf
PASS zsh -i starts without errors (119 ms)
PASS AeroSpace running (focused workspace 1)
PASS Karabiner privileged daemon running
...
All checks passed, 0 warning(s)
```

| Command | What it does |
|---|---|
| `dotfiles doctor` | Checks that everything is installed and working |
| `dotfiles permissions` | Walks you through the macOS approvals again |
| `dotfiles rescue` | 🚨 Panic button: stock keyboard, windows back on screen, original macOS settings |
| `dotfiles uninstall` | Removes every link and puts your old files back |

No terminal at hand? Open **Dotfiles Rescue** from Spotlight: same as `dotfiles rescue`, works even if the keyboard setup is broken.

## 🔧 Make it yours

The configuration is **linked** from this repo: edit a file here and the change is live. Common tasks have a [`just`](https://github.com/casey/just) recipe:

```bash
just            # list recipes
just doctor     # health check
just lint       # shellcheck, zsh syntax, JSON, TOML
just test       # lint + unit tests
just karabiner  # after changing AeroSpace keys
just demos      # re-record the GIFs in this README
```

## 🧪 Tested before it touches your machine

Every change runs through:

- **Lint + unit tests** (shellcheck, bats) on Ubuntu and macOS.
- **Full installs** in fresh Ubuntu 22.04 / 24.04 / 26.04, Debian 12 and Fedora containers, and on GitHub's macOS 15 and 26 runners. A second run must change nothing.
- **Real macOS VMs** ([tart](https://github.com/cirruslabs/tart)) with real keystrokes and reboots: a Mac with no permissions approved, a Mac with everything approved, and a Mac that is already in use.

```bash
just test            # lint + unit tests
just test-linux      # full install in a container
just test-vm fresh   # macOS VM (Apple Silicon)
```

<details>
<summary>Repository layout</summary>

```
install.sh        the installer
bin/dotfiles      doctor · permissions · rescue · uninstall
lib/              installer code per OS
packages/         package lists (Brewfiles, apt, dnf)
shell/            .zshrc, prompt, plugins
terminal/         Ghostty and Warp
wm/               i3 + polybar (Linux), AeroSpace + Karabiner (macOS)
claude/           Claude Code config
guides/           step-by-step guides
demos/            scripts that record the README GIFs
tests/            lint, unit, containers, macOS VMs
```

</details>

## 📄 License

[MIT](LICENSE)
