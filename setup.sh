
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
    echo -e "\n${orange}Installing dependencies...${nc}\n" && \
    echo -e "Installing ${orange}Visual Studio Code${cyan}...${nc}" && \
	sudo apt install -y software-properties-common apt-transport-https wget && \
	wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add - && \
	sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" && \
	sudo apt install -y code && \
	echo -e "${green}Visual Studio Code${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}neofetch${cyan}...${nc}" && \
    sudo apt install -y neofetch && \
    echo -e "${green}neofetch${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}Brave browser${cyan}...${nc}" && \
	sudo apt install -y apt-transport-https curl && \
	sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && \
	echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list && \
    update_ubuntu && \
	sudo apt install -y brave-browser && \
	echo -e "${green}Brave browser${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}dpkg${cyan}...${nc}" && \
    sudo apt install -y dpkg && \
    echo -e "${green}dpkg${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}zsh${cyan}...${nc}" && \
    sudo apt install -y zsh && \
    echo -e "${green}zsh${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}flameshot${cyan}...${nc}" && \
    sudo apt install -y flameshot && \
    echo -e "${green}flameshot${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}i3wm${cyan}...${nc}" && \
    sudo apt install -y i3 && \
    echo -e "${green}i3wm${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}tox${cyan}...${nc}" && \
    pip install tox && \
    echo -e "${green}tox${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}arandr${cyan}...${nc}" && \
    sudo apt install -y arandr && \
    echo -e "${green}arandr${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}rofi${cyan}...${nc}" && \
    sudo apt install -y rofi && \
    echo -e "${green}rofi${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}docker${cyan}...${nc}" && \
	sudo apt-get install \
		ca-certificates \
		curl \
		gnupg \
		lsb-release && \
	sudo mkdir -p /etc/apt/keyrings && \
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
	sudo groupadd docker && \
	sudo usermod -aG docker $USER && \
	echo -e "${green}docker${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}playerctl${cyan}...${nc}" && \
    sudo apt install -y playerctl && \
    echo -e "${green}playerctl${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}scrub${cyan}...${nc}" && \
    sudo apt install -y scrub && \
    echo -e "${green}scrub${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}coreutils${cyan}...${nc}" && \
    sudo apt install -y coreutils && \
    echo -e "${green}coreutils${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}xclip${cyan}...${nc}" && \
    sudo apt install -y xclip && \
    echo -e "${green}xclip${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}polybar${cyan}...${nc}" && \
    sudo apt install -y polybar && \
    echo -e "${green}polybar${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}vlc${cyan}...${nc}" && \
    sudo apt install -y vlc && \
    echo -e "${green}vlc${cyan} installed!${nc}\n"
}

function install_fedora_dependencies {
    echo -e "\n${orange}Installing dependencies...${nc}\n" && \
    echo -e "Installing ${orange}Visual Studio Code${cyan}...${nc}" && \
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
	sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo' && \
	dnf check-update && \
	sudo dnf install -y code && \
    echo -e "${green}Visual Studio Code${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}neofetch${cyan}...${nc}" && \
    sudo dnf install -y neofetch && \
    echo -e "${green}neofetch${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}Brave browser${cyan}...${nc}" && \
    sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/ && \
	sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc && \
	sudo dnf install -y brave-browser && \
    echo -e "${green}Brave browser${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}dpkg${cyan}...${nc}" && \
    sudo dnf install -y dpkg && \
    echo -e "${green}dpkg${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}zsh${cyan}...${nc}" && \
    sudo dnf install -y zsh && \
    echo -e "${green}zsh${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}flameshot${cyan}...${nc}" && \
    sudo dnf install -y flameshot && \
    echo -e "${green}flameshot${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}i3wm${cyan}...${nc}" && \
    sudo dnf install -y i3 && \
    echo -e "${green}i3wm${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}tox${cyan}...${nc}" && \
    pip install tox && \
    echo -e "${green}tox${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}arandr${cyan}...${nc}" && \
    sudo dnf install -y arandr && \
    echo -e "${green}arandr${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}rofi${cyan}...${nc}" && \
    sudo dnf install -y rofi && \
    echo -e "${green}rofi${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}docker${cyan}...${nc}" && \
    sudo dnf install -y dnf-plugins-core && \
	sudo dnf config-manager \
		--add-repo \
		https://download.docker.com/linux/fedora/docker-ce.repo && \
	sudo dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin && \

    if ! grep -q docker /etc/group; then
        sudo groupadd docker
    fi
    if ! groups $USER | grep -q '\bdocker\b'; then
        sudo usermod -aG docker $USER
    fi
    echo -e "${green}docker${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}playerctl${cyan}...${nc}" && \
    sudo dnf install -y playerctl && \
    echo -e "${green}playerctl${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}scrub${cyan}...${nc}" && \
    sudo dnf install -y scrub && \
    echo -e "${green}scrub${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}coreutils${cyan}...${nc}" && \
    sudo dnf install -y coreutils && \
    echo -e "${green}coreutils${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}xclip${cyan}...${nc}" && \
    sudo dnf install -y xclip && \
    echo -e "${green}xclip${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}polybar${cyan}...${nc}" && \
    sudo dnf install -y polybar && \
    echo -e "${green}polybar${cyan} installed!${nc}\n" && \

    echo -e "Installing ${orange}vlc${cyan}...${nc}" && \
    sudo dnf install -y vlc && \
    echo -e "${green}vlc${cyan} installed!${nc}\n"
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

function configure_kitty {
    echo -e "\n${orange}Configuring ${green}Kitty${orange}...${nc}" && \
    mkdir -p $HOME/.config/kitty && \
    cp terminal/color.ini $HOME/.config/kitty && \
    cp terminal/kitty.conf $HOME/.config/kitty && \
    echo -e "${green}Done!${nc}"
}

function configure_ubuntu_terminal {
    echo -e "\n${orange}Installing ${orange}kitty${orange}...${nc}" && \
    sudo add-apt-repository universe && \
    sudo apt update -y && \
    sudo apt install -y kitty && \
    echo -e "${green}kitty${orange} installed!${nc}\n" && \

    echo -e "\n${orange}Installing ${orange}tldr${orange}...${nc}" && \
    sudo apt install -y tldr && \
    echo -e "${green}tldr${orange} installed!${nc}\n" && \

    echo -e "\n${orange}Installing ${orange}lsd${orange}...${nc}" && \
    wget https://github.com/Peltoche/lsd/releases/download/0.23.1/lsd-musl_0.23.1_i686.deb && \
    sudo dpkg -i lsd-musl_0.23.1_i686.deb && \
    rm lsd-musl_0.23.1_i686.deb && \
    echo -e "${green}lsd${orange} installed!${nc}\n" && \

    echo -e "\n${orange}Installing ${orange}bat${orange}...${nc}" && \
    wget https://github.com/sharkdp/bat/releases/download/v0.22.1/bat-musl_0.22.1_amd64.deb && \
    sudo dpkg -i bat-musl_0.22.1_amd64.deb && \
    rm bat-musl_0.22.1_amd64.deb && \
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
    echo -e "\n${orange}Installing ${orange}kitty${orange}...${nc}" && \
    sudo dnf install -y kitty && \
    echo -e "${green}kitty${orange} installed!${nc}\n" && \

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
    cp -r i3/scripts $HOME/.config/i3 && \

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
