{ config, lib, pkgs, ... }:

{
  # macOS-specific applications
  home.packages = with pkgs; [
    # macOS utilities
    mas               # Mac App Store CLI
    m-cli             # macOS command line tools
    
    # Development tools
    cocoapods         # iOS/macOS dependency manager
    xcodes            # Xcode version manager
    
    # Security - KeePassXC as preferred password manager
    # Note: KeePassXC is also configured via the common module
    # but we include it here for macOS-specific package availability
    keepassxc         # Cross-platform password manager
    
    # Tools that work better with Homebrew (consider using it for these)
    # (They're commented out since you might want to use Homebrew for these)
    # docker
    # docker-compose
    # rectangle       # Window manager (lightweight)
  ];
  
  # Homebrew Bundle configuration (using home-manager for Homebrew)
  # Normally, we'd use nix-darwin's homebrew module for this
  # But we'll add a Brewfile to reference for manual installation
  
  home.file.".Brewfile".text = ''
    # Taps
    tap "homebrew/bundle"
    tap "homebrew/cask"
    tap "homebrew/cask-fonts"
    tap "homebrew/core"
    
    # CLI tools
    brew "mas"                 # Mac App Store command line interface
    
    # Applications
    # cask "1password"        # Password manager - Using KeePassXC as primary
    cask "keepassxc"          # Primary password manager - cross-platform
    cask "alfred"             # Launcher
    cask "discord"            # Chat
    cask "docker"             # Containerization
    cask "google-chrome"      # Web browser
    cask "iterm2"             # Terminal
    cask "rectangle"          # Window manager
    cask "slack"              # Team communication
    cask "spotify"            # Music streaming
    cask "visual-studio-code" # Text editor
    cask "zoom"               # Video conferencing
    
    # Fonts
    cask "font-fira-code"
    cask "font-jetbrains-mono"
    cask "font-hack-nerd-font"
    
    # Mac App Store apps
    mas "Keynote", id: 409183694
    mas "Numbers", id: 409203825
    mas "Pages", id: 409201541
    mas "Xcode", id: 497799835
  '';
  
  # macOS .zshrc extensions for macOS-specific paths and tools
  home.file.".zshrc.darwin".text = ''
    # macOS-specific configuration for zsh
    
    # Add Homebrew to PATH
    if [ -d "/opt/homebrew/bin" ]; then
      export PATH="/opt/homebrew/bin:$PATH"
    fi
    
    # Xcode command line tools
    if [ -d "/Applications/Xcode.app/Contents/Developer/usr/bin" ]; then
      export PATH="/Applications/Xcode.app/Contents/Developer/usr/bin:$PATH"
    fi
    
    # macOS aliases
    alias finder="open ."
    alias showfiles="defaults write com.apple.finder AppleShowAllFiles YES; killall Finder"
    alias hidefiles="defaults write com.apple.finder AppleShowAllFiles NO; killall Finder"
    
    # Flush DNS
    alias flushdns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
    
    # Quick Look from terminal
    alias ql="qlmanage -p 2>/dev/null"
    
    # Show/hide desktop icons
    alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"
    alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
  '';
}