{
  osConfig,
  config,
  lib,
  system,
  inputs,
  ...
}:
with builtins;
with lib; let
  inherit (osConfig) modules;
  inherit
    (lib)
    mkOverrideAtHmModuleLevel
    isModuleLoadedAndEnabled
    ;

  sys = modules.system;
  prg = sys.programs;
  cfg = prg.ib-tws;

  _ = mkOverrideAtHmModuleLevel;

  impermanenceCheck =
    (isModuleLoadedAndEnabled osConfig "modules.system.impermanence") && sys.impermanence.home.enable;
  impermanence =
    if impermanenceCheck
    then sys.impermanence
    else {};

  agenixCheck =
    (isModuleLoadedAndEnabled config "security.agenix") && cfg.agenix.enable;
in {
  config = mkIf cfg.enable (mkMerge [
    # |----------------------------------------------------------------------| #
    {
      home.packages = [
        inputs.self.packages.${system}.ib-tws-native
        inputs.self.packages.${system}.ib-tws-native-latest
      ];
    }
    # |----------------------------------------------------------------------| #
    (
      mkIf agenixCheck
      {
        age.secrets = {
          "${cfg.userSecretsPath}" = {
            # symlink = true;
            file = _ (secretsPath + "/${cfg.userSecretsPath}.age");
            mode = _ "0600";
          };
          "${cfg.passwordSecretsPath}" = {
            # symlink = true;
            file = _ (secretsPath + "/${cfg.passwordSecretsPath}.age");
            mode = _ "0600";
          };
        };
      }
    )
    # |----------------------------------------------------------------------| #
    (mkIf impermanenceCheck {
      home.persistence."${impermanence.persistentRoot}${config.home.homeDirectory}" = {
        allowOther = true;
        directories = [
          ".ib-tws-native"
          ".ib-tws-native_latest"
        ];
      };
    })
    # |----------------------------------------------------------------------| #
  ]);
}
