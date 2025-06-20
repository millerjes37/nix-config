# Nix Config Restructure Progress

## ✅ Completed

### 1. Created New Application Structure
- `applications/common/` - Cross-platform applications
  - `terminal/` - Terminal emulators, shells, multiplexers
  - `utilities/` - CLI tools, system monitoring, network tools
  - `development/` - Git, languages, containers, databases
  - `editors/` - Neovim, Helix, Emacs, NixVim
  - `security/` - KeePassXC, encryption, password managers
  - `media/` - GIMP, workflows, audio/video tools
- `applications/darwin/` - macOS-specific applications
- `applications/linux/` - Linux-specific applications

### 2. Modularized Existing Configurations
- ✅ Terminal applications (Alacritty, Zsh, Starship)
- ✅ CLI utilities (organized by category)
- ✅ Development tools (Git configuration extracted)
- ✅ Basic editor configurations
- ✅ Security tools (KeePassXC)
- ✅ Media tools (GIMP, workflows)

### 3. System Configuration Updates
- ✅ Created streamlined `modules/common/default-new.nix`
- ✅ Added XDG configuration module
- ✅ Added locale configuration module
- ✅ Separated system config from applications

## 🔄 Next Steps

### Phase 1: Complete File Moves
1. Move remaining configuration files to new locations:
   ```bash
   cp modules/common/nixvim.nix applications/common/editors/nixvim.nix
   cp modules/common/helix.nix applications/common/editors/helix.nix
   cp modules/common/emacs.nix applications/common/editors/emacs.nix
   ```

2. Create missing placeholder files:
   ```bash
   # Darwin-specific apps
   touch applications/darwin/{homebrew,mas-apps,xcode-tools,macos-utilities}.nix
   
   # Linux-specific apps
   touch applications/linux/{flatpak,appimage,gaming,linux-utilities}.nix
   ```

### Phase 2: Update Main Configuration
1. Replace current `modules/common/default.nix` with new version
2. Update platform-specific defaults to import applications
3. Modify `flake.nix` to use new structure

### Phase 3: Window Management Reorganization
1. Move window management to proper module structure:
   ```
   modules/darwin/window-management/
   modules/linux/window-management/
   ```

### Phase 4: Create Profiles
1. Create user profiles for different use cases:
   ```
   profiles/
   ├── workstation.nix     # Full development setup
   ├── minimal.nix         # Minimal setup
   └── media-production.nix # Media creation focus
   ```

## 🏗️ Updated flake.nix Structure

```nix
homeConfigurations = let
  mkHomeConfig = { system, username, profile ? "workstation" }:
    home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      modules = [
        ./modules/common/default.nix
        ./applications/common/default.nix
        ./profiles/${profile}.nix
      ] ++ lib.optionals pkgs.stdenv.isDarwin [
        ./modules/darwin/default.nix
        ./applications/darwin/default.nix
      ] ++ lib.optionals pkgs.stdenv.isLinux [
        ./modules/linux/default.nix
        ./applications/linux/default.nix
      ];
    };
in {
  "jacksonmiller@mac" = mkHomeConfig {
    system = "aarch64-darwin";
    username = "jacksonmiller";
  };
  "jackson@linux" = mkHomeConfig {
    system = "x86_64-linux";
    username = "jackson";
  };
};
```

## 📊 Benefits Achieved

1. **Modularity**: Each application is in its own file
2. **Categorization**: Applications grouped by function
3. **Platform Separation**: Clear separation between common and platform-specific
4. **Maintainability**: Easy to enable/disable specific applications
5. **Reusability**: Modules can be reused across different configurations
6. **Clarity**: System configuration separate from application configuration

## 🚀 Migration Commands

### Backup Current Configuration
```bash
git add . && git commit -m "Backup before restructure"
```

### Test New Structure
```bash
# Enable specific applications in applications/common/*/default.nix
# Then test build
home-manager switch --flake .#jacksonmiller@mac
```

### Final Migration
```bash
# Once tested, remove old files
rm modules/common/{alacritty,zsh,emacs,nixvim,helix,keepassxc,gimp-config,media-workflows,development}.nix
``` 