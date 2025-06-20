{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Gaming platforms
    # steam            # Steam gaming platform
    # lutris           # Open gaming platform
    # heroic           # Epic Games Store launcher
    # bottles          # Wine management
    
    # Gaming utilities
    # gamemode         # Optimize system for gaming
    # mangohud         # Gaming overlay for monitoring
    # goverlay         # GUI for MangoHud
    
    # Emulation
    # retroarch        # Multi-system emulator
    # dolphin-emu      # GameCube/Wii emulator
    # pcsx2            # PlayStation 2 emulator
  ];

  # Gaming-specific environment variables
  home.sessionVariables = {
    # Enable MangoHud for all Vulkan applications
    # MANGOHUD = "1";
    # Steam scaling
    # STEAM_FORCE_DESKTOPUI_SCALING = "1.5";
  };
} 