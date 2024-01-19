################################################
##### GNU utils
################################################

# References:
# https://gist.github.com/skyzyx/3438280b18e4f7c490db8a2a2ca0b9da

# Install GNU utils
brew install autoconf bash binutils coreutils diffutils ed findutils flex gawk \
    gnu-indent gnu-sed gnu-tar gnu-which gpatch grep gzip less m4 make nano \
    screen watch wdiff wget zip

tee ${HOME}/.zshrc.d/gnu-utils << 'EOF'
HOMEBREW_PREFIX=$(brew --prefix)
NEWPATH=${PATH}
for d in ${HOMEBREW_PREFIX}/opt/*/libexec/gnubin; do NEWPATH=$d:$NEWPATH; done
export PATH=$(echo ${NEWPATH} | tr ':' '\n' | cat -n | sort -uk2 | sort -n | cut -f2- | xargs | tr ' ' ':')
EOF

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