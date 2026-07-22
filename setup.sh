#!/usr/bin/env bash

# Resolve repository-owned files relative to this script, regardless of the
# directory from which setup.sh is invoked.
SETUP_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

################################################
##### Dev and compatibility tools
################################################

# Install Xcode Command Line Tools
xcode-select --install

# Install Rosetta
softwareupdate --install-rosetta --agree-to-license

################################################
##### brew
################################################

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add homebrew to the path
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ${HOME}/.zprofile

# Disable brew analytics
tee ${HOME}/.zshenv << EOF
# Disable brew analytics
export HOMEBREW_NO_ANALYTICS=1

# Disable brew update hint
export HOMEBREW_NO_ENV_HINTS=1
EOF

# Make brew available now
eval "$(/opt/homebrew/bin/brew shellenv)"

# Fix brew permissions
sudo chown -R $USER /opt/homebrew/var/log
chmod u+w /opt/homebrew/var/log

################################################
##### Common applications
################################################

# Disable "last login" message
touch ${HOME}/.hushlogin

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
    gnupg

# Install casks
brew install --cask spotify
brew install --cask brave-browser
brew install --cask obsidian
brew install --cask thunderbird
brew install --cask bitwarden
brew install --cask temurin
brew install --cask lulu
brew install --cask lm-studio
brew install --cask handy

# Install 3D printing apps
brew install --cask orcaslicer
brew install --cask freecad

################################################
##### Agents
################################################

# Install safehouse
git clone https://github.com/gjpin/agent-safehouse.git ~/src/agent-safehouse
cp ~/src/agent-safehouse/dist/safehouse.sh ~/.local/bin/safehouse
chmod +x ~/.local/bin/safehouse

# Configure Agent Safehouse
mkdir -p ${HOME}/.config/agent-safehouse
tee ${HOME}/.config/agent-safehouse/local-overrides.sb << 'EOF'
;; Permanent access to ~/src
(allow file-read* file-write*
  (home-subpath "/src")
)
EOF

tee ${HOME}/.zshrc.d/safehouse << 'EOF'
# https://agent-safehouse.dev/docs/getting-started.html#shell-functions-recommended

# Base
export SAFEHOUSE_APPEND_PROFILE="$HOME/.config/agent-safehouse/local-overrides.sb"
safe() { safehouse --append-profile="$SAFEHOUSE_APPEND_PROFILE" "$@"; }

# Profiles
codex()    { safe codex --dangerously-bypass-approvals-and-sandbox "$@"; }
opencode() { safe -- OPENCODE_PERMISSION='{"*":"allow"}' opencode "$@"; }
cursor()   { safe --enable=ssh -- /Applications/Cursor.app/Contents/MacOS/Cursor --no-sandbox "$@"; }
EOF

# Create Cursor Safehouse Application
cp -R "configs/Cursor Safehouse.app" ~/Applications/

# Install Agents
brew install opencode
brew install --cask codex
brew install --cask cursor

################################################
##### Development
################################################

# Set default branch name
git config --global init.defaultBranch main

# Install Bash tools
brew install bats-core shfmt

# Install Python tools
brew install ruff ty uv

# Install golang
brew install go

tee ${HOME}/.zshrc.d/go << EOF
export GOPATH=${HOME}/.go
PATH="$(go env GOPATH)/bin:\$PATH"
EOF

# Install node and package managers
brew install node npm pnpm

# Configure npm
npm config set ignore-scripts true

mkdir -p ${HOME}/.npm-global

npm config set prefix "${HOME}/.npm-global"

tee ${HOME}/.zshrc.d/npm << 'EOF'
export PATH=$HOME/.npm-global/bin:$PATH
EOF

# Configure pnpm
mkdir -p ${HOME}/.pnpm/bin

tee ${HOME}/.zshrc.d/pnpm << 'EOF'
export PNPM_HOME="$HOME/.pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
EOF

# Install Temurin JDK
brew install --cask temurin

################################################
##### Android
################################################

