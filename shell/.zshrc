# Warp ships its own prompt, autosuggestions and syntax highlighting. So
# Powerlevel10k and those plugins are only enabled OUTSIDE Warp (e.g. in the
# VS Code integrated terminal, SSH or tmux), avoiding conflicts and duplicates.
if [[ "$TERM_PROGRAM" != "WarpTerminal" ]]; then
  # Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
  # Code that requires input (passwords, [y/n]) must go above this block.
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
fi

# ===========================================================================
#  Common aliases (valid on macOS and Linux)
# ===========================================================================
(( $+commands[lsd] )) && alias ls="lsd"
alias l="ls -al"
alias ll="ls -l"
alias gs="git status"
alias gd="git diff"
alias ga="git add ."
alias gp="git push origin HEAD"        # push the current branch (was: hardcoded master)
alias gpt="git push --tags"
alias gtree="git log --graph --oneline --all"
alias nanozsh="nano ~/.zshrc"
alias catzsh="cat ~/.zshrc"
alias catn="command cat"
alias reload="source ~/.zshrc"

# cat -> bat (or batcat on Debian/Ubuntu, where the binary is renamed)
if (( $+commands[bat] )); then
    alias cat="bat"
elif (( $+commands[batcat] )); then
    alias cat="batcat"
fi

# ===========================================================================
#  Common functions
# ===========================================================================
function mkcd { mkdir -p "$1" && cd "$1"; }
function sizeof() { du -sh "$1"; }
function count() { l "$1" | wc -l; }
function untarfile() { tar -xvf "$1"; }
function untarfilegz() { tar -xvzf "$1"; }
function tarfilegz() { tar -czf "$1.tar.gz" "$1"; }
function tarfile() { tar -cf "$1.tar" "$1"; }
function compare_files() {
    cmp --silent "$1" "$2" && echo '### SUCCESS: Files Are Identical! ###' || echo '### WARNING: Files Are Different! ###'
}
function removenonedockers() {
    sudo docker rmi $(sudo docker images -f "dangling=true" -q)
}
# Welcome message (prefers fastfetch; falls back to neofetch if missing)
function welcome() {
    if (( $+commands[fastfetch] )); then
        fastfetch
    elif (( $+commands[neofetch] )); then
        neofetch
    fi
}

# ===========================================================================
#  Environment
# ===========================================================================
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
export HISTFILE="$HOME/.zsh_history"
DISABLE_AUTO_TITLE="true"

# ===========================================================================
#  OS-specific configuration
#  (aliases, functions, plugins and the Powerlevel10k path differ per OS)
# ===========================================================================
case "$(uname -s)" in
    Darwin) [[ -r "$HOME/.config/zsh/zshrc.macos.sh" ]] && source "$HOME/.config/zsh/zshrc.macos.sh" ;;
    Linux)  [[ -r "$HOME/.config/zsh/zshrc.linux.sh" ]] && source "$HOME/.config/zsh/zshrc.linux.sh" ;;
esac

# ===========================================================================
#  Powerlevel10k (the theme is sourced in the per-OS fragment) + its config
# ===========================================================================
welcome
# Powerlevel10k config (the theme is sourced by the per-OS fragment; only outside Warp).
[[ "$TERM_PROGRAM" != "WarpTerminal" && -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ===========================================================================
#  Key bindings
# ===========================================================================
bindkey "^[[1;3C" end-of-line        # ALT + >
bindkey "^[[1;3D" beginning-of-line  # ALT + <
bindkey "^[[1;5C" forward-word       # CTRL + >
bindkey "^[[1;5D" backward-word      # CTRL + <
bindkey "^[[3~"   delete-char        # Delete key

# case-insensitive autocomplete
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
autoload -Uz compinit && compinit

# change directory without typing cd; `cd -<TAB>` lists recent directories
setopt auto_cd auto_pushd pushd_ignore_dups

# fzf: Ctrl-T files, Ctrl-R history, Alt-C cd into a subdirectory
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border \
  --color=fg:#c0caf5,bg:-1,hl:#bb9af7,fg+:#c0caf5,bg+:#283457,hl+:#7dcfff \
  --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff,marker:#9ece6a,spinner:#9ece6a,header:#9ece6a,border:#3b4261"
if (( $+commands[fzf] )) && [[ -t 0 ]]; then
    if fzf --zsh >/dev/null 2>&1; then
        source <(fzf --zsh)
    elif [[ -r /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
        source /usr/share/doc/fzf/examples/key-bindings.zsh
    fi
fi

# bat follows the terminal palette (Tokyo Night)
export BAT_THEME="ansi"

# zoxide: `z <part of a path>` jumps to frequent directories, `zi` picks with fzf
if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
fi

# ===========================================================================
#  Personal/local configuration (NOT versioned)
#  For machine-specific PATHs (e.g. lmstudio), tokens or per-machine tweaks,
#  create ~/.zshrc.local; it is sourced last so it can override the above.
# ===========================================================================
if [[ -f ~/.zshrc.local ]]; then source ~/.zshrc.local; fi
