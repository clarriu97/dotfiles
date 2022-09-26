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
Cyan=\033[0;31m
Green=\033[0;32m
Cyan=\033[0;33m
Blue=\033[0;34m
Purple=\033[0;35m
Cyan=\033[0;36m
White=\033[0;37m
NC=\033[0m

help:
	@python3.8 -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

setup-env: ## start the whole setup
	$(MAKE) show-warning-message && $(MAKE) ask-for-distro-and-choice
	# reboot

show-warning-message: ## show a warning message when setting up the environment
	@echo -e "${Red}Note: the process requires super user privileges and will reboot your machine once finished. Is that okay with you? [Y/n] ${NC}" && read ans && [ $${ans:-N} = y ]
	# @read line; if [ $$line = "n" ]; then echo Aborting...; exit 1; fi

.ONESHELL:
ask-for-distro-and-choice: ## ask the user what does he/she wants to configure and for which Linux distribution
	@echo Please select your Linux distro:; \
        echo '1) Fedora'; \
        echo '2) Ubuntu'; \
        read -p 'Enter value: ' distro; export DISTRO=$$distro
	@echo What do you want to install?:; \
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
			$(MAKE) configure-fedora-i3
		else
			$(MAKE) configure-fedora-terminal
			$(MAKE) configure-fedora-i3
		fi
	else
		$(MAKE) update-ubuntu
		$(MAKE) install-ubuntu-os-deps
		if [ $$CHOICE == "1" ]; then
			$(MAKE) configure-ubuntu-terminal
		elif [ $$CHOICE == "2" ]; then
			$(MAKE) configure-ubuntu-i3
		else
			$(MAKE) configure-ubuntu-terminal
			$(MAKE) configure-ubuntu-i3
		fi
	fi

update-ubuntu: ## update Ubuntu dependencies
	sudo apt-get update -y && sudo apt-get upgrade -y

update-fedora: ## update Fedora dependencies
	sudo dnf upgrade -y

configure-ubuntu-terminal: ## install and configure the terminal for Ubuntu
	$(MAKE) configure-zsh-terminal

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
	@echo -e "${Cyan}Installing ${Green}tldr${Cyan}...${NC}"
	sudo apt install -y lsd
	@echo -e "${Green}lsd${Cyan} installed!${NC}"

	## bat (cat with steroids)
	@echo -e "${Cyan}Installing ${Green}bat${Cyan}...${NC}"
	sudo apt install -y bat
	@echo -e "${Green}bat${Cyan} installed!${NC}"

configure-fedora-terminal: ## install and configure the terminal for Fedora
	$(MAKE) configure-zsh-terminal
	$(MAKE) install-hack-nerd-font

	## copy terminal files
	cp terminal/.zshrc $$(HOME)/.zshrc
	cp terminal/.p10k.zsh $$(HOME)/.p10k.zsh

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

configure-zsh-terminal: ## configure zsh as the user shell
	sudo usermod --shell /usr/bin/zsh clarriu

install-hack-nerd-font: ## install font used in the terminal
	wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/Hack.zip
	sudo mv Hack.zip /usr/share/fonts && \
	cd /usr/share/fonts && \
	sudo unzip Hack.zip && \
	sudo rm Hack.zip && sudo rm LICENSE.md && sudo rm readme.md

install-ubuntu-os-deps: update-ubuntu ## install Ubuntu OS dependencies
	$(MAKE) update-ubuntu

	## Neofetch
	sudo apt install -y neofetch

install-fedora-os-deps: update-fedora ## install Fedora OS dependencies
	$(MAKE) update-fedora

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

	## zsh
	@echo -e "${Cyan}Installing ${Green}zsh${Cyan}...${NC}"
	sudo dnf install -y zsh
	@echo -e "${Green}zsh${Cyan} installed!${NC}"

configure-fedora-i3: ## configure Fedora i3wm
	@echo "Fedora"

configure-ubuntu-i3: ## configure Ubuntu i3wm
	@echo "Ubuntu"
