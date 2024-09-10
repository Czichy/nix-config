{
  config,
  pkgs,
  lib,
  ...
}:
with builtins;
with lib; let
  inherit
    (lib)
    isModuleLoadedAndEnabled
    ;
  sys = modules.system;

  impermanenceCheck =
    (isModuleLoadedAndEnabled osConfig "modules.system.impermanence") && sys.impermanence.home.enable;
  impermanence =
    if impermanenceCheck
    then sys.impermanence
    else {};

  browser = ["firefox.desktop"];
  mailer = ["thunderbird.desktop"];
  zathura = ["zathura.desktop"];
  fileManager = ["org.kde.dolphin.desktop"];

  associations = {
    "text/html" = browser;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    "x-scheme-handler/ftp" = browser;
    "x-scheme-handler/about" = browser;
    "x-scheme-handler/unknown" = browser;
    "application/xhtml+xml" = browser;
    "application/x-extension-htm" = browser;
    "application/x-extension-html" = browser;
    "application/x-extension-shtml" = browser;
    "application/x-extension-xhtml" = browser;
    "application/x-extension-xht" = browser;

    "inode/directory" = fileManager;
    "application/x-xz-compressed-tar" = ["org.kde.ark.desktop"];

    "audio/*" = ["mpv.desktop"];
    "video/*" = ["mpv.desktop"];
    "image/*" = ["imv.desktop"];
    "application/json" = browser;
    "application/pdf" = zathura;

    "x-scheme-handler/tg" = ["telegramdesktop.desktop"];
    "x-scheme-handler/spotify" = ["spotify.desktop"];
    "x-scheme-handler/discord" = ["WebCord.desktop"];
    "x-scheme-handler/mailto" = mailer;
  };

  template = import lib.xdgTemplate "home-manager";
in {
  #home.sessionVariables = template.sysEnv;
  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";

    configFile = {
      "npm/npmrc" = template.npmrc;
      "python/pythonrc" = template.pythonrc;
    };

    userDirs = {
      enable = pkgs.stdenv.isLinux;
      createDirectories = true;

      download = "${config.home.homeDirectory}/Downloads";
      desktop = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Dokumente";

      publicShare = null;
      templates = null;

      music = "${config.home.homeDirectory}/Media/Musik";
      pictures = "${config.home.homeDirectory}/Media/Bilder";
      videos = "${config.home.homeDirectory}/Media/Videos";

      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/Screenshots";
        XDG_MAIL_DIR = "${config.home.homeDirectory}/Mail";
      };
    };

    mimeApps = {
      enable = true;
      associations.added = associations;
      defaultApplications = associations;
    };
  };
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

      # home.file = {
      #"${config.xdg.configHome}/.blank".text = mkBefore "";
      #"${config.xdg.cacheHome}/.blank".text = mkBefore "";
      #"${config.xdg.dataHome}/.blank".text = mkBefore "";
      #"${config.xdg.stateHome}/.blank".text = mkBefore "";
      #"${config.home.sessionVariables.DOWNLOADS_DIR}/.blank".text = mkIf (
      #  config.home.sessionVariables.DOWNLOADS_DIR != null
      #) (mkBefore "");
      #"${config.home.sessionVariables.ORG_DIR}/.blank".text = mkIf (
      #  config.home.sessionVariables.ORG_DIR != null
      #) (mkBefore "");
      #"${config.home.sessionVariables.PROJECTS_DIR}/.blank".text = mkIf (
      #  config.home.sessionVariables.PROJECTS_DIR != null
      #) (mkBefore "");
      #"${config.home.sessionVariables.TRADING_DIR}/.blank".text = mkIf (
      #  config.home.sessionVariables.TRADING_DIR != null
      #) (mkBefore "");
      # };
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
