#!/bin/bash

PACKAGE="lsd bat exa ripgrep fzf tmux zsh tig neofetch btop"
BREW_PACKAGE="scc"

function add_zsh_plugin() {
    local plugin=$1
    if [ -z "$plugin" ]; then
        echo "Please specify a plugin name"
        return 1
    fi

    local zshrc="$HOME/.zshrc"
    if [ ! -f "$zshrc" ]; then
        echo ".zshrc not found"
        return 1
    fi

    if grep -q "plugins=(.* $plugin .*)" "$zshrc"; then
        echo "Plugin $plugin already added."
        return 1
    fi

    # Add the plugin to the plugins array
    sed -i "/^plugins=(/s/)$/ $plugin)/" "$zshrc"

    echo "Plugin $plugin added to .zshrc. Please restart your terminal or source .zshrc to apply changes."
}

function other_install() {
    # oh-my-zsh
    echo 'exit 0' | $(sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)")
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    add_zsh_plugin zsh-syntax-highlighting

    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    add_zsh_plugin zsh-autosuggestions

    # tmux
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    cp ./tmux.conf $HOME/.config/tmux/tmux.conf

    # kitty
    # curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

    # cdsearch
    cp cdsearch $HOME/.local/bin/cdsearch
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.zshrc
}

function install_mac() {
    brew install $PACKAGE
    brew install $BREW_PACKAGE
    other_install
}

function install_fedora() {
    sudo dnf install $PACKAGE
    which brew && brew install $BREW_PACKAGE
    other_install
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
    *fedora*)
        install_fedora
        ;;
    *arch*|*Manjaro*|*Arch*|*manjaro*|*fc3*)
        install_arch
        ;;
    *Darwin*)
        install_mac
        ;;
    *)
        echo "OS not recognized"
        ;;
esac