# Cursor Sandbox Fix for Linux

This document explains how to resolve the SUID sandbox error when running Cursor on Linux with Nix.

## The Problem

When running Cursor on Linux, you may encounter this error:

```
The SUID sandbox helper binary was found, but is not configured correctly. Rather than run without sandboxing I'm aborting now. You need to make sure that /nix/store/...cursor.../lib/cursor/chrome-sandbox is owned by root and has mode 4755.
```

This happens because Cursor (based on Electron/Chromium) expects a SUID sandbox helper binary, but Nix handles sandboxing differently.

## The Solution

I've created a comprehensive fix that:

1. **Wraps Cursor** with proper `--no-sandbox` flags
2. **Integrates with nixGL** for better graphics compatibility
3. **Creates desktop entries** for GUI launching
4. **Sets up file associations** for development files
5. **Provides debug tools** for troubleshooting

## Quick Fix (Automated)

Run the test script to apply and verify the fix:

```bash
./test-cursor-fix.sh
```

## Manual Steps

If the automated approach doesn't work, follow these steps:

### 1. Apply Home Manager Configuration

```bash
# For Linux users
home-manager switch --flake .#jackson@linux

# Or if that doesn't work
home-manager switch --flake .#jackson
```

### 2. Verify the Fix

Check that the wrapper script was created:

```bash
which cursor
# Should show: /home/jackson/.nix-profile/bin/cursor
```

### 3. Test Launch

Try launching Cursor:

```bash
# Basic launch
cursor

# Debug launch with verbose output
cursor-debug

# Safe mode (if regular mode fails)
/nix/store/.../code-cursor/bin/code-cursor --no-sandbox --disable-gpu
```

## What Was Changed

### New Files Created:
- `modules/linux/cursor.nix` - Linux-specific Cursor configuration
- `modules/darwin/cursor.nix` - macOS-specific Cursor configuration

### Modified Files:
- `modules/linux/default.nix` - Added cursor module import
- `modules/darwin/default.nix` - Added cursor module import  
- `modules/common/development.nix` - Moved cursor to platform-specific modules

### Key Features Added:

1. **Wrapped Cursor Command**: Creates a `cursor` script that runs with:
   ```bash
   --no-sandbox
   --disable-gpu-sandbox
   --disable-software-rasterizer
   # ... and other stability flags
   ```

2. **Desktop Integration**: 
   - Regular Cursor desktop entry
   - Safe mode desktop entry (for problematic systems)
   - File associations for common development files

3. **Debug Tools**:
   - `cursor-debug` script in `~/.local/bin/`
   - Verbose logging options
   - System compatibility checks

4. **Graphics Compatibility**:
   - Integrates with nixGL when available
   - Software rendering fallback options

## Troubleshooting

### If Cursor Still Won't Start:

1. **Try Safe Mode**:
   ```bash
   /nix/store/.../code-cursor/bin/code-cursor --no-sandbox --disable-gpu --disable-software-rasterizer
   ```

2. **Check nixGL Setup**:
   ```bash
   # Verify nixGL is working
   nixGL glxinfo | grep renderer
   ```

3. **Force Software Rendering**:
   Add to your shell profile:
   ```bash
   export LIBGL_ALWAYS_SOFTWARE=1
   ```

4. **Use Debug Script**:
   ```bash
   cursor-debug
   ```

### Common Issues:

- **Graphics driver problems**: Use safe mode or enable software rendering
- **Wayland issues**: Try setting `GDK_BACKEND=x11` before launching
- **Font rendering issues**: Install additional fonts or use `--disable-font-subpixel-positioning`

## Environment Variables

The configuration sets these environment variables:

```bash
ELECTRON_DISABLE_SANDBOX=1    # Disables sandbox for all Electron apps
# LIBGL_ALWAYS_SOFTWARE=1     # Uncomment if GPU issues persist
```

## File Associations

The fix automatically associates these file types with Cursor:
- `.py`, `.rs`, `.go`, `.js`, `.ts` 
- `.json`, `.md`, `.yaml`, `.toml`
- Plain text files and directories

## Reverting the Changes

If you need to revert:

1. Remove the cursor modules from the imports in `modules/linux/default.nix`
2. Add `code-cursor` back to `modules/common/development.nix`
3. Run `home-manager switch` again

## Additional Resources

- [NixGL Documentation](https://github.com/guibou/nixGL)
- [Electron Sandbox Documentation](https://www.electronjs.org/docs/tutorial/sandbox)
- [Chromium Command Line Switches](https://peter.sh/experiments/chromium-command-line-switches/) 