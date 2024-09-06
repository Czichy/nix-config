{
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkEnableOption;
in {
  options.modules.system.agenix = with lib.types; {
    enable = mkEnableOption ''
      Enables NixOS module that sets up & configures the agenix secrets
      backend.

      References
      - https://github.com/ryantm/agenix
      - https://nixos.wiki/wiki/Agenix
    '';
    secretsPath = lib.mkOption {
      type = path;
      default = "${inputs.private}";
      #default = ./secrets;
      description = "Path to the actual secrets directory";
    };

    pubkeys = lib.mkOption {
      type = attrsOf (attrsOf anything);
      default = {};
      description = ''
        The resulting option that will hold the various public keys used around
        the flake.
      '';
    };

    pubkeysFile = lib.mkOption {
      type = path;
      default = ./pubkeys.nix;
      description = ''
        Path to the pubkeys file that will be used to construct the
        `secrets.pubkeys` option.
      '';
    };

    extraPubkeys = lib.mkOption {
      type = attrsOf (attrsOf anything);
      default = {};
      description = ''
        Additional public keys that will be merged into the `secrets.pubkeys`
      '';
    };
  };
}
