{ config, lib, pkgs, ... }:

{
  # Homebrew configuration for macOS-specific applications
  # This is useful for apps that aren't available in nixpkgs or work better through Homebrew
  
  # Note: You'll need to enable homebrew in your Darwin configuration
  # homebrew = {
  #   enable = true;
  #   casks = [
  #     "1password"
  #     "discord"
  #     "spotify"
  #     "visual-studio-code"
  #     # Add other GUI applications here
  #   ];
  #   brews = [
  #     # Command line tools that work better through homebrew
  #   ];
  # };
} 