# macOS workstation setup

## How to

1. Update and restart MacOS
2. Add Wireguard config file to /etc/wireguard/wg0.conf
3. Run setup.sh
4. Keyboard shortcuts:
   * Windows -> General -> Fill: ctrl + option + enter
   * Windows -> Halves -> Tile Left Half: ctrl + option + left arrow
   * Windows -> Halves -> Tile Right Half: ctrl + option + right arrow
   * Mission Control -> Mission Control: option + tab
5. UX improvements:
   * Desktop & Dock -> Hot Corners -> top left : Mission Control
6. Battery behaviour:
   * Battery -> Options -> Prevent automatic sleeping on power adapter when the display is off
   * Battery -> Low Power Mode -> Only on battery
7. iTerm2:
   * Appearance -> Theme -> Minimal
   * Profiles -> Colors:
      * Color Preset: Pastel (Dark Background)
      * Defaults -> Foreground: ffffff
   * Profiles -> Text:
      * Font: MesloLGS Nerd Font Mono, 14
   * Advanced:
      * Scroll wheel sends arrow keys when in alternate screen mode: yes
8. Drag "Cursor Safehouse" Application into dock

## Tips

### WireGuard reconfiguration
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

### Remove lingering login items and others

- Check directories:
   - /Library/LaunchDaemons
   - ~/Library/LaunchAgents
   - ~/Library/Application\ Support
   - ~/Library/Preferences
   - ~/Library/Caches
