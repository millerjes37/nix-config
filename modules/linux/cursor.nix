# Cursor (AI Code Editor) configuration for Linux
{ config, lib, pkgs, inputs, ... }:

{
  # Create a wrapped version of Cursor that handles sandbox issues
  home.packages = with pkgs; [
    # Wrapped Cursor with proper sandbox configuration
    (writeShellScriptBin "cursor" ''
<<<<<<< HEAD
      # Launch Cursor with sandbox fixes
      exec ${code-cursor}/bin/code-cursor \
=======
      # Use nixGL wrapper if available for better graphics compatibility
      ${if config.nixGL.enable then "${config.nixGL.packages.nixGLIntel}/bin/nixGL" else ""} \
      ${pkgs.code-cursor}/bin/code-cursor \
>>>>>>> e520611 (Fix package references in cursor.nix files)
        --no-sandbox \
        --disable-gpu-sandbox \
        --disable-software-rasterizer \
        --disable-background-timer-throttling \
        --disable-renderer-backgrounding \
        --disable-backgrounding-occluded-windows \
        --disable-features=TranslateUI \
        --disable-ipc-flooding-protection \
        "$@"
    '')

    # Also provide the original cursor for fallback
    pkgs.code-cursor
  ];

  # Create desktop entry for Cursor with proper configuration
  xdg.desktopEntries.cursor = {
    name = "Cursor";
    comment = "AI-powered code editor";
    exec = "cursor %F";
    icon = "code-cursor";
    categories = [ "Development" "IDE" ];
    mimeType = [
      "text/plain"
      "inode/directory"
      "application/x-code-workspace"
    ];
    settings = {
      StartupNotify = "true";
      StartupWMClass = "code-cursor";
    };
  };

  # Alternative desktop entry with GPU acceleration disabled (for problematic systems)
  xdg.desktopEntries.cursor-safe = {
    name = "Cursor (Safe Mode)";
    comment = "AI-powered code editor (Safe Mode - No GPU)";
    exec = "${pkgs.code-cursor}/bin/code-cursor --no-sandbox --disable-gpu --disable-software-rasterizer %F";
    icon = "code-cursor";
    categories = [ "Development" "IDE" ];
    settings = {
      StartupNotify = "true";
      StartupWMClass = "code-cursor";
      NoDisplay = "false";
    };
  };

  # Set file associations for common development files
  xdg.mimeApps.defaultApplications = {
    "text/plain" = "cursor.desktop";
    "text/x-python" = "cursor.desktop";
    "text/x-rust" = "cursor.desktop";
    "text/x-go" = "cursor.desktop";
    "text/x-javascript" = "cursor.desktop";
    "text/x-typescript" = "cursor.desktop";
    "application/json" = "cursor.desktop";
    "text/x-markdown" = "cursor.desktop";
    "text/x-yaml" = "cursor.desktop";
    "text/x-toml" = "cursor.desktop";
  };

  # Create a launcher script in ~/.local/bin for easy terminal access
  home.file.".local/bin/cursor-debug" = {
    text = ''
      #!/usr/bin/env bash
      # Debug version of Cursor with verbose output
      echo "🚀 Starting Cursor in debug mode..."
<<<<<<< HEAD
      echo "📍 Cursor location: ${code-cursor}/bin/code-cursor"
      echo "🔧 Using nixGL: No (simplified for stability)"
=======
      echo "📍 Cursor location: ${pkgs.code-cursor}/bin/code-cursor"
      echo "🔧 Using nixGL: ${if config.nixGL.enable then "Yes" else "No"}"
>>>>>>> e520611 (Fix package references in cursor.nix files)
      echo ""
      
      # Check if the binary exists
      if [ ! -f "${pkgs.code-cursor}/bin/code-cursor" ]; then
        echo "❌ Cursor binary not found at expected location!"
        exit 1
      fi
      
      # Run with debug output
<<<<<<< HEAD
      exec ${code-cursor}/bin/code-cursor \
=======
      ${if config.nixGL.enable then "${config.nixGL.packages.nixGLIntel}/bin/nixGL" else ""} \
      ${pkgs.code-cursor}/bin/code-cursor \
>>>>>>> e520611 (Fix package references in cursor.nix files)
        --no-sandbox \
        --disable-gpu-sandbox \
        --enable-logging \
        --log-level=0 \
        --v=1 \
        "$@"
    '';
    executable = true;
  };

  # Environment variables for Electron applications
  home.sessionVariables = {
    # Disable GPU sandbox for all Electron apps if needed
    ELECTRON_DISABLE_SANDBOX = "1";
    # Force software rendering if GPU issues persist
    # LIBGL_ALWAYS_SOFTWARE = "1";  # Uncomment if needed
  };
} 