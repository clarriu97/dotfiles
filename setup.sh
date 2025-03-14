# Get system architecture
ARCH=$(uname -m)

# Map architecture to the corresponding deb file architecture
if [ "$ARCH" == "x86_64" ]; then
    DEB_ARCH="amd64"
elif [ "$ARCH" == "i686" ]; then
    DEB_ARCH="i386"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

###################
## System update ##
###################

function update_ubuntu {
    echo -e "\n${orange}Updating system...${nc}\n"
    sudo apt update -y && sudo apt upgrade -y
}

function update_fedora {
    echo -e "\n${orange}Updating system...${nc}\n"
    sudo dnf update -y && sudo dnf upgrade -y
}

#####################
## OS dependencies ##
#####################

function install_ubuntu_dependencies {
    echo -e "\n${orange}Installing dependencies:${nc}\n" && \
    echo -e "\t- ${cyan}software-properties-common${nc}" && \
    echo -e "\t- ${cyan}apt-transport-https${nc}" && \
    echo -e "\t- ${cyan}wget${nc}" && \
    echo -e "\t- ${cyan}Visual Studio Code${nc}" && \
    echo -e "\t- ${cyan}neofetch${nc}" && \
    echo -e "\t- ${cyan}Brave browser${nc}" && \
    echo -e "\t- ${cyan}dpkg${nc}" && \
    echo -e "\t- ${cyan}zsh${nc}" && \
    echo -e "\t- ${cyan}flameshot${nc}" && \
    echo -e "\t- ${cyan}i3wm${nc}" && \
    echo -e "\t- ${cyan}tox${nc}" && \
    echo -e "\t- ${cyan}arandr${nc}" && \
    echo -e "\t- ${cyan}rofi${nc}" && \
    echo -e "\t- ${cyan}docker${nc}" && \
    echo -e "\t- ${cyan}playerctl${nc}" && \
    echo -e "\t- ${cyan}scrub${nc}" && \
    echo -e "\t- ${cyan}coreutils${nc}" && \
    echo -e "\t- ${cyan}xclip${nc}" && \
    echo -e "\t- ${cyan}polybar${nc}" && \
    echo -e "\t- ${cyan}wget${nc}" && \
    echo -e "\t- ${cyan}gpg${nc}" && \
    echo -e "\t- ${cyan}vlc${nc}" && \
    echo -e "\n" && \

    sudo apt install -y software-properties-common apt-transport-https wget && \
    wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add - && \
    sudo add-apt-repository "deb [arch=${DEB_ARCH}] https://packages.microsoft.com/repos/vscode stable main" && \
	sudo apt install -y \
        code \
        neofetch \
        brave-browser \
        dpkg \
        zsh \
        flameshot \
        i3 \
        tox \
        arandr \
        rofi \
        docker \
        playerctl \
        scrub \
        coreutils \
        xclip \
        polybar \
        wget \
        gpg \
        vlc && \

    echo -e "\n${green}Dependencies installed!${nc}\n"
}

function install_fedora_dependencies {
    echo -e "\n${orange}Installing dependencies:${nc}\n" && \
    echo -e "\t- ${cyan}Visual Studio Code${nc}" && \
    echo -e "\t- ${cyan}neofetch${nc}" && \
    echo -e "\t- ${cyan}Brave browser${nc}" && \
    echo -e "\t- ${cyan}dpkg${nc}" && \
    echo -e "\t- ${cyan}zsh${nc}" && \
    echo -e "\t- ${cyan}flameshot${nc}" && \
    echo -e "\t- ${cyan}i3wm${nc}" && \
    echo -e "\t- ${cyan}tox${nc}" && \
    echo -e "\t- ${cyan}arandr${nc}" && \
    echo -e "\t- ${cyan}rofi${nc}" && \
    echo -e "\t- ${cyan}docker${nc}" && \
    echo -e "\t- ${cyan}playerctl${nc}" && \
    echo -e "\t- ${cyan}scrub${nc}" && \
    echo -e "\t- ${cyan}coreutils${nc}" && \
    echo -e "\t- ${cyan}xclip${nc}" && \
    echo -e "\t- ${cyan}polybar${nc}" && \
    echo -e "\t- ${cyan}wget${nc}" && \
    echo -e "\t- ${cyan}gpg${nc}" && \
    echo -e "\t- ${cyan}vlc${nc}" && \
    echo -e "\n" && \

    sudo dnf install -y \
        code \
        neofetch \
        brave-browser \
        dpkg \
        zsh \
        flameshot \
        i3 \
        tox \
        arandr \
        rofi \
        docker \
        playerctl \
        scrub \
        coreutils \
        xclip \
        polybar \
        wget \
        gpg \
        vlc && \

    echo -e "\n${green}Dependencies installed!${nc}\n"
}

############################
## Terminal configuration ##
############################

