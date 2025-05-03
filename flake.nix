{
  description = "MacBook Air Configuration";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    darwin.url = "github:LnL7/nix-darwin";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = { self, nixpkgs-unstable, home-manager, darwin, nix-homebrew, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs-unstable.legacyPackages.${system};
    in
    {
      # Darwin configuration
      darwinConfigurations."macbook-air" = darwin.lib.darwinSystem {
        inherit system;
        modules = [
          ./configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jacksonmiller = import ./home.nix;
          }
          nix-homebrew.darwinModules.nix-homebrew
        ];
      };
      
      # Standalone home-manager configuration
      homeConfigurations = {
        "jacksonmiller" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
        };
      };
    };
}
