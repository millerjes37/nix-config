# Changelog

## [1.0.0] - 2025-05-07

### Added
- Cross-platform support for both macOS and Linux
- Proper directory structure with common, darwin, and linux modules
- Window management solutions for both platforms:
  - macOS: yabai and skhd for tiling window management
  - Linux: i3 for tiling window management
- Common tools across platforms:
  - Alacritty terminal with simplified configuration
  - Zsh with modern features and plugins
  - Neovim with full LSP support
  - Emacs with Doom Emacs framework
- Platform detection using `pkgs.stdenv.isDarwin` and `pkgs.stdenv.isLinux`
- Cross-platform rebuild script
- Configuration validation script

### Changed
- Complete reorganization of the directory structure
- Simplified Alacritty configuration for better performance
- Enhanced Zsh configuration with syntax highlighting and better history
- Improved window management for both platforms

### Fixed
- Package references for renamed packages
- Cross-platform file path handling
- Platform-specific keybindings and shortcuts

## Future Plans
- Further optimize performance of configuration loading
- Add more specialized development environments
- Improve documentation and user guides
- Setup automated testing for configurations