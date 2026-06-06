# Dotfiles — cross-platform dev environment (macOS · Ubuntu · Fedora)

[![OS: macOS](https://img.shields.io/badge/OS-macOS-black)](#) [![OS: Linux](https://img.shields.io/badge/OS-Linux-blue)](#) [![Tiling WM](https://img.shields.io/badge/tiling-i3%20%2F%20AeroSpace-brightgreen)](#) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](#)

![ScreenRecord](images/screenrecord.gif)

One script to set up a consistent dev environment on **macOS, Ubuntu and Fedora**:
**ZSH** (with [powerlevel10k](https://github.com/romkatv/powerlevel10k) and plugins),
[Warp](https://www.warp.dev/) as the terminal, a **tiling window manager** and a **status bar**.

The installer **auto-detects the operating system** and links the configuration via
*symlinks* (backing up any previous file), so editing the repo updates your config live.

---

## Cross-system equivalents

| Component          | Linux (Ubuntu/Fedora)      | macOS                         |
|--------------------|----------------------------|-------------------------------|
| Window manager     | [i3wm](https://i3wm.org/)  | [AeroSpace](https://github.com/nikitabobko/AeroSpace) (i3-like, no SIP disable) |
| Status bar         | [polybar](https://github.com/polybar/polybar) | [SketchyBar](https://github.com/FelixKratz/SketchyBar) |
| Package manager    | apt / dnf                  | [Homebrew](https://brew.sh) (`Brewfile`) |
| Terminal           | Warp                       | Warp                          |
| Prompt             | ZSH + powerlevel10k        | ZSH + powerlevel10k           |
| Clipboard          | xclip                      | pbcopy/pbpaste                |
| Screenshots        | flameshot                  | flameshot                     |
| IDE                | VS Code                    | VS Code                       |
| Browser            | Brave                      | Brave                         |
| AI agents          | Claude CLI & opencode      | Claude CLI & opencode         |

---

## Repository layout

```
install.sh            # entrypoint: detects OS + arch and links the config
lib/                  # modules: common, detect, ubuntu, fedora, macos, linux-common
packages/             # declarative lists: Brewfile, apt-*.txt, dnf-*.txt
shell/                # .zshrc (common) + zshrc.{linux,macos}.sh fragments + .p10k.zsh + plugins
wm/
  linux/              # i3 (+ scripts/lock) and polybar
  macos/              # aerospace/.aerospace.toml and sketchybar/
docs/manual-bringup.md  # step-by-step guide for macOS
```

---

## Installation

```bash
git clone https://github.com/clarriu97/dotfiles
cd dotfiles
./install.sh                 # auto-detects the OS
# ./install.sh --os ubuntu   # to force a specific OS
```

You can clone the repo **anywhere** — `install.sh` resolves its own location and
creates all symlinks relative to it. The script asks what to install: **terminal**, **window manager** or **both**.

> **macOS:** **AeroSpace** needs Accessibility permission (System Settings → Privacy & Security → Accessibility).

### Automatic backups

Any existing file (`~/.zshrc`, `~/.config/i3`, etc.) is backed up to `*.bak-<date>`
before the symlink is created. To revert, restore the matching `.bak`.

### Personal / machine-specific config

Keep secrets, tokens and per-machine PATHs **out of the repo** in `~/.zshrc.local`
(not versioned). The repo's `.zshrc` sources it last so it can override anything.

---

## Window manager shortcuts

Modifier: **`Win`** on i3 (Linux) · **`alt`/Option** on AeroSpace (macOS).

| Action                              | i3 (Linux)            | AeroSpace (macOS)        |
|-------------------------------------|-----------------------|--------------------------|
| Open terminal                       | `Win`+`Enter`         | `alt`+`Enter`            |
| Switch to workspace *n*             | `Win`+`n`             | `alt`+`n`                |
| Send window to workspace *n*        | `Win`+`Shift`+`n`     | `alt`+`Shift`+`n`        |
| Move focus                          | `Win`+`h/j/k/l`       | `alt`+`h/j/k/l`          |
| Move window                         | `Win`+`Shift`+`h/j/k/l` | `alt`+`Shift`+`h/j/k/l` |
| Fullscreen                          | `Win`+`f`             | `alt`+`f`                |
| Close window                        | `Win`+`Shift`+`q`     | `alt`+`Shift`+`q`        |
| Floating / tiling                   | `Win`+`Shift`+`Space` | `alt`+`Shift`+`Space`    |
| Resize mode                         | `Win`+`r`             | `alt`+`r`                |
| Reload config                       | `Win`+`Shift`+`c`     | `alt`+`Shift`+`c`        |
| Open VS Code                        | `Win`+`Shift`+`v`     | `alt`+`Shift`+`v`        |
| App launcher                        | `Win`+`d` (rofi)      | `Cmd`+`Space` (Spotlight/Raycast) |

> On macOS, brightness, volume and power/restart use the native system keys/shortcuts.
> Screenshots use flameshot — run `ss` (or `flameshot gui`); it needs Screen Recording
> permission (System Settings > Privacy & Security > Screen Recording).

---

## Terminal shortcuts (Warp/ZSH)

| Action                          | Keys                |
|---------------------------------|---------------------|
| Go to end of line               | `Alt` + `>`         |
| Go to start of line             | `Alt` + `<`         |
| Forward one word                | `Ctrl` + `>`        |
| Backward one word               | `Ctrl` + `<`        |

## Useful aliases and functions

- `l` → `ls -al` (via `lsd`) · `cat` → `bat`/`batcat`
- `gs` `gd` `ga` · `gp` → `git push origin HEAD` (current branch) · `gtree` → log graph
- `update` → update the system (`apt`/`dnf` on Linux, `brew` on macOS) · `reload` → reload `~/.zshrc`
- `mkcd <dir>` · `sizeof <path>` · `ss` (screenshot)
- OS-specific aliases/functions live in `shell/zshrc.linux.sh` and `shell/zshrc.macos.sh`.

---

## Contributing

1. Fork and create a branch: `git checkout -b my-feature`
2. Commit and open a Pull Request describing your changes.

## License

Distributed under the [MIT License](https://opensource.org/licenses/MIT).
