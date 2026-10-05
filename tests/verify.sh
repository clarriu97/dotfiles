#!/usr/bin/env bash
# tests/verify.sh — post-install health check (also exposed as `dotfiles doctor`).
#
#   tests/verify.sh [--only terminal,apps,wm,keyboard,claude]
#
# Prints one line per check (PASS / WARN / FAIL) and exits non-zero if any
# check FAILs. WARN never fails the run (e.g. a macOS permission not granted yet).
set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/detect.sh
. "$DOTFILES_DIR/lib/detect.sh"

ONLY=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --only) ONLY="${2:-}"; shift 2 ;;
        --only=*) ONLY="${1#*=}"; shift ;;
        *) echo "Unknown option: $1" >&2; exit 2 ;;
    esac
done
if [[ -z "$ONLY" ]]; then
    case "$OS" in
        macos) ONLY="terminal,apps,wm,keyboard,desktop,claude" ;;
        *)     ONLY="terminal,apps,wm,claude" ;;
    esac
fi

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

FAILS=0
WARNS=0
pass() { printf '\033[0;32mPASS\033[0m %s\n' "$*"; }
warn() { printf '\033[0;35mWARN\033[0m %s\n' "$*"; WARNS=$((WARNS + 1)); }
fail() { printf '\033[0;31mFAIL\033[0m %s\n' "$*"; FAILS=$((FAILS + 1)); }

expect() {
    local desc="$1"
    shift
    if "$@" >/dev/null 2>&1; then pass "$desc"; else fail "$desc"; fi
}

default_is() { [[ "$(defaults read "$1" "$2" 2>/dev/null)" == "$3" ]]; }

has_font() { find "$HOME/Library/Fonts" /Library/Fonts -iname '*hack*nerd*' 2>/dev/null | grep -q .; }

want() { [[ ",$ONLY," == *",$1,"* ]]; }

expect_link() {
    local dest="$1" src="$DOTFILES_DIR/$2"
    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
        pass "link $dest"
    else
        fail "link $dest -> $src"
    fi
}

expect_cmd() {
    local c
    for c in "$@"; do
        if command -v "$c" >/dev/null 2>&1; then
            pass "command $c"
            return 0
        fi
    done
    fail "command $*"
}

optional_cmd() {
    local c
    for c in "$@"; do
        if command -v "$c" >/dev/null 2>&1; then
            pass "command $c"
            return 0
        fi
    done
    warn "command $* (optional, not available on this system)"
}

expect_app() {
    if [[ -d "/Applications/$1.app" || -d "$HOME/Applications/$1.app" ]]; then
        pass "app $1"
    else
        fail "app $1"
    fi
}

login_shell() {
    if [[ "$OS" == macos ]]; then
        dscl . -read "/Users/$(id -un)" UserShell 2>/dev/null | awk '{ print $2 }'
    else
        getent passwd "$(id -un)" | cut -d: -f7
    fi
}

now_ms() { perl -MTime::HiRes=time -e 'printf "%d\n", time * 1000'; }

check_zsh_startup() {
    local err start elapsed
    err="$(mktemp)"
    start="$(now_ms)"
    if ! TERM=xterm-256color zsh -i -c exit </dev/null >/dev/null 2>"$err"; then
        fail "zsh -i exits cleanly: $(head -c 400 "$err")"
    elif [[ -s "$err" ]]; then
        fail "zsh -i prints errors: $(head -c 400 "$err")"
    else
        elapsed=$(($(now_ms) - start))
        if [[ "$elapsed" -le "${ZSH_STARTUP_MAX_MS:-1500}" ]]; then
            pass "zsh -i starts without errors (${elapsed} ms)"
        else
            warn "zsh -i is slow (${elapsed} ms)"
        fi
    fi
    rm -f "$err"
}

echo "dotfiles doctor — $OS ($ARCH) — components: $ONLY"

if want terminal; then
    expect_link "$HOME/.zshrc" shell/.zshrc
    expect_link "$HOME/.p10k.zsh" shell/.p10k.zsh
    expect_link "$HOME/.config/zsh/zshrc.$([[ $OS == macos ]] && echo macos || echo linux).sh" \
        "shell/zshrc.$([[ $OS == macos ]] && echo macos || echo linux).sh"
    expect_cmd zsh
    expect_cmd git
    expect_cmd fzf
    expect_cmd bat batcat
    expect_cmd tldr
    expect_cmd zoxide
    expect_cmd rg
    expect_cmd fd fdfind
    optional_cmd lsd
    optional_cmd fastfetch neofetch
    case "$(login_shell)" in
        */zsh) pass "login shell is zsh" ;;
        *) fail "login shell is zsh (got: $(login_shell))" ;;
    esac
    if [[ "$OS" == macos ]]; then
        expect_app Warp
        expect "powerlevel10k" test -r "$(brew --prefix 2>/dev/null)/share/powerlevel10k/powerlevel10k.zsh-theme"
        expect "Hack Nerd Font" has_font
    else
        expect_link "$HOME/.local/share/zsh-plugins" shell/plugins
        expect_cmd warp-terminal
        expect "powerlevel10k" test -r "$HOME/powerlevel10k/powerlevel10k.zsh-theme"
        expect "Hack Nerd Font" bash -c "fc-list | grep -qi 'hack nerd font'"
    fi
    check_zsh_startup
    expect "zsh: zoxide 'z' command" zsh -i -c 'whence z' </dev/null
    expect "zsh: fzf Alt-C (cd widget) bound" bash -c "zsh -i -c 'bindkey \"\\\\ec\"' </dev/null 2>/dev/null | grep -q fzf-cd-widget"
    if [[ "$OS" == macos ]]; then
        expect_app Ghostty
        expect_link "$HOME/.config/ghostty/config" terminal/ghostty/config
        ghostty_bin=/Applications/Ghostty.app/Contents/MacOS/ghostty
        expect "Ghostty config is valid" "$ghostty_bin" +validate-config --config-file="$HOME/.config/ghostty/config"
        expect "Ctrl+Left/Right freed from Mission Control" bash -c \
            "defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys | grep -A1 -E '^ +79 =' | grep -q 'enabled = 0'"
    fi