# Install Android tools
brew install --cask android-commandlinetools
brew install --cask android-platform-tools
brew install vineflower # alternative: fernflower
brew install jadx
brew install apktool

# Install dex2jar
# https://github.com/ThexXTURBOXx/dex2jar
source ./dex2jar-manager.sh && install_dex2jar
cp ./dex2jar-manager.sh ${HOME}/.local/bin/dex2jar-manager.sh && chmod +x ${HOME}/.local/bin/dex2jar-manager.sh

# Required for agent skill
tee ${HOME}/.zshrc.d/vineflower << 'EOF'
export FERNFLOWER_JAR_PATH="/opt/homebrew/bin/vineflower"
EOF

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
##### iTerm2
################################################

# References:
# https://antkowiak.it/en/enable-touchid-for-sudo-in-iterm-2/

# Install iTerm2
brew install --cask iterm2

# Enable TouchID for sudo in iTerm2
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
##### Podman
################################################

# References:
# https://docs.podman.io/en/v5.8.1/markdown/podman-machine-init.1.html
# https://github.com/containers/krunkit

# Install krunkit
# brew tap slp/krun
# brew install krunkit

# Install Podman
brew install podman podman-compose

# Install Podman desktop
brew install --cask podman-desktop

# Init podman machine
podman machine init \
    --cpus 4 \
    --memory 8192 \
    --now

# Install system helper service (provides better Docker compatibility)
sudo "$(brew --prefix)/opt/podman/bin/podman-mac-helper" install

# Set Docker host path
tee ${HOME}/.zshrc.d/podman << EOF
alias docker=podman
EOF

################################################
##### zsh
################################################

# Install powerlevel10k zsh theme
curl https://raw.githubusercontent.com/gjpin/macos/main/configs/zsh/.p10k.zsh -o ${HOME}/.p10k.zsh

# Import ZSH configs
curl https://raw.githubusercontent.com/gjpin/macos/main/configs/zsh/.zshrc -o ${HOME}/.zshrc

# Add ~/.local/bin to the path
tee ${HOME}/.zshrc.d/local-bin << 'EOF'
# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH
EOF

# Updater helper
tee ${HOME}/.local/bin/update-all << 'EOF'
#!/usr/bin/env zsh

# Update brew repos
brew update

# Update brew packages
brew upgrade

# Update pip packages
uv tool upgrade --all

# Update pnpm packages
# pnpm up -g --latest

# Update dex2jar
${HOME}/.local/bin/dex2jar-manager.sh update
EOF

chmod +x ${HOME}/.local/bin/update-all

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

# Install Packer
brew tap hashicorp/tap
brew install hashicorp/tap/packer

# Install minikube
# brew install minikube vfkit
# minikube config set driver vfkit
# minikube config set cpus 2
# minikube config set memory 4096

################################################
##### Zed
################################################

# Install Zed
brew install --cask zed

# Configure Zed
mkdir -p ${HOME}/.config/zed/themes
curl https://raw.githubusercontent.com/gjpin/macos/main/configs/zed/settings.json -o ${HOME}/.config/zed/settings.json

# Download VSCode Dark Modern theme
curl https://raw.githubusercontent.com/kcamcam/vscode_dark_modern.zed/refs/heads/main/themes/vscode-dark-modern.json -o ${HOME}/.config/zed/themes/vscode-dark-modern.json

################################################
##### Visual Studio Code
################################################

# Install VSCode
brew install --cask visual-studio-code

# Configure VSCode
mkdir -p "${HOME}/Library/Application Support/Code/User"
curl https://raw.githubusercontent.com/gjpin/macos/main/configs/vscode/settings.json -o "${HOME}/Library/Application Support/Code/User/settings.json"

# Install extensions
code --install-extension ms-vscode-remote.remote-containers
# code --install-extension kilocode.kilo-code
# code --install-extension golang.go
# code --install-extension astral-sh.ty
# code --install-extension charliermarsh.ruff
# code --install-extension ms-vscode.remote-explorer
# code --install-extension ms-vscode-remote.remote-ssh

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
