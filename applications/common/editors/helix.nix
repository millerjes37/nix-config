{ config, lib, pkgs, ... }:

{
  # Enable Helix editor with a sensible default configuration.
  programs.helix = {
    enable = true;

    # Explicitly set the package (optional – Home Manager picks this by default).
    package = pkgs.helix;

    # Helix configuration rendered to ~/.config/helix/config.toml
    settings = {
      # Global theme. `gruvbox_dark_hard` ships with Helix.
      theme = "gruvbox_dark_hard";

      # Editor-wide settings.
      editor = {
        line-number = "relative";   # Show relative line numbers.
        cursorline  = true;          # Highlight the current line.
        rulers      = [ 80 100 ];    # Visual rulers at 80 & 100 columns.
        bufferline  = "multiple";   # Show multiple buffers in the bar.
        auto-save   = true;          # Autosave files when focus is lost.
      };

      # Custom key mappings (TOML-style keys).
      keys = {
        normal = {
          "space w" = ":write";         # <leader>w to save.
          "space q" = ":quit";          # <leader>q to quit.
          "space h" = ":nohlsearch";    # Clear search highlights.
        };
      };
    };
  };
} 