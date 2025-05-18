# File: ~/nix-config/modules/common/zen-browser.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.zenBrowser;

  # Access specialArgs passed to Home Manager.
  # Your flake.nix should be set up to pass 'inputs' and 'system'
  # via home-manager.extraSpecialArgs.
  flakeInputs = config._module.args.inputs;
  currentSystem = config._module.args.system; # This is the 'system' (e.g., "x86_64-linux") passed in extraSpecialArgs

in
{
  options.programs.zenBrowser = {
    enable = mkEnableOption (mdDoc "Zen Browser");

    package = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = mdDoc ''
        The specific Zen Browser package to install.

        If set to `null` (the default), the module will attempt to construct the package
        path using `inputs.zen-browser.packages."<system>".<channel>`.
        For this to work:
        1.  `inputs` (containing your `zen-browser` flake input) must be passed
            to Home Manager via `extraSpecialArgs` in your `flake.nix`.
        2.  The `system` variable must also be passed via `extraSpecialArgs`.
        3.  The Zen browser flake input must follow the structure
            `packages.<system>.<channel>`.

        Example of explicit setting: `inputs.zen-browser.packages."''${config._module.args.system}".specific`
      '';
    };

    channel = mkOption {
      type = types.enum [ "specific" "default" "beta" "twilight" "twilight-official" ];
      default = "specific";
      description = mdDoc ''
        Which Zen Browser channel/variant to use from the flake.
        This is only used if `programs.zenBrowser.package` is not explicitly set.
      '';
    };
  };

  config = mkIf cfg.enable (
    let
      resolvedPackage =
        if cfg.package != null then
          cfg.package
        else if flakeInputs == null then
          throw "programs.zenBrowser: 'inputs' is not available via Home Manager's specialArgs. Please pass 'inputs' to home-manager.extraSpecialArgs in your flake.nix or explicitly set programs.zenBrowser.package."
        else if flakeInputs.zen-browser == null then
          throw "programs.zenBrowser: 'inputs.zen-browser' is not defined. Ensure 'zen-browser' is an input in your flake.nix and passed via specialArgs."
        else if currentSystem == null then
          throw "programs.zenBrowser: 'system' is not available via Home Manager's specialArgs. Please pass 'system' to home-manager.extraSpecialArgs in your flake.nix or explicitly set programs.zenBrowser.package."
        else
          let
            packagePath = flakeInputs.zen-browser.packages."${currentSystem}"."${cfg.channel}";
          in
          if packagePath == null then
            throw ''
              programs.zenBrowser: Default package could not be found at path:
              inputs.zen-browser.packages."${currentSystem}".${cfg.channel}
              Please check:
              1. The 'system' value ('${currentSystem}') is correct.
              2. The 'channel' value ('${cfg.channel}') is correct and available for your system.
              3. Your 'zen-browser' flake input provides this package.
              Alternatively, explicitly set programs.zenBrowser.package.
            ''
          else
            packagePath;
    in
    {
      home.packages = [ resolvedPackage ];
    }
  );
}