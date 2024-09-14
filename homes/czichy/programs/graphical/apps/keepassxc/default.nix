{
  osConfig,
  config,
  lib,
  pkgs,
  ...
}:
with builtins;
with lib; let
  inherit (osConfig) modules;

  sys = modules.system;
  prg = sys.programs;
  cfg = prg.keepassxc;

  # _ = mkOverrideAtHmModuleLevel;
  impermanenceCheck = sys.impermanence.home.enable;

  impermanence =
    if impermanenceCheck
    then sys.impermanence
    else {};
in {
  config = mkIf cfg.enable (mkMerge [
    # |----------------------------------------------------------------------| #
    {
      home.packages = [pkgs.keepassxc];

      # systemd.user.services.keepassxc = {
      #   Unit = {
      #     Description = _ "KeePassXC password manager";
      #     After = [ "graphical-session-pre.target" ];
      #     PartOf = [ "graphical-session.target" ];
      #   };

      #   Install = {
      #     WantedBy = [ "graphical-session.target" ];
      #   };
      #   # TODO pkgs.keepassxc doesnt have a mainProgram for getExe set
      #   Service = {
      #     ExecStart = _ "${cfg.pkg}/bin/keepassxc";
      #   };
      # };
    }
    # |----------------------------------------------------------------------| #
    (mkIf impermanenceCheck {
      home.persistence."${impermanence.persistentRoot}${config.home.homeDirectory}" = {
        allowOther = true;
        directories = [
          ".cache/keepassxc"
          ".config/keepassxc"
        ];
        files = [".mozilla/native-messaging-hosts/org.keepassxc.keepassxc_browser.json"];
      };
    })
    # |----------------------------------------------------------------------| #
  ]);
}
