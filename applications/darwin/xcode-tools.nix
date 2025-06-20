{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # iOS/macOS development tools
    xcodes            # Manage multiple Xcode versions
    cocoapods         # Dependency manager for Swift/Objective-C
    # ios-deploy      # Deploy iOS apps to devices
    # libimobiledevice # iOS device communication
    
    # Simulator tools
    # ios-sim         # iOS Simulator command line tool
  ];

  # Environment variables for iOS development
  home.sessionVariables = {
    # DEVELOPER_DIR = "/Applications/Xcode.app/Contents/Developer";
  };
} 