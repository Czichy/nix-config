{
  osConfig,
  config,
  lib,
  ...
}:
with builtins;
with lib; let
  inherit (osConfig) modules;
  sys = modules.system;

  impermanenceCheck = sys.impermanence.home.enable;
  impermanence =
    if impermanenceCheck
    then sys.impermanence
    else {};
  pathToRelative = strings.removePrefix "${config.home.homeDirectory}/";
in {
  config = mkMerge [
    # |----------------------------------------------------------------------| #
    {
      home.sessionVariables = {
        # Default programs
        EDITOR = "hx";
        VISUAL = "hx";
        # Directory structure
        DOWNLOADS_DIR = config.home.homeDirectory + "/Downloads";
        ORG_DIR = config.home.homeDirectory + "/OrgBundle";
        PROJECTS_DIR = config.home.homeDirectory + "/projects";
        TRADING_DIR = config.home.homeDirectory + "/Trading";
        DOCUMENTS_DIR = config.home.homeDirectory + "/Dokumente";
        SECRETS_DIR = config.home.homeDirectory + "/.credentials";
      };
    }
    # |----------------------------------------------------------------------| #
    (mkIf impermanenceCheck {
      home.persistence."${impermanence.persistentRoot}${config.home.homeDirectory}" = {
        directories = [
          ".ssh"
          (pathToRelative config.home.sessionVariables.PROJECTS_DIR)
          (pathToRelative config.home.sessionVariables.TRADING_DIR)
          (pathToRelative config.home.sessionVariables.DOCUMENTS_DIR)
          (pathToRelative config.home.sessionVariables.SECRETS_DIR)
        ];
      };
    })
    # |----------------------------------------------------------------------| #
  ];
}
