{
  osConfig,
  lib,
  inputs,
  ...
}:
with lib; let
  inherit (lib.modules) mkMerge;
  inherit (lib.modules) mkIf;
  inherit (osConfig) modules;
  cfg = modules.system.impermanence;
in {
  imports = with inputs; [impermanence.nixosModules.home-manager.impermanence];
  config = mkIf cfg.home.enable (mkMerge [
    # |----------------------------------------------------------------------| #
    {
      assertions = [
        {
          assertion = hasAttr "impermanence" inputs;
          message = "Impermanence flake missing in the inputs library. Please add it to your flake inputs.";
        }
      ];
    }
    # |----------------------------------------------------------------------| #
    {
      home.persistence."${cfg.persistentRoot}" = {
        inherit (cfg.home) allowOther;
      };
    }
    # |----------------------------------------------------------------------| #
  ]);
}
