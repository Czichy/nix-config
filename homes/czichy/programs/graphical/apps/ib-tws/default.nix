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

  passwordSecretsPath = "hosts/${osConfig.meta.hostname}/users/${config.home.username}/ibkr/password";

  userSecretsPath = "hosts/${osConfig.meta.hostname}/users/${config.home.username}/ibkr/user";

  _ = mkOverrideAtHmModuleLevel;

  impermanenceCheck = sys.impermanence.home.enable;
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
          "${userSecretsPath}" = {
            # symlink = true;
            file = _ (secretsPath + "/${userSecretsPath}.age");
            mode = _ "0600";
          };
          "${passwordSecretsPath}" = {
            # symlink = true;
            file = _ (secretsPath + "/${passwordSecretsPath}.age");
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
