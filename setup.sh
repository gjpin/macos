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
    sops \
    age

# Install casks
brew install --cask spotify
brew install --cask brave-browser
brew install --cask obsidian
brew install --cask orcaslicer
brew install --cask freecad
brew install --cask moonlight
brew install --cask discord
brew install --cask thunderbird
brew install --cask bitwarden

################################################
##### SSH
################################################

mkdir -p ${HOME}/.ssh

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
export PATH="/opt/homebrew/opt/{make,libtool,gsed,grep,gpatch,gnu-which,gnu-tar,gnu-sed,gnu-indent,gawk,findutils,ed,coreutils}/libexec/gnubin:${PATH}"

# GNU utils — manpages
export MANPATH="/opt/homebrew/opt/{make,libtool,gsed,grep,gpatch,gnu-which,gnu-tar,gnu-sed,gnu-indent,gawk,findutils,ed,coreutils}/libexec/gnuman:${MANPATH}"
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
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"\>
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
            <dict>
                <key>NetworkState</key>
                <true/>
            </dict>
        <key>RunAtLoad</key>
        <true/>
        <key>StandardErrorPath</key>
        <string>/opt/homebrew/var/log/wireguard.err</string>
        <key>EnvironmentVariables</key>
        <dict>
            <key>PATH</key>
            <!-- Adds in user-specific and Homebrew bin directories to start of PATH -->
            <string>${HOME}/.local/bin:/opt/homebrew/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
        </dict>
    </dict>
</plist>
EOF

# Enable LaunchDaemon
sudo launchctl enable system/com.wireguard.wg0
sudo launchctl bootstrap system /Library/LaunchDaemons/com.wireguard.wg0.plist

################################################
##### Podman
################################################

# Install Podman and Podman desktop
brew install podman
brew install --cask podman-desktop

# Set Podman VM specs
podman machine init --cpus 4 --memory 8192

################################################
##### zsh
################################################

# Update account to use ZSH
chsh -s /bin/zsh

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

################################################
##### Kubernetes / Cloud
################################################

# Install Kubernetes tools
brew install kubernetes-cli helm kubectx k9s cilium-cli argocd
brew install --cask headlamp

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

# Install minikube
brew install minikube vfkit
minikube config set driver vfkit
minikube config set cpus 4
minikube config set memory 8192

################################################
##### Visual Studio Code
################################################

# Install VSCode
brew install --cask visual-studio-code

# Configure VSCode
mkdir -p "${HOME}/Library/Application Support/Code/User"
curl https://raw.githubusercontent.com/gjpin/macos/main/configs/vscode/settings.json -o "${HOME}/Library/Application Support/Code/User/settings.json"

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
##### Bluesnooze (Sleeping Mac = Bluetooth off)
################################################

# References:
# https://github.com/odlp/bluesnooze

# Install Bluesnooze
brew install --cask bluesnooze

# Hide Bluesnooze icon
defaults write com.oliverpeate.Bluesnooze hideIcon -bool true && killall Bluesnooze

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
##### FDE
################################################

# enable FileVault
sudo fdesetup enable