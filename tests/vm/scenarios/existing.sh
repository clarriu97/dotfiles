#!/usr/bin/env bash
# Scenario 3 — rehearsal of the real rollout: a Mac that is already in use.
# Homebrew with some casks, apps installed by hand (Brave, Claude), Claude Code
# installed twice (Homebrew cask + native), a hand-written ~/.zshrc and
# ~/.claude files. Rolled out phase by phase as on the real machine, then
# uninstalled: the original files must come back byte for byte.

# shellcheck disable=SC2016
FIXTURES=dotfiles/tests/vm/fixtures/existing-mac

step "Prepare a Mac that is already in use"
if remote 'NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' \
    > "$RESULTS/setup-homebrew.log" 2>&1; then pass "Homebrew installed"; else fail "Homebrew install (see setup-homebrew.log)"; fi
if remote 'eval "$(/opt/homebrew/bin/brew shellenv)"
    brew install --cask warp visual-studio-code claude-code font-hack-nerd-font
    brew install fzf bat lsd fastfetch tealdeer
    for c in brave-browser claude; do
        file="$(brew fetch --cask "$c" 2>/dev/null | sed -n "s/^Downloaded to: //p; s/^Already downloaded: //p" | tail -1)"
        case "$file" in
            *.zip) ditto -xk "$file" /Applications/ ;;
            *)     mnt="$(hdiutil attach -nobrowse "$file" | tail -1 | cut -f3-)"
                   cp -R "$mnt"/*.app /Applications/
                   hdiutil detach -quiet "$mnt" ;;
        esac
    done
    curl -fsSL https://claude.ai/install.sh | bash' > "$RESULTS/setup-apps.log" 2>&1; then
    pass "casks + hand-installed Brave and Claude + native Claude CLI"
else
    fail "app setup (see setup-apps.log)"
fi
remote "cp $FIXTURES/zshrc ~/.zshrc; cp $FIXTURES/zprofile ~/.zprofile
    mkdir -p ~/.claude; cp $FIXTURES/claude-settings.json ~/.claude/settings.json; cp $FIXTURES/CLAUDE.md ~/.claude/CLAUDE.md"
expect_remote "Brave installed by hand" '[ -d "/Applications/Brave Browser.app" ] && ! /opt/homebrew/bin/brew list --cask brave-browser'
expect_remote "two Claude CLIs installed" '[ -d /opt/homebrew/Caskroom/claude-code ] && [ -x ~/.local/bin/claude ]'
remote 'shasum ~/.zshrc ~/.zprofile ~/.claude/settings.json ~/.claude/CLAUDE.md' > "$RESULTS/original.sha"

step "Phase 1: terminal + claude"
install_dotfiles terminal,claude
doctor terminal,claude
expect_remote "duplicate Homebrew claude-code cask removed" '[ ! -d /opt/homebrew/Caskroom/claude-code ]'
expect_remote "zsh resolves claude to the native install" '[ "$(zsh -i -c "command -v claude" </dev/null 2>/dev/null)" = "$HOME/.local/bin/claude" ]'
expect_remote "original ~/.zshrc backed up" 'grep -q original-zshrc ~/.zshrc.bak-*'
expect_remote "original Claude settings backed up" 'grep -q original-claude-settings ~/.claude/settings.json.bak-*'

step "Phase 2: apps + wm + desktop"
install_dotfiles apps,wm,desktop
doctor apps,wm,desktop
expect_remote "Brave still there" '[ -d "/Applications/Brave Browser.app" ]'
desktop_is_usable "1-after-phase-2"

step "Phase 3: keyboard"
install_dotfiles keyboard
doctor keyboard

reboot_vm "$VM"
desktop_is_usable "2-after-reboot"
typed="$(capture_keys /tmp/existing-keys.txt "type ok" "key space" "combo rmeta+2" "combo lmeta+2")"
if [[ "$typed" == "ok @@" ]]; then pass "keyboard unchanged until permissions are approved"; else fail "keyboard: got '$typed'"; fi

step "Second full run is a no-op"
remote 'cd ~/dotfiles && ./install.sh --yes' > "$RESULTS/second-run.log" 2>&1
if grep -qE 'linked:|installed:|Backing up' "$RESULTS/second-run.log"; then
    fail "second run changed files (see second-run.log)"
else
    pass "second run changed nothing"
fi

step "Uninstall restores the original files byte for byte"
if remote '.local/bin/dotfiles uninstall' > "$RESULTS/uninstall.log" 2>&1; then pass "dotfiles uninstall"; else fail "dotfiles uninstall (see uninstall.log)"; fi
remote 'shasum ~/.zshrc ~/.zprofile ~/.claude/settings.json ~/.claude/CLAUDE.md' > "$RESULTS/restored.sha"
if diff "$RESULTS/original.sha" "$RESULTS/restored.sha"; then pass "original files restored"; else fail "files differ after uninstall"; fi
expect_remote "Dock settings back to stock" '! defaults read com.apple.dock autohide >/dev/null 2>&1'
desktop_is_usable "3-after-uninstall"
