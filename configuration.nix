# This is the main system configuration file for macOS, managed by nix-darwin.
# It defines system-level settings, packages, and services.
# - `config`: Provides access to configuration options.
# - `pkgs`: Provides access to the Nix Packages collection for the system.
{ config, pkgs, ... }:

{
  # `services.yabai.enable` and `services.skhd.enable`:
  # These lines control the built-in nix-darwin services for Yabai (tiling window manager)
  # and skhd (simple hotkey daemon).
  # They are explicitly set to `false` because this configuration opts to manage
  # Yabai and skhd via external scripts (e.g., started by launchd or manually).
  # This approach can sometimes offer more control or stability, especially if
  # specific startup sequences or environment variables are needed that are complex
  # to manage directly via nix-darwin services.
  services.yabai.enable = false; # Yabai is managed externally for potentially better stability or custom setup.
  services.skhd.enable = false;  # skhd is managed externally for similar reasons.

  # `environment.systemPackages`: This option lists packages that should be installed
  # system-wide, making them available to all users on the macOS system.
  # These packages are typically command-line tools or applications that integrate
  # at the system level.
  environment.systemPackages = with pkgs; [
    alacritty  # Alacritty terminal emulator.
    jq         # Command-line JSON processor, useful for scripts.
    yabai      # Yabai tiling window manager (the package itself, not the service).
    # inputs.zen-browser.packages."${system}".default # Installs the Zen browser from the flake input.
    # Note: The `${system}` variable refers to the system architecture (e.g., "aarch64-darwin").
  ];

  # `nix-homebrew.enable`: This option enables the nix-homebrew integration.
  # When set to `true`, it allows managing Homebrew taps and packages declaratively
  # within the Nix configuration. This can be useful for software that is primarily
  # distributed via Homebrew or when a specific Homebrew version is needed.
  # See the nix-homebrew documentation for how to declare Homebrew packages.
  nix-homebrew.enable = true;
}
