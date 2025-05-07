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

  outputs = { self, nixpkgs, home-manager, darwin, nix-homebrew, nixvim, ... }:
  let
    mkHomeConfig = { system, username, extraImports ? [] }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
        extraSpecialArgs = { inherit extraImports; };
        modules = [
          ./home.nix
          nixvim.homeManagerModules.nixvim
          ({ pkgs, ... }: {
            home.username = username;
            home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
          })
        ];
      };

    mkDarwinConfig = { system, username }:
      darwin.lib.darwinSystem {
        inherit system;
        modules = [
          ./configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = import ./home.nix;
          }
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
          ./modules/darwin/default.nix # Main macOS configuration
        ];
      };
      
      "jackson@linux" = mkHomeConfig {
        system = "x86_64-linux";
        username = "jackson";
        extraImports = [
          ./modules/linux/default.nix  # Main Linux configuration
        ];
      };
    };
  };
}