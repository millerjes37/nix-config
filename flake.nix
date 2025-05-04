{
  description = "Cross-Platform Configuration for macOS and Linux";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-homebrew.inputs.nixpkgs.follows = "nixpkgs";
  };

  # In flake.nix
outputs = { self, nixpkgs, home-manager, darwin, nix-homebrew, nixvim, ... }:
  let
    mkHomeConfig = { system, username, extraImports ? [] }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        # Pass extraImports via specialArgs
        specialArgs = { inherit extraImports; }; # <-- Add this line
        modules = [
          ./home.nix
          nixvim.homeManagerModules.nixvim
          { # This module now only sets basic home.* attributes
            home.username = username;
            home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
            # Remove _module.args from here:
            # _module.args.extraImports = extraImports; # <-- Remove this line
          }
        ];
      };

    # mkDarwinConfig might need similar adjustments if passing special args there too
    mkDarwinConfig = { system, username }:
      darwin.lib.darwinSystem {
        inherit system;
        # If home.nix used within darwin needs special args, pass them here too
        # specialArgs = { /* ... */ };
        modules = [
          ./configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Check if importing home.nix directly here works as expected
            # or if you should reuse mkHomeConfig's result.
            # For consistency, often better to configure HM separately.
            home-manager.users.${username} = import ./home.nix;
            # If home.nix needs specialArgs when used here, this direct import won't work.
            # You might need to structure it differently, perhaps importing the result
            # of a home-manager configuration.
          }
          nix-homebrew.darwinModules.nix-homebrew
        ];
      };
  in
  {
    # Darwin configuration for macOS
    darwinConfigurations."macbook-air" = mkDarwinConfig {
      system = "aarch64-darwin";
      username = "jacksonmiller";
    };

    # Standalone home-manager configurations for both platforms
    homeConfigurations = {
      "jacksonmiller@mac" = mkHomeConfig {
        system = "aarch64-darwin";
        username = "jacksonmiller";
        extraImports = [
          ./modules/yabai.nix
          ./modules/skhd.nix
        ];
      };
      "jacksonmiller@linux" = mkHomeConfig {
        system = "x86_64-linux";
        username = "jacksonmiller";
        extraImports = []; # No extra imports needed for Linux
      };
    };
  };