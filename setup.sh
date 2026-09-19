#!/usr/bin/env bash

################################################
##### Mac dev tools
################################################

# Install Xcode Command Line Tools
xcode-select --install

################################################
##### brew
################################################

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add homebrew to the path
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ${HOME}/.zprofile

# Disable brew analytics
curl https://raw.githubusercontent.com/gjpin/macos/main/configs/zsh/.zshenv -o ${HOME}/.zshenv

# Make brew available now
source "${HOME}/.zshenv"
eval "$(/opt/homebrew/bin/brew shellenv)"

# Fix brew permissions
sudo chown -R $USER /opt/homebrew/var/log
chmod u+w /opt/homebrew/var/log

tee ${HOME}/.local/bin/brew-update << 'EOF'
# Update all brew packages
brew update && brew upgrade --greedy && brew cleanup
EOF

chmod +x ${HOME}/.local/bin/brew-update

################################################
##### zsh
################################################

# Disable "last login" message
touch ${HOME}/.hushlogin

# Install ZSH plugins
brew install \
    zsh-syntax-highlighting \
    zsh-completions \
    zsh-autosuggestions \
    fzf-tab

# Rebuild the completion cache on the next interactive zsh startup
rm -f "${HOME}/.zcompdump"

# Fix insecure Homebrew zsh completion directory permissions
chmod go-w '/opt/homebrew/share'
chmod -R go-w '/opt/homebrew/share/zsh'

# Install Oh My Posh
brew install oh-my-posh

# Install the local Oh My Posh theme
curl https://raw.githubusercontent.com/gjpin/macos/main/configs/zsh/.omp.json -o ${HOME}/.omp.json

# Import ZSH configs
curl https://raw.githubusercontent.com/gjpin/macos/main/configs/zsh/.zshrc -o ${HOME}/.zshrc

################################################
##### Common applications and directories
################################################

# Create common directories
mkdir -p \
    ${HOME}/.configs \
    ${HOME}/.zshrc.d \
    ${HOME}/.local/bin \
    ${HOME}/src    

# Install common applications
brew install \
    git \
    lazygit \
    ripgrep \
    fd \
    yq \
    jq \
    wget \
    zstd \
    iproute2mac \
    fzf \
    pipx \
    jsonnet \
    cmake \
    make \
    gnupg \
    age \
    sops \
    rsync \
    argon2 \
    bcrypt

# Install casks
brew install --cask spotify
brew install --cask brave-browser
brew install --cask obsidian
brew install --cask bitwarden
brew install --cask lulu
brew install --cask handy
brew install --cask caffeine

# Install 3D printing apps
brew install --cask orcaslicer
brew install --cask freecad

################################################
##### Development
################################################

# Set default branch name
git config --global init.defaultBranch main

# Install and configure herdr
brew install herdr
mkdir -p ${HOME}/.config/herdr
curl https://raw.githubusercontent.com/gjpin/macos/main/configs/herdr/config.toml -o ${HOME}/.config/herdr/config.toml

################################################
##### SSH
################################################

# Create SSH directory
mkdir -p ${HOME}/.ssh

# Copy SSH config file
tee ${HOME}/.ssh/config << 'EOF'
Host *
  UseKeychain yes
  AddKeysToAgent yes
  IdentityFile ~/.ssh/id_ecdsa
EOF

################################################
##### Firewall
################################################

# Enable MacOS firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setblockall on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned off
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on

################################################
##### Syncthing
################################################

# Install syncthing
brew install syncthing

# Automatically start syncthing
brew services start syncthing

################################################
##### GNU utils
################################################

# References:
# https://gist.github.com/skyzyx/3438280b18e4f7c490db8a2a2ca0b9da

brew install autoconf bash binutils coreutils diffutils ed findutils flex gawk \
    gnu-indent gnu-sed gnu-tar gnu-which gpatch grep gzip less m4 make nano \
    screen watch wdiff wget zip

# Add GNU utils to path
tee ${HOME}/.zshrc.d/gnu-utils << 'EOF'
# GNU utils — bin
# for pkg in make libtool grep gpatch gnu-which gnu-tar gnu-sed gnu-indent gawk findutils ed coreutils; do

for pkg in grep gnu-sed coreutils; do
  PATH="/opt/homebrew/opt/$pkg/libexec/gnubin:$PATH"
done
export PATH

# GNU utils — manpages
for pkg in grep gnu-sed coreutils; do
  PATH="/opt/homebrew/opt/$pkg/libexec/gnuman:$PATH"
done
export MANPATH
EOF

################################################
##### Ghostty
################################################

# References:
# https://antkowiak.it/en/enable-touchid-for-sudo-in-iterm-2/

# Install and configure Ghostty
brew install --cask ghostty

tee "$HOME/.zshrc.d/zsh-syntax-highlighting" << 'EOF'
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[comment]='fg=#cccccc'
EOF

mkdir -p "~/.config/ghostty"
curl https://raw.githubusercontent.com/gjpin/macos/main/configs/ghostty/config.ghostty -o "${HOME}/.config/ghostty/config.ghostty"

# Enable TouchID for sudo in terminal
sudo gsed -i '1 a auth       sufficient     pam_tid.so' /etc/pam.d/sudo

################################################
##### Wireguard
################################################

# Install Wireguard tools
brew install wireguard-tools

# Create wireguard folder
sudo mkdir /etc/wireguard

