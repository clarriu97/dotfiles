.PHONY: docs test help
.DEFAULT_GOAL := help

SHELL := /bin/bash

export ROOTDIR:=$(shell pwd)
OUTPUT_PATH=${ROOTDIR}/output

define PRINT_HELP_PYSCRIPT
import re, sys
print("You can run the following targets (with make <target>): \r\n")
for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black=\033[0;30m
Red=\033[0;31m
Green=\033[0;32m
Orange=\033[0;33m
Blue=\033[0;34m
Purple=\033[0;35m
Cyan=\033[0;36m
White=\033[0;37m
NC=\033[0m

help:
	@python3.8 -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

setup-env: ## start the whole setup
	$(MAKE) welcome-message
	$(MAKE) show-warning-message && $(MAKE) ask-for-distro-and-choice
	reboot

welcome-message: ## show a welcome message and presents the tool
	@echo -e "${Orange}"
	@echo -e "██╗    ██╗███████╗██╗      ██████╗ ██████╗ ███╗   ███╗███████╗    ████████╗ ██████╗ "
	@echo -e "██║    ██║██╔════╝██║     ██╔════╝██╔═══██╗████╗ ████║██╔════╝    ╚══██╔══╝██╔═══██╗"
	@echo -e "██║ █╗ ██║█████╗  ██║     ██║     ██║   ██║██╔████╔██║█████╗         ██║   ██║   ██║"
	@echo -e "██║███╗██║██╔══╝  ██║     ██║     ██║   ██║██║╚██╔╝██║██╔══╝         ██║   ██║   ██║"
	@echo -e "╚███╔███╔╝███████╗███████╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗       ██║   ╚██████╔╝"
	@echo -e " ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝       ╚═╝    ╚═════╝ "
	@echo -e "                                                                                    "
	@echo -e "          ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗             "
	@echo -e "          ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝             "
	@echo -e "          ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗             "
	@echo -e "          ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║             "
	@echo -e "          ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║             "
	@echo -e "          ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝             "
	@echo -e ""
	@echo -e "\n${NC}This project is made by ${Red}clarriu97${NC}"
	@echo -e "\nhttps://github.com/${Red}clarriu97${NC}/dotfiles"

show-warning-message: ## show a warning message when setting up the environment
	@echo -e "\n${Red}Note: the process requires super user privileges and will reboot your machine once finished. Is that okay with you? [Y/n] ${NC}" && read ans && [ $${ans:-N} != n ]
	@read line; if [ $$line = "n" ]; then echo Aborting...; exit 1; fi

.ONESHELL:
ask-for-distro-and-choice: ## ask the user what does he/she wants to configure and for which Linux distribution
	@echo -e "\nPlease select your Linux distro:"; \
        echo '1) Fedora'; \
        echo '2) Ubuntu'; \
        read -p 'Enter value: ' distro; export DISTRO=$$distro
	@echo -e "\nWhat do you want to install?:"; \
        echo '1) Terminal'; \
        echo '2) I3 Windows Manager'; \
		echo '3) Both Terminal and I3'; \
        read -p 'Enter value: ' choice; export CHOICE=$$choice

	@if [ $$DISTRO == "1" ]; then
		$(MAKE) update-fedora
		$(MAKE) install-fedora-os-deps
		if [ $$CHOICE == "1" ]; then
			$(MAKE) configure-fedora-terminal
		elif [ $$CHOICE == "2" ]; then
			$(MAKE) configure-i3
		elif [ $$CHOICE == "3" ]; then
			$(MAKE) configure-fedora-terminal
			$(MAKE) configure-i3
		else
			echo -e "\nPlease select one of the options..." && exit 1
		fi
	elif [ $$DISTRO == "2" ]; then
		$(MAKE) update-and-upgrade-ubuntu
		$(MAKE) install-ubuntu-os-deps
		if [ $$CHOICE == "1" ]; then
			$(MAKE) configure-ubuntu-terminal
		elif [ $$CHOICE == "2" ]; then
			$(MAKE) configure-i3
		elif [ $$CHOICE == "3" ]; then
			$(MAKE) configure-ubuntu-terminal
			$(MAKE) configure-i3
		else
			echo -e "\nPlease select one of the options..." && exit 1
		fi
	else
		echo -e "\nPlease select one of the options..." && exit 1
	fi

###################
## System update ##
###################

update-and-upgrade-ubuntu: ## update and upgrade Ubuntu dependencies
	sudo apt-get update -y && sudo apt-get upgrade -y

update-ubuntu: ## update Ubuntu dependencies
	sudo apt-get update -y

update-fedora: ## update Fedora dependencies
	sudo dnf upgrade -y

#####################
## OS dependencies ##
#####################

install-ubuntu-os-deps: update-ubuntu ## install Ubuntu OS dependencies
	## Visual Studio Code
	@echo -e "${Cyan}Installing ${Green}Visual Studio Code${Cyan}...${NC}"
	sudo apt install -y software-properties-common apt-transport-https wget
	wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
	sudo apt install -y code
	@echo -e "${Green}Visual Studio Code${Cyan} installed!${NC}"

	## Spotify
	@echo -e "${Cyan}Installing ${Green}Spotify${Cyan}...${NC}"
	curl -sS https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg | sudo apt-key add - 
	@echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
	$(MAKE) update-ubuntu
	sudo apt-get install -y spotify-client
	@echo -e "${Green}Spotify${Cyan} installed!${NC}"

	## Neofetch
	sudo apt install -y neofetch

	## Brave browser
	@echo -e "${Cyan}Installing ${Green}Brave browser${Cyan}...${NC}"
	sudo apt install -y apt-transport-https curl
	sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
	@echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
	$(MAKE) update-ubuntu
	sudo apt install -y brave-browser
	@echo -e "${Green}Brave browser${Cyan} installed!${NC}"

	## dpkg
	@echo -e "${Cyan}Installing ${Green}dpkg${Cyan}...${NC}"
	sudo apt-get install -y dpkg
	@echo -e "${Green}dpkg${Cyan} installed!${NC}"

	## zsh
	@echo -e "${Cyan}Installing ${Green}zsh${Cyan}...${NC}"
	sudo apt-get install -y zsh
	@echo -e "${Green}zsh${Cyan} installed!${NC}"

	## flameshot
	@echo -e "${Cyan}Installing ${Green}flameshot${Cyan}...${NC}"
	sudo apt install -y flameshot
	@echo -e "${Green}flameshot${Cyan} installed!${NC}"

	## i3wm
	@echo -e "${Cyan}Installing ${Green}i3wm${Cyan}...${NC}"
	sudo apt install -y i3
	@echo -e "${Green}i3wm${Cyan} installed!${NC}"

	## i3blocks
	@echo -e "${Cyan}Installing ${Green}i3blocks${Cyan}...${NC}"
	sudo apt install -y i3blocks
	@echo -e "${Green}i3blocks${Cyan} installed!${NC}"

	## tox
	@echo -e "${Cyan}Installing ${Green}tox${Cyan}...${NC}"
	$(MAKE) install-tox
	@echo -e "${Green}tox${Cyan} installed!${NC}"

	## arandr
	@echo -e "${Cyan}Installing ${Green}arandr${Cyan}...${NC}"
	sudo apt-get install -y arandr
	@echo -e "${Green}arandr${Cyan} installed!${NC}"

	## rofi
	@echo -e "${Cyan}Installing ${Green}rofi${Cyan}...${NC}"
	sudo apt install -y rofi
	@echo -e "${Green}rofi${Cyan} installed!${NC}"

	## docker
	@echo -e "${Cyan}Installing ${Green}docker${Cyan}...${NC}"
	sudo apt-get install \
		ca-certificates \
		curl \
		gnupg \
		lsb-release
	sudo mkdir -p /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	$(MAKE) docker-group
	@echo -e "${Green}docker${Cyan} installed!${NC}"

	## playerctl
	@echo -e "${Cyan}Installing ${Green}playerctl${Cyan}...${NC}"
	wget https://github.com/altdesktop/playerctl/releases/download/v2.4.1/playerctl-2.4.1_amd64.deb
	sudo dpkg -i playerctl-2.4.1_amd64.deb
	rm playerctl-2.4.1_amd64.deb
	@echo -e "${Green}playerctl${Cyan} installed!${NC}"

	## scrub
	@echo -e "${Cyan}Installing ${Green}scrub${Cyan}...${NC}"
	sudo apt install -y scrub
	@echo -e "${Green}scrub${Cyan} installed!${NC}"

	## coreutils (just in case)
	@echo -e "${Cyan}Installing ${Green}coreutils${Cyan}...${NC}"
	sudo apt install -y coreutils
	@echo -e "${Green}coreutils${Cyan} installed!${NC}"

install-fedora-os-deps: update-fedora ## install Fedora OS dependencies
	## Visual Studio Code
	@echo -e "${Cyan}Installing ${Green}Visual Studio Code${Cyan}...${NC}"
	sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
	sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
	dnf check-update
	sudo dnf install -y code
	@echo -e "${Green}Visual Studio Code${Cyan} installed!${NC}"

	## Spotify
	@echo -e "${Cyan}Installing ${Green}Spotify${Cyan}...${NC}"
	sudo dnf install -y flatpak && \
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	sudo flatpak install -y flathub com.spotify.Client
	@echo -e "${Green}Spotify${Cyan} installed!${NC}"

	## Neofetch
	@echo -e "${Cyan}Installing ${Green}Neofetch${Cyan}...${NC}"
	sudo dnf install -y neofetch
	@echo -e "${Green}Neofetch${Cyan} installed!${NC}"

	## Brave browser
	@echo -e "${Cyan}Installing ${Green}Brave browser${Cyan}...${NC}"
	sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
	sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
	sudo dnf install -y brave-browser
	@echo -e "${Green}Brave browser${Cyan} installed!${NC}"

	## dpkg
	@echo -e "${Cyan}Installing ${Green}dpkg${Cyan}...${NC}"
	sudo dnf install -y dpkg
	@echo -e "${Green}dpkg${Cyan} installed!${NC}"

	## zsh
	@echo -e "${Cyan}Installing ${Green}zsh${Cyan}...${NC}"
	sudo dnf install -y zsh
	@echo -e "${Green}zsh${Cyan} installed!${NC}"

	## flameshot
	@echo -e "${Cyan}Installing ${Green}flameshot${Cyan}...${NC}"
	sudo dnf install -y flameshot
	@echo -e "${Green}flameshot${Cyan} installed!${NC}"

	## i3wm
	@echo -e "${Cyan}Installing ${Green}i3wm${Cyan}...${NC}"
	sudo dnf install -y i3
	@echo -e "${Green}i3wm${Cyan} installed!${NC}"

	## i3blocks
	@echo -e "${Cyan}Installing ${Green}i3blocks${Cyan}...${NC}"
	sudo apt install -y i3blocks
	@echo -e "${Green}i3blocks${Cyan} installed!${NC}"

	## tox
	@echo -e "${Cyan}Installing ${Green}tox${Cyan}...${NC}"
	$(MAKE) install-tox
	@echo -e "${Green}tox${Cyan} installed!${NC}"

	## arandr
	@echo -e "${Cyan}Installing ${Green}arandr${Cyan}...${NC}"
	sudo dnf install -y arandr
	@echo -e "${Green}arandr${Cyan} installed!${NC}"

	## rofi
	@echo -e "${Cyan}Installing ${Green}rofi${Cyan}...${NC}"
	sudo dnf install -y rofi
	@echo -e "${Green}rofi${Cyan} installed!${NC}"

	## docker
	@echo -e "${Cyan}Installing ${Green}docker${Cyan}...${NC}"
	sudo dnf install -y dnf-plugins-core
	sudo dnf config-manager \
		--add-repo \
		https://download.docker.com/linux/fedora/docker-ce.repo
	sudo dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin
	$(MAKE) docker-group
	@echo -e "${Green}docker${Cyan} installed!${NC}"

	## playerctl
	@echo -e "${Cyan}Installing ${Green}playerctl${Cyan}...${NC}"
	sudo dnf install -y playerctl
	@echo -e "${Green}playerctl${Cyan} installed!${NC}"

	## scrub
	@echo -e "${Cyan}Installing ${Green}scrub${Cyan}...${NC}"
	sudo dnf install -y scrub
	@echo -e "${Green}scrub${Cyan} installed!${NC}"

	## coreutils (just in case)
	@echo -e "${Cyan}Installing ${Green}coreutils${Cyan}...${NC}"
	sudo dnf install -y coreutils
	@echo -e "${Green}coreutils${Cyan} installed!${NC}"

docker-group: ## add your user to the docker group
	sudo groupadd docker
	sudo usermod -aG docker $$USER

install-tox: ## install tox with pip
	pip install tox

############################
## Terminal configuration ##
############################

configure-zsh-and-p10k: ## configure zsh and powerlevel10k
	@echo -e "${Cyan}Configuring ${Green}zsh ${Cyan}and ${Green}Powerlevel10k${Cyan}...${NC}"
	sudo usermod --shell /usr/bin/zsh $$USER
	sudo usermod --shell /usr/bin/zsh root

	## copy terminal files
	cp terminal/.zshrc $${HOME}/.zshrc
	cp terminal/.p10k.zsh $${HOME}/.p10k.zsh

	sudo cp terminal/.zshrc /root/.zshrc
	sudo cp terminal/.p10k.zsh /root/.p10k.zsh

	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
	@echo -e "${Green}Done!${NC}"

configure-zsh-plugins: ## configure zsh plugins
	@echo -e "${Cyan}Installing ${Green}zsh plugins${Cyan}...${NC}"

	sudo mkdir -p /usr/share/zsh-autosuggestions && \
	sudo cp terminal/zsh-plugins/zsh-autosuggestions.zsh /usr/share/zsh-autosuggestions

	sudo mkdir -p /usr/share/zsh-sudo && \
	sudo cp terminal/zsh-plugins/sudo.plugin.zsh /usr/share/zsh-sudo

	sudo cp -r terminal/zsh-plugins/zsh-syntax-highlighting /usr/share
	@echo -e "${Green}Done!${NC}"

configure-kitty: ## configure Kitty terminal emulator
	mkdir -p $${HOME}/.config/kitty
	cp terminal/color.ini $${HOME}/.config/kitty
	cp terminal/kitty.conf $${HOME}/.config/kitty

configure-ubuntu-terminal: ## install and configure the terminal for Ubuntu
	## Kitty
	@echo -e "${Cyan}Installing ${Green}kitty${Cyan}...${NC}"
	sudo add-apt-repository universe
	sudo apt update -y
	sudo apt install -y kitty
	@echo -e "${Green}kitty${Cyan} installed!${NC}"

	## tldr (Too long, didn't read)
	@echo -e "${Cyan}Installing ${Green}tldr${Cyan}...${NC}"
	sudo apt install -y tldr
	@echo -e "${Green}tldr${Cyan} installed!${NC}"

	## lsd (ls with steroids)
	@echo -e "${Cyan}Installing ${Green}lsd${Cyan}...${NC}"
	wget https://github.com/Peltoche/lsd/releases/download/0.23.1/lsd-musl_0.23.1_i686.deb && \
	sudo dpkg -i lsd-musl_0.23.1_i686.deb
	rm lsd-musl_0.23.1_i686.deb
	@echo -e "${Green}lsd${Cyan} installed!${NC}"

	## bat (cat with steroids)
	@echo -e "${Cyan}Installing ${Green}bat${Cyan}...${NC}"
	wget https://github.com/sharkdp/bat/releases/download/v0.22.1/bat-musl_0.22.1_amd64.deb && \
	sudo dpkg -i bat-musl_0.22.1_amd64.deb
	rm bat-musl_0.22.1_amd64.deb
	@echo -e "${Green}bat${Cyan} installed!${NC}"

	## fzf
	@echo -e "${Cyan}Installing ${Green}fzf${Cyan}...${NC}"
	sudo apt-get install -y fzf
	@echo -e "${Green}fzf${Cyan} installed!${NC}"

	$(MAKE) configure-zsh-and-p10k
	$(MAKE) configure-zsh-plugins
	$(MAKE) configure-kitty
	$(MAKE) install-hack-nerd-font

configure-fedora-terminal: ## install and configure the terminal for Fedora
	## Kitty
	@echo -e "${Cyan}Installing ${Green}kitty${Cyan}...${NC}"
	sudo dnf install -y kitty
	@echo -e "${Green}kitty${Cyan} installed!${NC}"

	## tldr (Too long, didn't read)
	@echo -e "${Cyan}Installing ${Green}tldr${Cyan}...${NC}"
	sudo dnf install -y tldr
	@echo -e "${Green}tldr${Cyan} installed!${NC}"

	## lsd (ls with steroids)
	@echo -e "${Cyan}Installing ${Green}lsd${Cyan}...${NC}"
	sudo dnf install -y lsd
	@echo -e "${Green}lsd${Cyan} installed!${NC}"

	## bat (cat with steroids)
	@echo -e "${Cyan}Installing ${Green}bat${Cyan}...${NC}"
	sudo dnf install -y bat
	@echo -e "${Green}bat${Cyan} installed!${NC}"

	## fzf
	@echo -e "${Cyan}Installing ${Green}fzf${Cyan}...${NC}"
	sudo dnf install -y fzf
	@echo -e "${Green}fzf${Cyan} installed!${NC}"

	$(MAKE) configure-zsh-and-p10k
	$(MAKE) configure-zsh-plugins
	$(MAKE) configure-kitty
	$(MAKE) install-hack-nerd-font

install-hack-nerd-font: ## install font used in the terminal
	@echo -e "${Cyan}Installing ${Green}HackNerdFont${Cyan}...${NC}"
	wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/Hack.zip
	sudo mv Hack.zip /usr/share/fonts && \
	cd /usr/share/fonts && \
	sudo unzip -n Hack.zip && \
	sudo rm Hack.zip && sudo rm LICENSE.md && sudo rm readme.md
	@echo -e "${Green}HackNerdFont${Cyan} installed!${NC}"

#####################
## Windows manager ##
#####################

configure-i3: ## configure i3wm
	mkdir -p $${HOME}/.config/i3
	cp i3/config $${HOME}/.config/i3
	cp -r i3/scripts $${HOME}/.config/i3
	cp i3/i3blocks.conf $${HOME}/.config/i3

	mkdir -p $${HOME}/.screenlayout
	cp i3/.screenlayout/* $${HOME}/.screenlayout

	cp images/candado.png $${HOME}/Pictures

#########################
## Extra configuration ##
#########################

set-ubuntu-wallpaper: ## put a custom wallpaper
	feh --bg-fill images/wallpaper.jpeg
