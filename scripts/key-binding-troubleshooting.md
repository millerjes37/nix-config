# Window Manager Key Binding Troubleshooting

## Key Binding Options

I've updated your configuration to provide multiple ways to control window management:

### 1. Option Key Only (requires disabling system shortcuts)
- `Option + 1-6`: Switch to desktop
- `Option + Arrow Keys`: Focus window in direction
- `Option + F`: Toggle fullscreen
- `Option + T`: Toggle float

### 2. Ctrl+Option (less likely to conflict)
- `Ctrl+Option + 1-6`: Switch to desktop
- `Ctrl+Option + Arrow Keys`: Focus window in direction

### 3. Vim-style (least likely to conflict)
- `Ctrl + H/J/K/L`: Focus window in direction

## Troubleshooting Steps

If your key bindings don't work:

1. **Check which bindings work**:
   Try all three binding styles to see which ones work. This helps identify if the issue is with specific modifier keys.

2. **Check System Shortcuts**:
   System Preferences → Keyboard → Shortcuts → Mission Control
   - Look for shortcuts using Option, especially:
     - "Mission Control" (often Control+Up Arrow)
     - "Application windows" (often Control+Down Arrow)
     - "Move left/right a space" (often Control+Arrow Left/Right)
     - "Switch to Desktop X" (often Control+number)

3. **Check skhd is receiving events**:
   ```bash
   skhd -o | grep -i option
   ```
   Press some keys with Option and see if they register.

4. **Restart skhd**:
   ```bash
   skhd --restart-service
   ```

5. **Check process priority**:
   ```bash
   ps -o nice -p $(pgrep skhd)
   ```
   If it's not 0 or negative, try:
   ```bash
   sudo renice -n -10 -p $(pgrep skhd)
   ```

## Common Issues

1. **Mission Control Overrides**: macOS Mission Control has deep system integration and can override skhd for desktop switching.

2. **Slow Response**: If keys work but are slow, try changing process priority.

3. **Accessibility Permissions**: Ensure skhd has proper permissions in System Preferences → Security & Privacy → Privacy → Accessibility.

4. **Input Sources**: Some keyboard layouts or input methods can interfere with hotkeys.

## Recommended Working Setup

The most reliable setup is:
- Use `Ctrl+Option+[key]` for window management
- Use `Ctrl+H/J/K/L` for directional focus
- Disable conflicting system shortcuts

If you want to stick with just Option key, you must disable all conflicting system shortcuts in System Preferences.