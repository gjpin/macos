# How to
1. Update and restart MacOS
2. Add Wireguard config file to /etc/wireguard/wg0.conf
3. Run setup.sh

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