function configure_zsh_and_p10k {
    echo -e "\n${orange}Configuring ${green}zsh ${orange}and ${green}Powerlevel10k${orange}...${nc}" && \
    sudo usermod --shell /usr/bin/zsh $USER && \
    sudo usermod --shell /usr/bin/zsh root && \

    cp terminal/.zshrc $HOME/.zshrc && \
    cp terminal/.p10k.zsh $HOME/.p10k.zsh && \

    sudo cp terminal/.zshrc /root/.zshrc && \
    sudo cp terminal/.p10k.zsh /root/.p10k.zsh && \

    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
    echo -e "${green}Done!${nc}"
}

function configure_zsh_plugins {
    echo -e "\n${orange}Configuring ${green}zsh plugins${orange}...${nc}" && \
    sudo mkdir -p /usr/share/zsh-autosuggestions && \
    sudo cp terminal/zsh-plugins/zsh-autosuggestions.zsh /usr/share/zsh-autosuggestions && \

    sudo mkdir -p /usr/share/zsh-sudo && \
    sudo cp terminal/zsh-plugins/sudo.plugin.zsh /usr/share/zsh-sudo && \

    sudo cp -r terminal/zsh-plugins/zsh-syntax-highlighting /usr/share && \
    echo -e "${green}Done!${nc}"
}

function configure_ubuntu_terminal {
    echo -e "\n${orange}Installing ${orange}warp-terminal${orange}...${nc}" && \
    sudo apt-get install wget gpg
    wget -qO- https://releases.warp.dev/linux/keys/warp.asc | gpg --dearmor > warpdotdev.gpg
    sudo install -D -o root -g root -m 644 warpdotdev.gpg /etc/apt/keyrings/warpdotdev.gpg
    sudo sh -c "echo 'deb [arch=${DEB_ARCH} signed-by=/etc/apt/keyrings/warpdotdev.gpg] https://releases.warp.dev/linux/deb stable main' > /etc/apt/sources.list.d/warpdotdev.list"
    rm warpdotdev.gpg
    sudo apt update && sudo apt install warp-terminal
    echo -e "${green}warp-terminal${orange} installed!${nc}\n" && \

    echo -e "\n${orange}Installing ${orange}tldr${orange}...${nc}" && \
    sudo apt install -y tldr && \
    echo -e "${green}tldr${orange} installed!${nc}\n" && \

    echo -e "\n${orange}Installing ${orange}lsd${orange}...${nc}" && \
    sudo apt install -y lsd && \
    echo -e "${green}lsd${orange} installed!${nc}\n" && \

    echo -e "\n${orange}Installing ${orange}bat${orange}...${nc}" && \
    wget https://github.com/sharkdp/bat/releases/download/v0.22.1/bat-musl_0.22.1_${DEB_ARCH}.deb && \
    sudo dpkg -i bat-musl_0.22.1_${DEB_ARCH}.deb && \
    rm bat-musl_0.22.1_${DEB_ARCH}.deb && \
    echo -e "${green}bat${orange} installed!${nc}\n" && \

    echo -e "\n${orange}Installing ${orange}fzf${orange}...${nc}" && \
    sudo apt-get install -y fzf && \
    echo -e "${green}fzf${orange} installed!${nc}\n" && \

    configure_zsh_and_p10k && \
    configure_zsh_plugins && \
    configure_kitty && \
    install_hack_nerd_font
}

function configure_fedora_terminal {
    echo -e "\n${orange}Installing ${orange}warp-terminal${orange}...${nc}" && \
    sudo rpm --import https://releases.warp.dev/linux/keys/warp.asc
    sudo sh -c 'echo -e "[warpdotdev]\nname=warpdotdev\nbaseurl=https://releases.warp.dev/linux/rpm/stable\nenabled=1\ngpgcheck=1\ngpgkey=https://releases.warp.dev/linux/keys/warp.asc" > /etc/yum.repos.d/warpdotdev.repo'
    sudo dnf install warp-terminal
    echo -e "${green}warp-terminal${orange} installed!${nc}\n" && \

    echo -e "\n${orange}Installing ${orange}tldr${orange}...${nc}" && \
    sudo dnf install -y tldr && \
    echo -e "${green}tldr${orange} installed!${nc}\n" && \

    echo -e "\n${orange}Installing ${orange}lsd${orange}...${nc}" && \
    sudo dnf install -y lsd && \
    echo -e "${green}lsd${orange} installed!${nc}\n" && \

    echo -e "\n${orange}Installing ${orange}bat${orange}...${nc}" && \
    sudo dnf install -y bat && \
    echo -e "${green}bat${orange} installed!${nc}\n" && \

    echo -e "\n${orange}Installing ${orange}fzf${orange}...${nc}" && \
    sudo dnf install -y fzf && \
    echo -e "${green}fzf${orange} installed!${nc}\n" && \

    configure_zsh_and_p10k && \
    configure_zsh_plugins && \
    configure_kitty && \
    install_hack_nerd_font
}

