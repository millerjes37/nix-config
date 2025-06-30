{ config, lib, pkgs, ... }:

{
  # Enable Helix editor with a sensible default configuration.
  programs.helix = {
    enable = true;

    # Explicitly set the package (optional – Home Manager picks this by default).
    package = pkgs.helix;

    # Helix configuration rendered to ~/.config/helix/config.toml
    settings = {
      # Dynamic theme based on color scheme - matches your browns and tans preference
      theme = lib.mkDefault (
        if config.colorScheme.slug == "atelier-dune" then "autumn_night_transparent"
        else if config.colorScheme.slug == "atelier-cave" then "monokai"
        else if config.colorScheme.slug == "atelier-heath" then "autumn_night"
        else if config.colorScheme.slug == "ir-black" then "monokai"
        else if lib.hasPrefix "gruvbox" config.colorScheme.slug then "gruvbox_dark_hard"
        else "gruvbox_dark_hard"
      ); # fallback

      # Editor-wide settings.
      editor = {
        line-number = "relative";   # Show relative line numbers.
        cursorline  = true;          # Highlight the current line.
        rulers      = [ 80 100 ];    # Visual rulers at 80 & 100 columns.
        bufferline  = "multiple";   # Show multiple buffers in the bar.
        auto-save   = true;          # Autosave files when focus is lost.
      };

      # Custom key mappings (correct Helix format).
      keys = {
        normal = {
          space = {
            h = "select_all";     # <space>h to select all (no hlsearch in helix).
          };
        };
      };
    };
  };
} 