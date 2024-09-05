# --- parts/secrets/default.nix
#
# Author:  czichy <christian@czichy.com>
# URL:     https://github.com/czichy/tensorfiles
# License: MIT
#
# 888                                                .d888 d8b 888
# 888                                               d88P"  Y8P 888
# 888                                               888        888
# 888888 .d88b.  88888b.  .d8888b   .d88b.  888d888 888888 888 888  .d88b.  .d8888b
# 888   d8P  Y8b 888 "88b 88K      d88""88b 888P"   888    888 888 d8P  Y8b 88K
# 888   88888888 888  888 "Y8888b. 888  888 888     888    888 888 88888888 "Y8888b.
# Y88b. Y8b.     888  888      X88 Y88..88P 888     888    888 888 Y8b.          X88
#  "Y888 "Y8888  888  888  88888P'  "Y88P"  888     888    888 888  "Y8888   88888P'
{
  config,
  lib,
  self,
  inputs,
  ...
}: let
  localFlake = self;
in {
  flake = {
    # config,
    # lib,
    pkgs,
    system,
    ...
  }: {
    globals = let
      globalsSystem = lib.evalModules {
        prefix = ["globals"];
        specialArgs = {
          inherit lib;
          # inherit (inputs.self.pkgs.x86_64-linux) lib;
          inherit config;
        };
        modules = [
          ./globals.nix
          ../globals.nix
          # ({
          #   lib,
          #   config,
          #   ...
          # }: {
          #   globals = lib.mkMerge (
          #     lib.concatLists (lib.flip lib.mapAttrsToList config.nodes (
          #       name: cfg:
          #         builtins.addErrorContext "while aggregating globals from nixosConfigurations.${name} into flake-level globals:"
          #         cfg.config._globalsDefs
          #     ))
          #   );
          # })
        ];
      };
    in {
      # Make sure the keys of this attrset are trivially evaluatable to avoid infinite recursion,
      # therefore we inherit relevant attributes from the config.
      inherit (globalsSystem.config.globals) net services monitoring;
    };
  };
}
