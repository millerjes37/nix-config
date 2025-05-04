# Disable Conflicting System Shortcuts

macOS System Preferences has keyboard shortcuts that may conflict with skhd's key bindings. Here's how to disable them:

## Mission Control Shortcuts

1. Open **System Preferences** → **Keyboard** → **Keyboard Shortcuts** → **Mission Control**
2. Uncheck or modify these shortcuts that conflict with option key bindings:
   - [ ] "Mission Control" (often Command+Up Arrow)
   - [ ] "Application windows" (often Command+Down Arrow)
   - [ ] "Move left a space" (often Control+Left Arrow)
   - [ ] "Move right a space" (often Control+Right Arrow)
   - [ ] "Switch to Desktop 1" (often Control+1)
   - [ ] "Switch to Desktop 2" (often Control+2)
   - [ ] "Switch to Desktop 3" (often Control+3)
   - [ ] And so on for other desktop numbers...

## Spotlight Shortcuts

1. Open **System Preferences** → **Keyboard** → **Keyboard Shortcuts** → **Spotlight**
2. Uncheck or modify:
   - [ ] "Show Spotlight search" (often Command+Space)

## Application Shortcuts

1. Open **System Preferences** → **Keyboard** → **Keyboard Shortcuts** → **App Shortcuts**
2. Check if any custom app shortcuts might conflict with your skhd bindings

## Alternative Option

If you don't want to disable system shortcuts, you can modify skhd's configuration to use different keys that don't conflict with system shortcuts. For example:

- Use Hyper key (Command+Option+Shift+Control) for window management
- Use different number keys or function keys for spaces
- Use different modifier combinations

## Testing Your Changes

After disabling conflicting shortcuts:

1. Log out and log back in (or restart)
2. Test your skhd shortcuts
3. If they still don't work, run:
   ```bash
   skhd --restart-service
   ```

Remember that some macOS features (like Mission Control, Spaces, and Screenshot) have built-in shortcuts that are deeply integrated with the system.