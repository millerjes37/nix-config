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
  };

  # Outputs define what this flake provides to other flakes or to the user.
  outputs = { self, nixpkgs, home-manager, darwin, nix-homebrew, nixvim, ... }@inputs:
  let
    # Helper function to create a home-manager configuration with the new modular structure
    mkHomeConfig = { system, username, profile ? "workstation", extraModules ? [] }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ inputs.nixgl.overlay ];
          config = {
            allowUnfree = true;
            permittedInsecurePackages = [
              "electron-25.9.0"
            ];
          };
        };
        
        extraSpecialArgs = { inherit inputs; };
        
        modules = [
          # Core system configuration
          ./modules/common/default.nix
          
          # Applications
          ./applications/common/default.nix
          
          # User profile
          ./profiles/${profile}.nix
          
          # User-specific configuration
          ({ pkgs, ... }: {
            home.username = username;
            home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
            nixpkgs.config.allowUnfree = true;
          })
          
          # nixvim integration
          nixvim.homeManagerModules.nixvim
          
          # Platform-specific modules
        ] ++ lib.optionals pkgs.stdenv.isDarwin [
          ./modules/darwin/default.nix
          ./applications/darwin/default.nix
        ] ++ lib.optionals pkgs.stdenv.isLinux [
          ./modules/linux/default.nix
          ./applications/linux/default.nix
          inputs.nix-flatpak.homeManagerModules.nix-flatpak
        ] ++ extraModules;
      };

    lib = nixpkgs.lib;
  in
  {
    # NixOS Configurations
    nixosConfigurations = {
      "nixos-desktop" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Main NixOS system configuration
          ./modules/nixos/default.nix

          # Home Manager integration for NixOS
          home-manager.nixosModules.home-manager
          {
            nixpkgs.config.allowUnfree = true;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Configure Home Manager for a specific user
            home-manager.users.jules = {
              imports = [
                ./modules/common/default.nix
                ./applications/common/default.nix
                ./profiles/workstation.nix
                ./modules/linux/default.nix
                ./applications/linux/default.nix
                inputs.nix-flatpak.homeManagerModules.nix-flatpak
                nixvim.homeManagerModules.nixvim
              ];
            };
            # Pass flake inputs to home-manager modules as well
            home-manager.extraSpecialArgs = { inherit inputs; };
          }

          # Overlay to expose nixgl in system pkgs
          ({ nixpkgs.overlays = [ inputs.nixgl.overlay ]; })
        ];
      };
    };

    # Darwin Configurations (macOS system-level)
    darwinConfigurations."macbook-air" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./configuration.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.jacksonmiller = {
            imports = [
              ./modules/common/default.nix
              ./applications/common/default.nix
              ./profiles/workstation.nix
              ./modules/darwin/default.nix
              ./applications/darwin/default.nix
              nixvim.homeManagerModules.nixvim
            ];
          };
          home-manager.extraSpecialArgs = { inherit inputs; };
          nixpkgs.config.allowUnfree = true;
        }
      ];
    };

    # Home Manager Configurations (user-level, standalone)
    homeConfigurations = {
      # macOS configurations
      "jacksonmiller@mac" = mkHomeConfig {
        system = "aarch64-darwin";
        username = "jacksonmiller";
        profile = "workstation";
      };
      
      "jacksonmiller@mac-minimal" = mkHomeConfig {
        system = "aarch64-darwin";
        username = "jacksonmiller";
        profile = "minimal";
      };

      # Linux configurations
      "jackson@linux" = mkHomeConfig {
        system = "x86_64-linux";
        username = "jackson";
        profile = "workstation";
      };
      
      "jackson@linux-minimal" = mkHomeConfig {
        system = "x86_64-linux";
        username = "jackson";
        profile = "minimal";
      };
      
      "jackson@media" = mkHomeConfig {
        system = "x86_64-linux";
        username = "jackson";
        profile = "media-production";
      };

      # Aliases for convenience
      "jackson" = mkHomeConfig {
        system = "x86_64-linux";
        username = "jackson";
        profile = "workstation";
      };
    };
  };
}