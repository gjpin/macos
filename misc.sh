################################################
##### Preferences
################################################

# Appearance
defaults write -globalDomain AppleInterfaceStyleSwitchesAutomatically -bool true

# Menu Bar
defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool true
defaults write com.apple.airplay showInMenuBarIfPresent -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -bool true
defaults -currentHost write com.apple.Spotlight MenuItemHidden -int 1

# Show warning before changing an extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

################################################
##### Python
################################################

# Install MiniConda
curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh
sh Miniconda3-latest-MacOSX-arm64.sh
rm -f Miniconda3-latest-MacOSX-arm64.sh

# Install PyTorch
conda install pytorch torchvision torchaudio -c pytorch-nightly

################################################
##### Docker (colima)
################################################

# Install Docker
brew install docker docker-buildx docker-compose docker-credential-helper

# Install Colima
brew install colima

# Set docker host path
tee ${HOME}/.zshrc.d/docker << 'EOF'
export DOCKER_HOST=unix://${HOME}/.colima/default/docker.sock
EOF

# Configure Docker
json_data=$(cat "${HOME}/.docker/config.json")
updated_json=$(echo "$json_data" | jq '. + {cliPluginsExtraDirs: ["/opt/homebrew/lib/docker/cli-plugins"]}')
echo "$updated_json" > "${HOME}/.docker/config.json"

# Set buildx as default Docker builder
docker buildx install

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
##### System Preferences
################################################

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Enable Reduce motion
defaults write com.apple.Accessibility ReduceMotionEnabled -bool true

################################################
##### Applications
################################################

# Install windows management tools
brew install --cask rectangle alt-tab

# Install Google Chrome
brew install --cask google-chrome

# Install OrbStack (docker)
brew install --cask orbstack

################################################
##### Yabai
################################################

# References:
# https://github.com/koekeishiya/yabai
# https://www.josean.com/posts/yabai-setup

# Install Yabai
brew install koekeishiya/formulae/yabai

# Import Yabai configuration
mkdir -p ${HOME}/.config/yabai
tee ${HOME}/.config/yabai/yabairc << EOF
# default layout (can be bsp, stack or float)
yabai -m config layout bsp

# New window spawns to the right if vertical split, or bottom if horizontal split
yabai -m config window_placement second_child

# padding set to 12px
yabai -m config top_padding 12
yabai -m config bottom_padding 12
yabai -m config left_padding 12
yabai -m config right_padding 12
yabai -m config window_gap 12

# center mouse on window with focus
# yabai -m config mouse_follows_focus on

# modifier for clicking and dragging with mouse
yabai -m config mouse_modifier alt
# set modifier + left-click drag to move window
yabai -m config mouse_action1 move
# set modifier + right-click drag to resize window
yabai -m config mouse_action2 resize

# when window is dropped in center of another window, swap them (on edges it will split it)
yabai -m mouse_drop_action swap

# Disable specific apps from being managed with yabai
yabai -m rule --add app="^System Settings$" manage=off
yabai -m rule --add app="^Calculator$" manage=off
yabai -m rule --add app="^FortiClient$" manage=off
yabai -m rule --add app="^ClearPass OnGuard$" manage=off
EOF

# Start Yabai service
yabai --start-service

# Give Accessibility access and then restart Yabai
yabai --restart-service

################################################
##### skhd
################################################

# References:
# https://github.com/koekeishiya/skhd
# https://www.josean.com/posts/yabai-setup

# Install skhd
brew install koekeishiya/formulae/skhd

# Import skhd configuration
mkdir -p ${HOME}/.config/skhd
tee ${HOME}/.config/skhd/skhdrc << EOF
# change window focus within space
alt - j : yabai -m window --focus south
alt - k : yabai -m window --focus north
alt - h : yabai -m window --focus west
alt - l : yabai -m window --focus east

#change focus between external displays (left and right)
alt - s: yabai -m display --focus west
alt - g: yabai -m display --focus east

# rotate layout clockwise
shift + alt - r : yabai -m space --rotate 270

# flip along y-axis
shift + alt - y : yabai -m space --mirror y-axis

# flip along x-axis
shift + alt - x : yabai -m space --mirror x-axis

# toggle window float
shift + alt - t : yabai -m window --toggle float --grid 4:4:1:1:2:2

# maximize a window
shift + alt - m : yabai -m window --toggle zoom-fullscreen

# balance out tree of windows (resize to occupy same area)
shift + alt - e : yabai -m space --balance

# swap windows
shift + alt - j : yabai -m window --swap south
shift + alt - k : yabai -m window --swap north
shift + alt - h : yabai -m window --swap west
shift + alt - l : yabai -m window --swap east

# move window and split
ctrl + alt - j : yabai -m window --warp south
ctrl + alt - k : yabai -m window --warp north
ctrl + alt - h : yabai -m window --warp west
ctrl + alt - l : yabai -m window --warp east

# move window to display left and right
shift + alt - s : yabai -m window --display west; yabai -m display --focus west;
shift + alt - g : yabai -m window --display east; yabai -m display --focus east;

#move window to prev and next space
shift + alt - p : yabai -m window --space prev;
shift + alt - n : yabai -m window --space next;

