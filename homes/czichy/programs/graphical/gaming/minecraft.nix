{
  osConfig,
  config,
  lib,
  ...
}:
with lib; let
  inherit (lib.modules) mkIf;
  inherit (osConfig) modules;

  sys = modules.system;
  env = modules.usrEnv;
  prg = env.programs;

  impermanenceCheck = sys.impermanence.home.enable;
  impermanence =
    if impermanenceCheck
    then sys.impermanence
    else {};
in {
  config = mkIf prg.gaming.minecraft.enable (mkMerge [
    # |----------------------------------------------------------------------| #
    (mkIf impermanenceCheck {
      home.persistence."${impermanence.persistentRoot}${config.home.homeDirectory}" = {
        allowOther = true;
        directories = [
          # Minecraft Bedrock Launcher
          # https://mcpelauncher.readthedocs.io/en/latest/index.html
          ".config/Minecraft Linux Launcher"
          ".var/app/io.mrarm.mcpelauncher"
          ".local/share/mcpelauncher-webview"
          ".local/share/Minecraft Linux Launcher"
        ];
      };
    })
    # |----------------------------------------------------------------------| #
  ]);
}