# Configure LaunchDaemon for wg0
sudo tee /Library/LaunchDaemons/com.wireguard.wg0.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.wireguard.wg0</string>

    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/bin/wg-quick</string>
        <string>up</string>
        <string>/etc/wireguard/wg0.conf</string>
    </array>

    <key>KeepAlive</key>
    <false/>

    <key>RunAtLoad</key>
    <true/>

    <key>StartInterval</key>
    <integer>10</integer>

    <key>StandardErrorPath</key>
    <string>/tmp/wireguard.err</string>

    <key>StandardOutPath</key>
    <string>/tmp/wireguard.out</string>

    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
</dict>
</plist>
EOF

# Enable LaunchDaemon
sudo launchctl bootstrap system /Library/LaunchDaemons/com.wireguard.wg0.plist
sudo launchctl enable system/com.wireguard.wg0

################################################
##### Docker (Lima)
################################################

# References:
# https://lima-vm.io/docs/examples/containers/docker/
# https://lima-vm.io/docs/usage/autostart/
# https://docs.docker.com/engine/manage-resources/contexts/

# Install the Docker CLI and Lima. Docker runs inside Lima; the Docker CLI
# connects through a persistent context rather than a shell-specific DOCKER_HOST.
brew install \
    docker \
    docker-buildx \
    docker-compose \
    docker-credential-helper \
    lima

# Configure Docker
mkdir -p ${HOME}/.docker
curl https://raw.githubusercontent.com/gjpin/macos/main/configs/docker/config.json -o "${HOME}/.docker/config.json"

# Create and configure Docker VM
limactl create \
    --name=docker \
    --cpus=4 \
    --memory=8 \
    template:docker

# Start Docker VM
limactl start docker

# Autostart Docker VM on login
limactl autostart enable --condition=login docker

# Create and use Docker context for Lima
docker context create lima-docker --docker "host=unix:///Users/${USER}/.lima/docker/sock/docker.sock"
docker context use lima-docker

################################################
##### Kubernetes / Cloud
################################################

# Install Kubernetes tools
brew install kubernetes-cli helm kubectx k9s talosctl
# brew install --cask headlamp

tee ${HOME}/.zshrc.d/kubernetes << EOF
# Aliases
alias k="kubectl"
alias kx="kubectx"
alias ks="kubens"

# Autocompletion
autoload -Uz compinit
compinit
source <(kubectl completion zsh)
EOF

# Install OpenTofu
brew install opentofu

# Install Kind
brew install kind

# Install minikube and vfkit
brew install minikube vfkit
minikube config set driver vfkit

# Install Packer
brew tap hashicorp/tap
brew install hashicorp/tap/packer

################################################
##### Visual Studio Code
################################################

# Install VSCode
brew install --cask visual-studio-code

# Configure VSCode
mkdir -p "${HOME}/Library/Application Support/Code/User"
curl https://raw.githubusercontent.com/gjpin/macos/main/configs/vscode/settings.json -o "${HOME}/Library/Application Support/Code/User/settings.json"

# Install extensions
code --install-extension ms-vscode-remote.remote-ssh
code --install-extension ms-vscode-remote.remote-ssh-edit
code --install-extension ms-vscode.remote-explorer
code --install-extension ms-vscode-remote.remote-containers

################################################
##### Fonts
################################################

# Install fonts
brew install --cask \
    font-meslo-lg-nerd-font \
    font-fira-code-nerd-font

################################################
##### Firefox
################################################

# Install Firefox
brew install --cask firefox

# Temporarily open Firefox to create profiles
open /Applications/Firefox.app --args --headless
sleep 5
killall firefox

# Set Firefox profile path
FIREFOX_PROFILE_PATH=$(realpath ${HOME}/Library/Application\ Support/Firefox/Profiles/*.default-release)

# Import extensions
mkdir -p "${FIREFOX_PROFILE_PATH}/extensions"
curl https://addons.mozilla.org/firefox/downloads/file/4003969/ublock_origin-latest.xpi -o "${FIREFOX_PROFILE_PATH}/extensions/uBlock0@raymondhill.net.xpi"
curl https://addons.mozilla.org/firefox/downloads/file/4018008/bitwarden_password_manager-latest.xpi -o "${FIREFOX_PROFILE_PATH}/extensions/{446900e4-71c2-419f-a6a7-df9c091e268b}.xpi"
curl https://addons.mozilla.org/firefox/downloads/file/3998783/floccus-latest.xpi -o "${FIREFOX_PROFILE_PATH}/extensions/floccus@handmadeideas.org.xpi"
curl https://addons.mozilla.org/firefox/downloads/file/3932862/multi_account_containers-latest.xpi -o "${FIREFOX_PROFILE_PATH}/extensions/@testpilot-containers.xpi"

# Import Firefox configs
curl https://raw.githubusercontent.com/gjpin/macos/main/configs/firefox/user.js -o "${FIREFOX_PROFILE_PATH}/user.js"

################################################
##### System Preferences
################################################

# References:
# https://pawelgrzybek.com/change-macos-user-preferences-via-command-line/
# https://github.com/pawelgrzybek/dotfiles/blob/master/setup-macos.sh

# Tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# Finder > View > Show Path Bar
defaults write com.apple.finder ShowPathbar -bool true

# Disable automatic rearrangement of Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

################################################
##### Full Disk Encryption
################################################

# Enable FileVault
sudo fdesetup enable
