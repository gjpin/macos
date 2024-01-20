# How to
1. Update and restart MacOS
2. Add Wireguard config file to /etc/wireguard/wg0.conf
3. Run setup.sh

# Misc guides
## Applications and system configurations
```bash
# References:
# https://pawelgrzybek.com/change-macos-user-preferences-via-command-line/

# Get list of domains
defaults domains

# Read settings of app
defaults read com.apple.Notes

# Get setting type
defaults read-type com.apple.universalaccess reduceMotion

# Find setting across all domains
defaults find reducemotion

# Compare all settings
defaults read > before
defaults read > after
diff before after
code --diff before after
```

## Enable TouchID for sudo in iTerm2
```bash
# For reference only. It's already in iterm2.plist
defaults write "com.googlecode.iterm2" "BootstrapDaemon" -bool false # Do not "Allow sessions to survive logging out and back in"
sudo gsed -i '1 a auth       sufficient     pam_tid.so' /etc/pam.d/sudo
```