fi

if want desktop; then
    expect "Dock auto-hides" default_is com.apple.dock autohide 1
    expect "Finder shows extensions" default_is NSGlobalDomain AppleShowAllExtensions 1
fi

if want apps; then
    if [[ "$OS" == macos ]]; then
        expect_app "Visual Studio Code"
        expect_app "Brave Browser"
    else
        expect_cmd code
        expect_cmd brave-browser
    fi
fi

if want wm; then
    if [[ "$OS" == macos ]]; then
        expect_app AeroSpace
        expect_link "$HOME/.aerospace.toml" wm/macos/aerospace/.aerospace.toml
        expect_cmd borders
        if pgrep -x AeroSpace >/dev/null && aerospace list-workspaces --focused >/dev/null 2>&1; then
            pass "AeroSpace running (focused workspace $(aerospace list-workspaces --focused))"
        else
            warn "AeroSpace not running or missing Accessibility permission (open -a AeroSpace)"
        fi
    else
        expect_cmd i3
        expect_cmd polybar
        expect_link "$HOME/.config/i3/config" wm/linux/i3/config
        expect_link "$HOME/.config/polybar" wm/linux/polybar
        expect "i3 config is valid" i3 -C -c "$HOME/.config/i3/config"
    fi
fi

if want keyboard; then
    expect_app Karabiner-Elements
    expect "karabiner.json installed" cmp -s "$DOTFILES_DIR/wm/macos/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"
    if systemextensionsctl list 2>/dev/null | grep -q 'Karabiner.*\[activated enabled\]'; then
        pass "Karabiner driver extension active"
    else
        warn "Karabiner driver extension not approved yet (Login Items & Extensions > Driver Extensions)"
    fi
fi

expect_link "$HOME/.local/bin/dotfiles" bin/dotfiles

if want claude; then
    if version="$("$HOME/.local/bin/claude" --version 2>/dev/null)"; then
        pass "claude $version (native)"
    else
        fail "claude --version (native install in ~/.local/bin)"
    fi
    case "$OS" in
        macos)  expect_app Claude ;;
        ubuntu) expect_cmd claude-desktop ;;
    esac
    expect_link "$HOME/.claude/CLAUDE.md" claude/CLAUDE.md
    expect_link "$HOME/.claude/settings.json" claude/settings.json
    expect_link "$HOME/.claude/statusline.sh" claude/statusline.sh
    expect_link "$HOME/.claude/hooks" claude/hooks
    for skill in "$DOTFILES_DIR"/claude/skills/*/; do
        skill="${skill%/}"
        expect_link "$HOME/.claude/skills/${skill##*/}" "claude/skills/${skill##*/}"
    done
    expect "status line renders" bash -c "echo '{}' | '$HOME/.claude/statusline.sh' | grep -q Claude"
    expect "guard hook blocks rm -rf ~" bash -c "! echo '{\"tool_input\":{\"command\":\"rm -rf ~\"}}' | '$HOME/.claude/hooks/guard-bash.sh' 2>/dev/null"
    plugins="$("$HOME/.local/bin/claude" plugin list 2>/dev/null)"
    for plugin in $(jq -r '.enabledPlugins | to_entries[] | select(.value) | .key' "$DOTFILES_DIR/claude/settings.json"); do
        if [[ "$plugins" == *"$plugin"* ]]; then pass "plugin $plugin"; else fail "plugin $plugin"; fi
    done
    if git -C "$DOTFILES_DIR" rev-parse >/dev/null 2>&1; then
        expect "claude/settings.json unchanged by the install" git -C "$DOTFILES_DIR" diff --quiet -- claude/settings.json
    fi
fi

echo
if [[ "$FAILS" -gt 0 ]]; then
    printf '\033[0;31m%d check(s) failed\033[0m, %d warning(s)\n' "$FAILS" "$WARNS"
    exit 1
fi
printf '\033[0;32mAll checks passed\033[0m, %d warning(s)\n' "$WARNS"