# move window to space #
shift + alt - 1 : yabai -m window --space 1;
shift + alt - 2 : yabai -m window --space 2;
shift + alt - 3 : yabai -m window --space 3;
shift + alt - 4 : yabai -m window --space 4;
shift + alt - 5 : yabai -m window --space 5;
shift + alt - 6 : yabai -m window --space 6;
shift + alt - 7 : yabai -m window --space 7;

# stop/start/restart yabai
ctrl + alt - q : yabai --stop-service
ctrl + alt - s : yabai --start-service
ctrl + alt - r : yabai --restart-service

# applications
fn + return : open -n -a "iterm"
EOF

# Start skhd service
skhd --start-service

# Give Accessibility access and then restart skhd
skhd --restart-service

################################################
##### Siri
################################################

# Disable Ask Siri
defaults write com.apple.Siri SiriPrefStashedStatusMenuVisible -bool false
defaults write com.apple.Siri VoiceTriggerUserEnabled -bool false

# Disable Siri Suggestions for specific apps
defaults write com.apple.suggestions AppStoreEnabled -bool false
defaults write com.apple.suggestions BooksEnabled -bool false
defaults write com.apple.suggestions CalendarEnabled -bool false
defaults write com.apple.suggestions ContactsEnabled -bool false
defaults write com.apple.suggestions FaceTimeEnabled -bool false
defaults write com.apple.suggestions FreeformEnabled -bool false
defaults write com.apple.suggestions HelpViewerEnabled -bool false
defaults write com.apple.suggestions MailEnabled -bool false
defaults write com.apple.suggestions MapsEnabled -bool false
defaults write com.apple.suggestions MessagesEnabled -bool false
defaults write com.apple.suggestions MicrosoftOutlookEnabled -bool false
defaults write com.apple.suggestions NotesEnabled -bool false
defaults write com.apple.suggestions PhotosEnabled -bool false
defaults write com.apple.suggestions PodcastsEnabled -bool false
defaults write com.apple.suggestions RemindersEnabled -bool false
defaults write com.apple.suggestions SafariEnabled -bool false
defaults write com.apple.suggestions ShortcutsEnabled -bool false
defaults write com.apple.suggestions StocksEnabled -bool false
defaults write com.apple.suggestions TipsEnabled -bool false
defaults write com.apple.suggestions WeatherEnabled -bool false

# Disable Siri Learning for Each Specific Application
defaults write com.apple.suggestions AppStoreShouldLearn -bool false
defaults write com.apple.suggestions BooksShouldLearn -bool false
defaults write com.apple.suggestions CalendarShouldLearn -bool false
defaults write com.apple.suggestions ContactsShouldLearn -bool false
defaults write com.apple.suggestions FaceTimeShouldLearn -bool false
defaults write com.apple.suggestions FreeformShouldLearn -bool false
defaults write com.apple.suggestions HelpViewerShouldLearn -bool false
defaults write com.apple.suggestions MailShouldLearn -bool false
defaults write com.apple.suggestions MapsShouldLearn -bool false
defaults write com.apple.suggestions MessagesShouldLearn -bool false
defaults write com.apple.suggestions MicrosoftOutlookShouldLearn -bool false
defaults write com.apple.suggestions NotesShouldLearn -bool false
defaults write com.apple.suggestions PhotosShouldLearn -bool false
defaults write com.apple.suggestions PodcastsShouldLearn -bool false
defaults write com.apple.suggestions RemindersShouldLearn -bool false
defaults write com.apple.suggestions SafariShouldLearn -bool false
defaults write com.apple.suggestions ShortcutsShouldLearn -bool false
defaults write com.apple.suggestions StocksShouldLearn -bool false
defaults write com.apple.suggestions TipsShouldLearn -bool false
defaults write com.apple.suggestions WeatherShouldLearn -bool false

################################################
##### Spotlight
################################################

# Disable Spotlight
sudo mdutil -a -i off

# Configure Spotlight to index only applications and system preferences
defaults write com.apple.spotlight orderedItems -array \
    '{"enabled" = 1;"name" = "APPLICATIONS";}' \
    '{"enabled" = 0;"name" = "MENU_EXPRESSION";}' \
    '{"enabled" = 0;"name" = "CONTACT";}' \
    '{"enabled" = 0;"name" = "MENU_CONVERSION";}' \
    '{"enabled" = 0;"name" = "MENU_DEFINITION";}' \
    '{"enabled" = 0;"name" = "DOCUMENTS";}' \
    '{"enabled" = 0;"name" = "EVENT_TODO";}' \
    '{"enabled" = 0;"name" = "DIRECTORIES";}' \
    '{"enabled" = 0;"name" = "FONTS";}' \
    '{"enabled" = 0;"name" = "IMAGES";}' \
    '{"enabled" = 0;"name" = "MESSAGES";}' \
    '{"enabled" = 0;"name" = "MOVIES";}' \
    '{"enabled" = 0;"name" = "MUSIC";}' \
    '{"enabled" = 0;"name" = "MENU_OTHER";}' \
    '{"enabled" = 0;"name" = "PDF";}' \
    '{"enabled" = 0;"name" = "PRESENTATIONS";}' \
    '{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}' \
    '{"enabled" = 0;"name" = "SPREADSHEETS";}' \
    '{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
    '{"enabled" = 0;"name" = "TIPS";}' \
    '{"enabled" = 0;"name" = "BOOKMARKS";}'

# Re-enable Spotlight
sudo mdutil -a -i on