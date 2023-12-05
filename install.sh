#!/bin/bash

PACKAGE="lsd bat exa ripgrep fzf tmux zsh tig neofetch btop util-linux-user"
BREW_PACKAGE="scc"
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
NC='\033[0m'

function add_zsh_plugin() {
    local plugin=$1
    if [ -z "$plugin" ]; then
        echo -e "${RED}Please specify a plugin name${NC}"
        return 1
    fi

    local zshrc="$HOME/.zshrc"
    if [ ! -f "$zshrc" ]; then
        echo "${RED}.zshrc not found${NC}"
        return 1
    fi

    if grep -q "plugins=(.* $plugin .*)" "$zshrc"; then
        echo "${YELLOW}Plugin $plugin already added.${NC}"
        return 1
    fi

    # Add the plugin to the plugins array
    sed -i "/^plugins=(/s/)$/ $plugin)/" "$zshrc"

    echo "Plugin $plugin added to .zshrc. Please restart your terminal or source .zshrc to apply changes."
}

function other_install() {
    # oh-my-zsh
    echo -e "${GREEN}istalling oh-my-zsh and plugins${NC}"
    echo 'exit 0' | $(sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)")
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    add_zsh_plugin zsh-syntax-highlighting

    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    add_zsh_plugin zsh-autosuggestions

    # tmux
    echo -e  "${GREEN}installing tmux and plugins${NC}"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    mkdir -p $HOME/.config/tmux
    cp tmux.conf $HOME/.config/tmux/tmux.conf

    # kitty
    mkdir -p $HOME/.local/
    echo -e "${GREEN}installing kitty${NC}"
    # curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    mkdir -p $HOME/.config/kitty && cp kitty.conf $HOME/.config/kitty/kitty.conf

    # cdsearch
    echo -e "${GREEN}installing cdsearch${NC}"
    mkdir -p $HOME/.local/bin
    cp cdsearch $HOME/.local/bin/cdsearch
    echo 'alias cdsearch=". cdsearch"' >> $HOME/.zshrc
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.zshrc
}

function install_mac() {
    brew install $PACKAGE
    brew install $BREW_PACKAGE
    other_install
}

function install_fedora() {
    sudo dnf install $PACKAGE -y
    sudo dnf install kitty -y
    which brew && brew install $BREW_PACKAGE
    other_install
    sudo chsh -s $(which zsh)
}

function install_arch() {
    sudo pacman -S $PACKAGE
}
#
# Get OS information
osInfo=$(uname -a)
echo $osInfo

# Switch case to determine OS and run the corresponding function
case "$osInfo" in
    *fedora*|*fc3*)
        install_fedora
        ;;
    *arch*|*Manjaro*|*Arch*|*manjaro*)
        install_arch
        ;;
    *Darwin*)
        install_mac
        ;;
    *)
        echo "OS not recognized"
        ;;
esac
