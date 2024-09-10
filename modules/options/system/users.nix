{
  config,
  lib,
  ...
}:
with builtins;
with lib; let
  inherit
    (lib)
    mkImpermanenceEnableOption
    mkUsersSettingsOption
    mkAgenixEnableOption
    ;

  _ = mkOverrideAtModuleLevel;
in {
  # TODO move bluetooth dir to hardware
  options.modules.system.users = with types; {
    enable = mkEnableOption ''
      Enables NixOS module that sets up the basis for the userspace, that is
      declarative management, basis for the home directories and also
      configures home-manager, persistence, agenix if they are enabled.
    '';

    impermanence = {
      enable = mkImpermanenceEnableOption;
    };

    agenix = {
      enable = mkAgenixEnableOption;
    };

    usersSettings = mkUsersSettingsOption (_user: {
      isSudoer = mkOption {
        type = bool;
        default = true;
        description = ''
          Add user to sudoers (ie the `wheel` group)
        '';
      };

      isNixTrusted = mkOption {
        type = bool;
        default = false;
        description = ''
          Whether the user has the ability to connect to the nix daemon
          and gain additional privileges for working with nix (like adding
          binary cache)
        '';
      };

      uid = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = "The uid to assign if it is missing in `users.users.<name>`.";
      };
      gid = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = "The gid to assign if it is missing in `users.groups.<name>`.";
      };

      extraGroups = mkOption {
        type = listOf str;
        default = [];
        description = ''
          Any additional groups which the user should be a part of. This is
          basically just a passthrough for `users.users.<user>.extraGroups`
          for convenience.
        '';
      };

      agenixPassword = {
        enable = mkEnableOption ''
          TODO
        '';

        passwordSecretsPath = mkOption {
          type = str;
          default = "hosts/${config.networking.hostName}/users/${_user}/system-password";
          description = ''
            TODO
          '';
        };
      };

      authorizedKeys = {
        enable =
          mkEnableOption ''
            TODO
          ''
          // {
            default = true;
          };

        keysRaw = mkOption {
          type = listOf str;
          default = [];
          description = ''
            TODO
          '';
        };

        keysSecretsAttrsetKey = mkOption {
          type = str;
          default = "hosts.${config.networking.hostName}.users.${_user}.authorizedKeys";
          description = ''
            TODO
          '';
        };
      };
    });
  };
}
