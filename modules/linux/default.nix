{ config, lib, pkgs, ... }:

{
  # Import system configuration modules
  imports = [
    # Core system configuration
    ../common/default.nix  # Common system modules
    
    # Window management
    ./window-management/default.nix
    
    # Linux system settings
    ./gtk.nix
    ./services.nix
    ./hardware.nix
  ];
}