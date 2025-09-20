# How to
1. Update and restart MacOS
2. Add Wireguard config file to /etc/wireguard/wg0.conf
3. Run setup.sh
4. Keyboard shortcuts:
   * Windows -> General -> Fill: ctrl + fn + enter
   * Windows -> Halves -> Tile Left Half: ctrl + fn +left arrow
   * Windows -> Halves -> Tile Right Half: ctrl + fn + right arrow
   * Mission Control -> Mission Control: option + tab
5. UX improvements:
   * Desktop & Dock -> Hot Corners -> top left : Mission Control
7. iTerm2:
   * Appearance -> Theme -> Minimal
   * Profiles -> Colors:
      * Color Preset: Pastel (Dark Background)
      * Defaults -> Foreground: ffffff
   * Profiles -> Text:
      * Font: MesloLGS Nerd Font Mono, 14
   * Advanced:
      * Scroll wheel sends arrow keys when in alternate screen mode: yes

# Local LLM + Cline example setup
LM Studio
- Download models:
   - Qwen3-Coder-30B-A3B-Instruct-MLX-4bit
   - Devstral-Small-2507-MLX-4bit
- Developer -> Load
   - Context Length: 262144
   - KV Cache Quantization: disabled
- Load model
- Status: running

Cline
- Provider: LM Studio
- Model: qwen/qwen3-coder-30b
- Custom base URL: disabled
- Context window: 262144
- Use compact prompt: enabled
