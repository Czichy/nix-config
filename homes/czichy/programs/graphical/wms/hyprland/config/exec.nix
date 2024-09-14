{
  osConfig,
  lib,
  ...
}:
with lib; let
  inherit (osConfig) modules;
  inherit (config.home.sessionVariables) BROWSER; # EDITO

  # theming
  inherit (modules.style) pointerCursor;

  sys = modules.system;
  agenixCheck = sys.agenix.home.enable;

  ibkr = {
    user = osConfig.age.secrets."${modules.system.programs.ib-tws.userSecretsPath}".path;
    password = osConfig.age.secrets."${modules.syste.programs.ib-tws.passwordSecretsPath}".path;
  };
in {
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      # Startup
      # "swaybg -i ${wallpaper} --mode fill"
      "${pkgs.swaynotificationcenter}/bin/swaync"
      # "ib-tws-native"
      "[workspace 7] firefox -P 'tradingview1' --class=tradingview"
      "[workspace 6] ${BROWSER}"
      "wl-paste --type text --watch cliphist store #Stores only text data"
      "wl-paste --type image --watch cliphist store #Stores only image data"
      "[workspace special:pass silent] keepassxc"
      "swayosd --max-volume 150"
      "xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 1"
      # set cursor for HL itself
      "hyprctl setcursor ${pointerCursor.name} ${toString pointerCursor.size}"

      (mkIf agenixCheck "ib-tws-native -u $(< ${ibkr.user}) -p $(< ${ibkr.password})")
      (mkIf (!agenixCheck) "ib-tws-native")
    ];
  };
}
