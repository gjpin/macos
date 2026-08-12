# Misc guides
## WireGuard reconfiguration
1. Disable wireguard
```bash
sudo launchctl bootout system /Library/LaunchDaemons/com.wireguard.wg0.plist
sudo /opt/homebrew/bin/wg-quick down /etc/wireguard/wg0.conf
sudo rm -f /var/run/wireguard/utun0.sock
sudo rm -f /var/run/wireguard/wg0.name
```

2. Update /etc/wireguard/wg0.conf

3. Re-enable wireguard
```bash
sudo launchctl bootstrap system /Library/LaunchDaemons/com.wireguard.wg0.plist
```

4. Verify
```bash
sudo /opt/homebrew/bin/wg show
```

## Remove lingering login items and others

- Check directories:
   - /Library/LaunchDaemons
   - ~/Library/LaunchAgents
   - ~/Library/Application\ Support
   - ~/Library/Preferences
   - ~/Library/Caches

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

# Write setting example
defaults write com.googlecode.iterm2 BootstrapDaemon -bool false # Do not "Allow sessions to survive logging out and back in"
```