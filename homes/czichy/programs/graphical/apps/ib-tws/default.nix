{
  self',
  osConfig,
  config,
  lib,
  ...
}:
with builtins;
with lib; let
  inherit (osConfig) modules;
  inherit
    (lib)
    mkOverrideAtHmModuleLevel
    ;

  sys = modules.system;
  prg = sys.programs;
  cfg = prg.ib-tws;

  passwordSecretsPath = "ibkr/password";

  userSecretsPath = "ibkr/user";

  _ = mkOverrideAtHmModuleLevel;

  impermanenceCheck = sys.impermanence.home.enable;
  impermanence =
    if impermanenceCheck
    then sys.impermanence
    else {};

  agenixCheck = cfg.agenix.enable;
in {
  config = mkIf cfg.enable (mkMerge [
    # |----------------------------------------------------------------------| #
    {
      home.packages = [
        self'.packages.ibtws
        self'.packages.ibtws_latest
        # pkgs.ib-tws-native-latest
      ];
    }
    # |----------------------------------------------------------------------| #
    (
      mkIf agenixCheck
      {
        age.secrets = {
          "${userSecretsPath}" = {
            # symlink = true;
            file = _ (sys.agenix.home.secretsPath + "/${userSecretsPath}.age");
            mode = _ "0600";
          };
          "${passwordSecretsPath}" = {
            # symlink = true;
            file = _ (sys.agenix.home.secretsPath + "/${passwordSecretsPath}.age");
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
