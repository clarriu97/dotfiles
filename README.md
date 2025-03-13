# Dotfiles & Linux Environment Setup

[![OS: Linux](https://img.shields.io/badge/OS-Linux-blue)](#) [![i3: yes](https://img.shields.io/badge/i3-yes-brightgreen)](#) [![Build Status](https://img.shields.io/badge/build-passing-success)](#) [![No Spaghetti](https://img.shields.io/badge/code-no--spaghetti-red)](#) [![Works on my machine](https://img.shields.io/badge/works-on%20my%20machine-lightgrey)](#) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](#)

![ScreenRecord](images/screenrecord.gif)

This repository contains all the files and configurations needed to quickly set up a Linux working environment with a customized **ZSH** (with [powerlevel10k](https://github.com/romkatv/powerlevel10k), and plugins), [Warp](https://www.warp.dev/) (as a modern, GPU-accelerated terminal) and an **i3wm** (with [polybar](https://github.com/polybar/polybar)) setup.

---

## Table of Contents

1. [Overview](#overview)  
2. [Terminal View](#terminal-view)  
3. [Supported Distributions](#supported-distributions)  
4. [Requirements](#requirements)  
5. [Installation](#installation)  
6. [Post-install Configuration](#post-install-configuration)  
7. [Keyboard Shortcuts](#keyboard-shortcuts)  
   - [i3wm Shortcuts](#i3wm-shortcuts)  
   - [Terminal Shortcuts (Warp/ZSH)](#terminal-shortcuts-warpzsh)  
8. [Useful Aliases](#useful-aliases)  
9. [Contributing](#contributing)  
10. [License](#license)  

---

## Overview

**Goal**: Provide an easy way to replicate your Linux dev environment by automatically configuring:
- **Terminal**: ZSH + [powerlevel10k](https://github.com/romkatv/powerlevel10k) + helpful plugins.
- **Window Manager**: [i3wm](https://i3wm.org/) + [polybar](https://github.com/polybar/polybar).

Key features:
1. A stylish, high-performance prompt.
2. Plugin integrations to enhance command-line experience.
3. A minimal yet powerful tiling window manager setup with a customizable status bar.

---


## Terminal View

![Terminal Demo](images/terminalrecord.gif)
*An example of the terminal with ZSH + powerlevel10k.*

## Supported Distributions

- [Fedora 36-38](https://getfedora.org/)
- [Ubuntu 20.04](https://ubuntu.com/)

---

## Requirements

Make sure you have the following before starting:
- [Git](https://git-scm.com/)

---

## Installation

> **Warning**: The installation process will require superuser privileges and will reboot your system upon completion to ensure all changes take effect.

To clone the repository and launch the setup:

```bash
git clone https://github.com/clarriu97/dotfiles /tmp/dotfiles
chmod +x /tmp/dotfiles/setup.sh
/tmp/dotfiles/setup.sh
```

1. **Distribution Selection**: The script will ask which distro you use.
2. **Installation Options**:
   - Only terminal (ZSH + powerlevel10k + plugins).
   - Only i3wm + polybar.
   - Both terminal and i3wm.

Example of what you will see in the terminal:

![Installation Example](images/example_questions.png)

Once you select your desired options, the automatic installation and configuration will begin.

## Post-install Configuration

### Polybar Network Interfaces

You need to update the network interface names in the `etc` and `wlan` modules inside:

```
/home/<user>/.config/polybar/config.ini
```

For example:

```ini
[module/wlan]
inherit = network-base
interface-type = wireless
interface = wlp5s0
label-connected = %{F#F0C674}%{F-}  %essid% %local_ip% %{F#F0C674}  %downspeed:1%  %upspeed:1%%{F-}

[module/eth]
inherit = network-base
interface-type = wired
interface = enp0s31f6
label-connected = %{F#F0C674}%{F-}  %local_ip% %{F#F0C674}  %downspeed:1%  %upspeed:1%%{F-}
```

Replace `wlp5s0` and `enp0s31f6` with the correct interface names on your system.  
> *Tip: run `ip link show` to see your interfaces.*

---

## Keyboard Shortcuts

### i3wm Shortcuts

| Action                                             | Keys                          |
|----------------------------------------------------|-------------------------------|
| Open terminal (Warp)                              | `Win` + `Enter`               |
| Switch to workspace `n`                            | `Win` + `n` (number)          |
| Send current window to workspace `n`               | `Win` + `Shift` + `n`         |
| Switch to last used workspace/window               | `Win` + `Tab`                 |
| Close current window                                | `Win` + `Shift` + `Q`         |
| Home screens setup (via `xrandr`)                  | `Win` + `Shift` + `H`         |
| Office screens setup (via `xrandr`)                | `Win` + `Shift` + `G`         |
| Only primary screen (via `xrandr`)                 | `Win` + `Shift` + `B`         |
| Resize mode (Press `ESC` to exit)                  | `Win` + `R`                   |
| Screenshot ([flameshot](https://github.com/flameshot-org/flameshot)) | `Win` + `Ctrl` + `S` |
| Open file explorer (`Files`)                       | `Win` + `Ctrl` + `E`          |
| Reboot the system                                  | `Win` + `Ctrl` + `R`          |
| Power off the system                                | `Win` + `Ctrl` + `P`          |

### Terminal Shortcuts (Warp/ZSH)

| Action                                                 | Keys                                      |
|--------------------------------------------------------|-------------------------------------------|
| Open a new tab                                         | `Ctrl` + `Shift` + `t`                    |
| Rename current tab                                     | `Ctrl` + `Shift` + `Alt` + `t`            |
| Go to the tab on the left                              | `Ctrl` + `Shift` + `←`                    |
| Go to the tab on the right                             | `Ctrl` + `Shift` + `→`                    |
| Move current tab to the left *(ES keyboard)*           | `Ctrl` + `Shift` + `,`                    |
| Move current tab to the right *(ES keyboard)*          | `Ctrl` + `Shift` + `.`                    |
| Jump forward one word in the current command line      | `Ctrl` + `>`                              |
| Jump backward one word in the current command line     | `Ctrl` + `<`                              |
| Go to end of the line                                  | `Alt` + `>`                               |
| Go to start of the line                                | `Alt` + `<`                               |

---

## Useful Aliases

- `l`: `ls -al`
- `gs`: `git status`
- `gd`: `git diff`
- `catzsh`: `cat ~/.zshrc`
- `nanozsh`: `nano ~/.zshrc`
- `gtree`: `git log --graph --oneline --all`
- `open <file>`: open any file with `xdg-open`
- `sizeof <file_or_folder>`: display size via `du -sh`

*(They're now integrated within Warp)*

---

## Contributing

Contributions are welcome! To propose changes:

1. Fork this repository.  
2. Create a new branch: `git checkout -b my-feature`  
3. Commit your changes: `git commit -m 'Add my feature'`  
4. Push to your branch: `git push origin my-feature`  
5. Open a Pull Request on GitHub explaining your changes.

---

## License

Distributed under the [MIT License](https://opensource.org/licenses/MIT).  
Feel free to use, modify, and distribute as you see fit.

---

**Final Note**  
- Always back up your existing configuration files (e.g., `~/.zshrc`, `~/.config/i3`, etc.) before running any script that might overwrite them.  
- If you encounter issues or want to request new features, please open an issue on GitHub!
