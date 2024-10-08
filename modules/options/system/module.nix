{
  config,
  lib,
  ...
}: let
  inherit (builtins) elemAt;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.modules) mkMerge;
  inherit (lib.lists) optionals;
  inherit (lib.types) enum listOf str nullOr bool package;
in {
  imports = [
    # configuration options for nixos activation scripts
    ./activation.nix

    # boot/impermanence mounts
    ./boot.nix
    ./impermanence.nix

    # network and overall hardening
    ./networking
    ./security.nix
    ./encryption.nix

    # filesystems
    ./fs.nix

    # emulation and virtualization
    ./emulation.nix
    ./virtualization.nix

    # package and program related options
    ./services
    ./programs

    # systemd-nspawn containers
    ./containers.nix

    # deterministic user/group ids
    ./deterministic_ids.nix

    # agenix secrets
    ./agenix.nix

    #users definitions
    ./users.nix
  ];
  config = {
    warnings = mkMerge [
      (optionals (config.modules.system.users == []) [
        ''
          You have not added any users to be supported by your system. You may end up with an unbootable system!

          Consider setting {option}`config.modules.system.users` in your configuration
        ''
      ])
    ];
  };

  options.modules.system = {
    yubikeySupport = {
      enable = mkEnableOption "yubikey support";
      deviceType = mkOption {
        type = nullOr (enum ["NFC5" "nano"]);
        default = null;
        description = "A list of device models to enable Yubikey support for";
      };
    };

    sound = {
      enable = mkEnableOption "sound related programs and audio-dependent programs";
    };

    video = {
      enable = mkEnableOption "video drivers and programs that require a graphical user interface";
    };

    bluetooth = {
      enable = mkEnableOption "bluetooth modules, drivers and configuration program(s)";
    };

    # should the device enable printing module and try to load common printer modules
    # you might need to add more drivers to the printing module for your printer to work
    printing = {
      enable = mkEnableOption "printing";
      extraDrivers = mkOption {
        type = listOf str;
        default = [];
        description = "A list of extra drivers to enable for printing";
      };

      "3d" = {
        enable = mkEnableOption "3D printing suite";
        extraPrograms = mkOption {
          type = listOf package;
          default = [];
          description = "A list of extra programs to enable for 3D printing";
        };
      };
    };
  };
}
