# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

alias ls="lsd"
alias l="ls -al"
alias ll="ls -l"
alias spo="systemctl poweroff"
alias srb="systemctl reboot"
alias gs="git status"
alias gd="git diff"
alias ga="git add ."
alias gp="git push origin master"
alias gpt="git push --tags"
alias nanozsh="nano ~/.zshrc"
alias nanoi3="nano ~/.config/i3/config"
alias nanoalacritty="nano ~/.config/alacritty/alacritty.yml"
alias catzsh="cat ~/.zshrc"
alias cat="bat"
alias catn="/usr/bin/cat"
alias update="sudo apt-get update -y && sudo apt-get upgrade -y && exit"
alias gtree="git log --graph --oneline --all"
alias solaar="~/foo/Solaar/bin/solaar &"
alias xclip="xclip -selection clipboard"

# OTHER
export PATH=/sbin/:/usr/bin/:$HOME/bin:/usr/local/bin:~/.local/bin:$PATH
export GITLAB_API_TOKEN=""
export HISTFILE=$HOME/.zsh_history
export GITHUB_TOKEN=""
export GOOGLE_MAPS_APIKEY=""


function mkcd {
	mkdir $1
	cd $1
}

function open() {
	xdg-open "$1" &
}

function sizeof() {
	du -sh "$1"
}

function opemacs() {
	setsid emacs "$1" &>/dev/null
}

function welcome(){
	neofetch
}

function untarfile() {
	tar -xvf "$1"
}

function untarfilegz() {
	tar -xvzf "$1"
}

function tarfilegz() {
	tar -czf "$1.tar.gz" "$1"
}

function tarfile() {
	tar -cf "$1.tar" "$1"
}

function count() {
	l "$1" | wc -l
}

function ss() {
	/usr/bin/flameshot gui
}

function removenonedockers() {
	sudo docker rmi $(sudo docker images -f "dangling=true" -q)
}

function updateenv() {
	deactivate && source ~/.zshrc
}

function rmk(){
	scrub -p dod $1
	shred -zun 10 -v $1
}

function set_wallpaper() {
	feh --bg-fill $1
}

function compare_files() {
	cmp --silent $1 $2 && echo '### SUCCESS: Files Are Identical! ###' || echo '### WARNING: Files Are Different! ###'
}

DISABLE_AUTO_TITLE="true"

# Plugins
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-sudo/sudo.plugin.zsh

welcome

source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# shortcuts para teclas
bindkey "^[[1;3C" end-of-line        # ALT + >
bindkey "^[[1;3D" beginning-of-line  # ALT + <
bindkey "^[[1;5C" forward-word       # CTRL + >
bindkey "^[[1;5D" backward-word      # CTRL + <

# delete a character with the "supr" key
bindkey "^[[3~" delete-char

# autocomplete non case sensitive
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
autoload -Uz compinit && compinit

# change directory withoud cd
setopt auto_cd
