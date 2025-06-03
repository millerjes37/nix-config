{ pkgs, ... }:

{
  imports = [
    ./nixos.nix
    ./home.nix
  ];
}
