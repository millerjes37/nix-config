{
  # A short description of the flake's purpose.
  description = "Cross-Platform Configuration for macOS and Linux";

  # Inputs define the external Nix flakes that this flake depends on.
  inputs = {
    # `nixpkgs`: The Nix Packages collection, providing a vast set of software packages.
    # This is pinned to the nixpkgs-unstable branch for access to the latest packages.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # `home-manager`: A tool to manage user-specific configuration files and packages.
    home-manager.url = "github:nix-community/home-manager";
    # Ensures home-manager uses the same nixpkgs version as defined above.
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # `nixvim`: A module for configuring Neovim using Nix.
    nixvim.url = "github:nix-community/nixvim";
    # Ensures nixvim uses the same nixpkgs version.
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    # `nix-darwin`: Provides modules to configure macOS systems using Nix.
    darwin.url = "github:LnL7/nix-darwin";
    # Ensures nix-darwin uses the same nixpkgs version.
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # `nix-homebrew`: A flake for managing Homebrew packages via Nix.
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # `nix-flatpak`: Declarative Flatpak management for Nix and Home Manager.
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    # nixGL wrapper packages and overlay
    nixgl.url = "github:guibou/nixGL";

    # nix-colors: large collection of colorschemes for use across the system
    nix-colors.url = "github:misterio77/nix-colors";
  };

  # Outputs define what this flake provides to other flakes or to the user.
  outputs = { self, nixpkgs, home-manager, darwin, nix-homebrew, nixvim, ... }@inputs:
  let
    # Import lib for helper functions
    lib = nixpkgs.lib;
    
    # `mkHomeConfig`: A helper function to create a home-manager configuration.
    # Parameters:
    #   - `system`: The target system architecture (e.g., "aarch64-darwin", "x86_64-linux").
    #   - `username`: The username for the home-manager configuration.
    #   - `extraImports` (optional): A list of additional Nix modules to import,
    #     allowing for platform-specific or user-specific configurations.
    mkHomeConfig = { system, username, extraImports ? [] }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { # Import nixpkgs for the specified system.
          inherit system;
          # Only apply nixGL overlay on Linux systems
          overlays = lib.optionals (lib.hasInfix "linux" system) [ inputs.nixgl.overlay ];
          config = {
            allowUnfree = true; # Allow installation of unfree packages.
            permittedInsecurePackages = [
              "electron-25.9.0" # Example: Allow a specific insecure package.
            ];
          };
        };
        # Pass `extraImports` to the modules, making them available for conditional logic.
        extraSpecialArgs = { inherit extraImports inputs; };
        # List of modules to include in the home-manager configuration.
        modules = [
          ./home.nix # The main shared home-manager configuration.
          nixvim.homeManagerModules.nixvim # Module for nixvim integration.
          # Anonymous module to set user-specific details.
          ({ pkgs, ... }: {
            home.username = username;
            home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
            nixpkgs.config.allowUnfree = true; # Also allow unfree packages here.
          })
        ];
      };

    # `mkDarwinConfig`: A helper function to create a nix-darwin system configuration for macOS.
    # Parameters:
    #   - `system`: The target macOS system architecture (e.g., "aarch64-darwin").
    #   - `username`: The username for the macOS system.
    # This function sets up a full macOS system configuration using nix-darwin.
    mkDarwinConfig = { system, username }:
      darwin.lib.darwinSystem {
        inherit system;
        # List of modules for the nix-darwin configuration.
        modules = [
          ./configuration.nix # macOS specific system configurations.
          home-manager.darwinModules.home-manager # Integrate home-manager into the darwin system.
          {
            # Configure home-manager to use global packages and user packages.
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Import the main home.nix configuration for the specified user.
            home-manager.users.${username} = import ./home.nix;
            nixpkgs.config.allowUnfree = true; # Allow unfree packages for the system.
          }
        ];
      };
  in
  {
    # NixOS Configurations (commented out - incomplete configuration)
    # Uncomment and complete when you need NixOS support
    # nixosConfigurations = {
    #   "nixos-desktop" = nixpkgs.lib.nixosSystem {
    #     system = "x86_64-linux"; # Or your target system
    #     specialArgs = { inherit inputs; }; # Pass all flake inputs to modules
    #     modules = [
    #       # Main NixOS system configuration
    #       ./modules/nixos/default.nix

    #       # Home Manager integration for NixOS
    #       home-manager.nixosModules.home-manager
    #       {
    #         nixpkgs.config.allowUnfree = true;
    #         home-manager.useGlobalPkgs = true;
    #         home-manager.useUserPackages = true;
    #         # Configure Home Manager for the correct user (jackson, not jules)
    #         home-manager.users.jackson = import ./modules/nixos/home.nix;
    #         # Pass flake inputs to home-manager modules as well
    #         home-manager.extraSpecialArgs = { inherit inputs; };
    #       }

    #       # Only apply nixGL overlay for NixOS (Linux-based)
    #       ({ nixpkgs.overlays = [ inputs.nixgl.overlay ]; })
    #     ];
    #   };
    # };

    # `darwinConfigurations`: Defines complete macOS system configurations.
    # These are typically used to build and manage an entire macOS setup.
    # Example: `nix build .#darwinConfigurations.macbook-air`
    darwinConfigurations."macbook-air" = mkDarwinConfig {
      system = "aarch64-darwin"; # Apple Silicon Mac
      username = "jacksonmiller";
    };

    # `homeConfigurations`: Defines standalone home-manager configurations.
    # These can be activated on any system (macOS or Linux) where home-manager is installed.
    # They manage the user's dotfiles and user-specific packages.
    # Example: `home-manager switch --flake .#jacksonmiller@mac`
    homeConfigurations = let
      # Home-manager configuration for a macOS user named "jacksonmiller".
      jacksonMac = mkHomeConfig {
        system = "aarch64-darwin";
        username = "jacksonmiller";
        # Imports macOS-specific modules from `modules/darwin/default.nix`.
        extraImports = [
          ./modules/darwin/default.nix # Main macOS user-specific configuration
        ];
      };

      # Home-manager configuration for a Linux user named "jackson".
      jacksonLinux = mkHomeConfig {
        system = "x86_64-linux";
        username = "jackson";
        # Imports Linux-specific modules from `modules/linux/default.nix`.
        extraImports = [
          ./modules/linux/default.nix  # Main Linux user-specific configuration
        ];
      };
    in {
      "jacksonmiller@mac" = jacksonMac;
      "jackson@linux" = jacksonLinux;
      "jackson" = jacksonLinux;
    };
  };
}