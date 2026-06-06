# zshrc.macos.sh — macOS-specific fragment (sourced from ~/.zshrc).

# --- Homebrew on PATH (Apple Silicon in /opt/homebrew, Intel in /usr/local) -
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi
BREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"

# --- VS Code `code` command ------------------------------------------------
# On macOS the 'code' binary lives inside the app bundle, not on PATH (unlike
# Linux, where the package already drops it in /usr/bin). Add it if the app
# exists, so `code .` works from the terminal.
VSCODE_BIN="/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
[[ -d "$VSCODE_BIN" ]] && export PATH="$PATH:$VSCODE_BIN"

# --- Autosuggestions, syntax highlighting and Powerlevel10k ----------------
# Warp ships these out of the box, so they are only loaded outside Warp
# (e.g. the VS Code integrated terminal).
if [[ "$TERM_PROGRAM" != "WarpTerminal" ]]; then
    [[ -r "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
        source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    [[ -r "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
        source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    [[ -r "$BREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme" ]] && \
        source "$BREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme"
fi

# --- macOS-specific aliases ------------------------------------------------
alias spo="sudo shutdown -h now"
alias srb="sudo shutdown -r now"
alias update="brew update && brew upgrade && brew cleanup"
# Clipboard: pbcopy/pbpaste are native. Linux-style shortcuts:
alias setclip="pbcopy"
alias getclip="pbpaste"

# --- macOS-specific functions ----------------------------------------------
# 'open' is already native on macOS, no need to redefine it.
function ss() { flameshot gui; }                        # screenshot (same as Linux)
