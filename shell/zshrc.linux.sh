# zshrc.linux.sh — Linux-specific fragment (sourced from ~/.zshrc).

# --- zsh plugins (vendored in the repo, linked into ~/.local/share) --------
ZSH_PLUGINS="$HOME/.local/share/zsh-plugins"

# sudo.plugin (ESC ESC prepends 'sudo' to the command): useful everywhere, also in Warp.
[[ -r "$ZSH_PLUGINS/sudo.plugin.zsh" ]] && source "$ZSH_PLUGINS/sudo.plugin.zsh"

# Autosuggestions, syntax highlighting and Powerlevel10k: Warp ships these out
# of the box, so they are only loaded outside Warp (e.g. the VS Code terminal).
if [[ "$TERM_PROGRAM" != "WarpTerminal" ]]; then
    [[ -r "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
        source "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    [[ -r "$ZSH_PLUGINS/zsh-autosuggestions.zsh" ]] && \
        source "$ZSH_PLUGINS/zsh-autosuggestions.zsh"
    [[ -r "$HOME/powerlevel10k/powerlevel10k.zsh-theme" ]] && \
        source "$HOME/powerlevel10k/powerlevel10k.zsh-theme"
fi

# --- Linux-specific aliases ------------------------------------------------
alias spo="systemctl poweroff"
alias srb="systemctl reboot"
alias nanoi3="nano ~/.config/i3/config"
alias update="sudo apt-get update -y && sudo apt-get upgrade -y"   # Debian/Ubuntu
alias xclip="xclip -selection clipboard"

# --- Linux-specific functions ----------------------------------------------
function open() { xdg-open "$1" & }
function opemacs() { setsid emacs "$1" &>/dev/null; }
function ss() { flameshot gui; }                       # screenshot
function rmk() {                                       # secure delete
    scrub -p dod "$1"
    shred -zun 10 -v "$1"
}
