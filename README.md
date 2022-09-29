
## Welcome

This repository is meant to store all the files and configurations needed to instantly set my Linux working environment to my liking.

The tool can configure two main things:

- Your terminal: using `zsh`, [`powerlevel10k`](https://github.com/romkatv/powerlevel10k)
- Your Windows Manager: using [i3wm](https://i3wm.org/)

## Overview

This is how your environment will look like if you install everything.

![terminal](images/terminal.png)

## Support

The tool supports the following Linux distributions:

- [Fedora](https://getfedora.org/)
- [Ubuntu](https://ubuntu.com/)

## Needs

To automate the process and to avoid problems, you should have the following tools installed:

- [GNU Make](https://www.gnu.org/software/make/)
- [Git](https://git-scm.com/)

## Get started

> In the installation process there will be actions that require super user permissions.
> The process will reboot your system when it finishes.

To start the installation of all tools and configurations, simply run the following command:

```bash
git clone https://github.com/clarriu97/dotfiles && cd dotfiles && make -s setup-env
```

## User guide and shortcuts

`in3` is a windows manager with which we will be able to manage all our windows environment
with the keyboard. For that purpose, every command will be a combination of the `$mod` key plus
any other keys. In my case, the `$mod` key is the `Windows` key:

![winkey](images/win_key.jpg)

- `Win` + number(`n`): move to window `n`.
- `Win` + `Shift` + number(`n`): move the window you are working on, to window `n`.
- `Win` + `Tab`: move to the last window you were at.
- `Win` + `Shift` + `Q`: close the window you are working on.