function install_hack_nerd_font {
    echo -e "\n${orange}Installing ${orange}HackNerdFont${orange}...${nc}" && \
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/Hack.zip && \
    sudo mv Hack.zip /usr/share/fonts && \
    cd /usr/share/fonts && \
    sudo unzip -n Hack.zip && \
    sudo rm Hack.zip && sudo rm LICENSE.md && sudo rm readme.md && \
    echo -e "${green}HackNerdFont${orange} installed!${nc}\n"
}

#####################
## Windows manager ##
#####################

function configure_wm {
    mkdir -p $HOME/.config/i3 && \
    cp i3/config $HOME/.config/i3 && \

    mkdir -p $HOME/.screenlayout && \
    cp i3/.screenlayout/* $HOME/.screenlayout && \

    cp images/candado.png $HOME/Pictures && \

    configure_polybar
}

#########################
## Extra configuration ##
#########################

function configure_polybar {
    mkdir -p $HOME/.config/polybar && \
    cp polybar/* $HOME/.config/polybar && \
    chmod +x $HOME/.config/polybar/launch.sh
}

##########
## Main ##
##########

# Colors
export black='\e[0;30m'
export red='\e[0;31m'
export green='\e[0;32m'
export orange='\e[0;33m'
export blue='\e[0;34m'
export purple='\e[0;35m'
export cyan='\e[0;36m'
export white='\e[0;37m'
export nc='\e[0m' # No Color

# Welcome message
echo -e "${orange}"
echo -e "██╗    ██╗███████╗██╗      ██████╗ ██████╗ ███╗   ███╗███████╗    ████████╗ ██████╗ "
echo -e "██║    ██║██╔════╝██║     ██╔════╝██╔═══██╗████╗ ████║██╔════╝    ╚══██╔══╝██╔═══██╗"
echo -e "██║ █╗ ██║█████╗  ██║     ██║     ██║   ██║██╔████╔██║█████╗         ██║   ██║   ██║"
echo -e "██║███╗██║██╔══╝  ██║     ██║     ██║   ██║██║╚██╔╝██║██╔══╝         ██║   ██║   ██║"
echo -e "╚███╔███╔╝███████╗███████╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗       ██║   ╚██████╔╝"
echo -e " ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝       ╚═╝    ╚═════╝ "
echo -e "                                                                                    "
echo -e "          ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗             "
echo -e "          ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝             "
echo -e "          ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗             "
echo -e "          ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║             "
echo -e "          ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║             "
echo -e "          ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝             "
echo -e ""
echo -e "\n${nc}This project is made by ${red}clarriu97${nc}"
echo -e "\nhttps://github.com/${red}clarriu97${nc}/dotfiles"

# warning message
echo -e "\n${orange}This script will install some packages and will need superuser privileges."
echo -e "Do you want to continue? (y/n)${nc}"
read -r input
if [[ $input == "" ]]; then
    input="y"
fi
if [[ $input != "y" ]]; then
    echo -e "\n${red}Exiting...${nc}"
    exit 1
fi

# distro selection
echo -e "\n${white}What distro are you using? Introduce the number:${nc}"
echo -e "${green}1) Fedora${nc}"
echo -e "${green}2) Ubuntu${nc}"
read -r input
if [[ $input == "1" ]]; then
    distro=1
elif [[ $input == "2" ]]; then
    distro=2
elif [[ $input == "" ]]; then
    distro=1
else
    echo -e "\n${red}Invalid option, exiting...${nc}"
    exit 1
fi

# option selection
echo -e "\n${white}What do you want to install and configure? Introduce the number:${nc}"
echo -e "${green}1) Terminal${nc}"
echo -e "${green}2) Windows manager${nc}"
echo -e "${green}3) Both${nc}"
read -r input
if [[ $input == "1" ]]; then
    option=1
elif [[ $input == "2" ]]; then
    option=2
elif [[ $input == "3" ]]; then
    option=3
elif [[ $input == "" ]]; then
    option=1
else
    echo -e "\n${red}Invalid option, exiting...${nc}"
    exit 1
fi

if [[ $distro == "1" ]]; then
    update_fedora && \
    install_fedora_dependencies && \

    if [[ $option == "1" ]]; then
        configure_fedora_terminal
    elif [[ $option == "2" ]]; then
        configure_wm
    elif [[ $option == "3" ]]; then
        configure_fedora_terminal && \
        configure_wm
    fi
elif [[ $distro == "2" ]]; then
    update_ubuntu && \
    install_ubuntu_dependencies && \

    if [[ $option == "1" ]]; then
        configure_ubuntu_terminal
    elif [[ $option == "2" ]]; then
        configure_wm
    elif [[ $option == "3" ]]; then
        configure_ubuntu_terminal && \
        configure_wm
    fi
fi

echo -e "\n${green}Done!${nc}"
echo -e "\n${orange}Thanks for using this script!${nc}"
