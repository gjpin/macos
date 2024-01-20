################################################
##### brew
################################################

# Install Xcode Command Line Tools
xcode-select --install

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add homebrew to the path
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ${HOME}/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Disable brew analytics
tee ${HOME}/.zshenv << EOF
# Disable brew analytics
export HOMEBREW_NO_ANALYTICS=1
EOF

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
    zstd

# Install windows management tools
brew install --cask rectangle alt-tab

# Install Google Chrome
brew install --cask google-chrome

# Install Spotify
brew install --cask spotify

################################################
##### GNU utils
################################################

# References:
# https://gist.github.com/skyzyx/3438280b18e4f7c490db8a2a2ca0b9da

brew install autoconf bash binutils coreutils diffutils ed findutils flex gawk \
    gnu-indent gnu-sed gnu-tar gnu-which gpatch grep gzip less m4 make nano \
    screen watch wdiff wget zip

tee ${HOME}/.zshrc.d/gnu-utils << 'EOF'
if type brew &>/dev/null; then
  NEWPATH=${PATH}
  for d in /opt/homebrew/opt/*/libexec/gnubin; do NEWPATH=$d:$NEWPATH; done
  export PATH=$(echo ${NEWPATH} | tr ':' '\n' | cat -n | sort -uk2 | sort -n | cut -f2- | xargs | tr ' ' ':')
fi
EOF

################################################
##### iTerm2
################################################

# References:
# https://antkowiak.it/en/enable-touchid-for-sudo-in-iterm-2/

# Install iTerm2
brew install --cask iterm2

# Download and import iTerm2 configs
defaults import com.googlecode.iterm2 ${HOME}/iterm2.plist
curl https://raw.githubusercontent.com/gjpin/macos/main/configs/iterm2/iterm2.plist -o ${HOME}/iterm2.plist
rm -f ${HOME}/iterm2.plist

################################################
##### Wireguard
################################################

# Install Wireguard tools
brew install wireguard-tools

# Create wireguard folder
sudo mkdir /etc/wireguard

# Configure LaunchDaemon for wg0
sudo tee /Library/LaunchDaemons/com.wireguard.wg0.plist << 'EOF'
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
            <string>/Users/slowe/.local/bin:/opt/homebrew/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
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

# Install Oh-My-Zsh
# https://github.com/ohmyzsh/ohmyzsh#manual-installation
git clone https://github.com/ohmyzsh/ohmyzsh.git ${HOME}/.oh-my-zsh

# Install powerlevel10k zsh theme
# https://github.com/romkatv/powerlevel10k#oh-my-zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${HOME}/.oh-my-zsh/custom/themes/powerlevel10k
curl https://raw.githubusercontent.com/gjpin/macos/main/configs/zsh/.p10k.zsh -o ${HOME}/.p10k.zsh

# Import ZSH configs
curl https://raw.githubusercontent.com/gjpin/macos/main/configs/zsh/.zshrc -o ${HOME}/.zshrc

################################################
##### Kubernetes
################################################

# Install Kubernetes tools
brew install kubernetes-cli helm kubectx k9s cilium-cli
brew install --cask openlens

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

################################################
##### keybindings
################################################

# Custom key bindings in zsh
tee ${HOME}/.zshrc.d/keybindings << EOF
bindkey "[D" backward-word
bindkey "[C" forward-word
bindkey "^[a" beginning-of-line
bindkey "^[e" end-of-line
EOF

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

# Add fonts tap
brew tap homebrew/cask-fonts

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
mkdir -p ${FIREFOX_PROFILE_PATH}/extensions
curl https://addons.mozilla.org/firefox/downloads/file/4003969/ublock_origin-latest.xpi -o ${FIREFOX_PROFILE_PATH}/extensions/uBlock0@raymondhill.net.xpi
curl https://addons.mozilla.org/firefox/downloads/file/4018008/bitwarden_password_manager-latest.xpi -o ${FIREFOX_PROFILE_PATH}/extensions/{446900e4-71c2-419f-a6a7-df9c091e268b}.xpi
curl https://addons.mozilla.org/firefox/downloads/file/3998783/floccus-latest.xpi -o ${FIREFOX_PROFILE_PATH}/extensions/floccus@handmadeideas.org.xpi
curl https://addons.mozilla.org/firefox/downloads/file/3932862/multi_account_containers-latest.xpi -o ${FIREFOX_PROFILE_PATH}/extensions/@testpilot-containers.xpi

# Import Firefox configs
curl https://raw.githubusercontent.com/gjpin/macos/main/configs/firefox/user.js -o ${FIREFOX_PROFILE_PATH}/user.js

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

# Enable Reduce motion
defaults write com.apple.Accessibility ReduceMotionEnabled -bool true

# Appearance
defaults write -globalDomain AppleInterfaceStyleSwitchesAutomatically -bool true

# Menu Bar
defaults write "com.apple.controlcenter" "NSStatusItem Visible Bluetooth" -bool true
defaults write "com.apple.airplay" showInMenuBarIfPresent -bool false
defaults write "com.apple.controlcenter" "NSStatusItem Visible Sound" -bool true
defaults -currentHost write com.apple.Spotlight MenuItemHidden -int 1

# Ask Siri
defaults write com.apple.Siri SiriPrefStashedStatusMenuVisible -bool false
defaults write com.apple.Siri VoiceTriggerUserEnabled -bool false

# Tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show warning before changing an extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Finder > View > Show Path Bar
defaults write com.apple.finder ShowPathbar -bool true

# Disable automatic rearrangement of Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false