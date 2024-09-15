{
  pkgs,
  lib,
  ...
}: {
  config.modules.system = {
    fs.enabledFilesystems = ["btrfs" "vfat" "ntfs" "exfat"];

    agenix = {
      root.enable = true;
      home.enable = true;
    };

    impermanence = {
      root.enable = true;
      home.enable = true;
    };

    boot = {
      loader = "systemd-boot";
      secureBoot = false;
      enableKernelTweaks = true;
      initrd.enableTweaks = true;
      loadRecommendedModules = true;
      tmpOnTmpfs = false;
      plymouth = {
        enable = false;
        withThemes = false;
      };
    };

    users.enable = true;
    # containers = {
    # enabledContainers = ["alpha"];
    # };

    # yubikeySupport.enable = true;

    video.enable = true;
    sound.enable = true;
    # bluetooth.enable = false;
    printing.enable = false;
    emulation.enable = true;

    virtualization = {
      enable = true;
      qemu.enable = true;
      docker.enable = true;
    };

    networking = {
      optimizeTcp = true;
      nftables.enable = true;
      tailscale = {
        enable = false;
        isClient = true;
        isServer = false;
      };
    };

    security = {
      # tor.enable = true;
      # fixWebcam = false;
      lockModules = true;
      auditd.enable = true;
    };
    services = {
      flatpak = {
        enable = true;
      };
      syncthing = {
        enable = true;
        user = "czichy";
      };
    };

    programs = {
      cli.enable = true;
      gui.enable = true;

      ib-tws.enable = true;
      # spotify.enable = true;

      # git.signingKey = "0xAF26552424E53993 ";

      gaming.enable = true;

      default = {
        terminal = "foot";
      };

      shells = {
        nushell = {
          enable = true;
        };
      };

      libreoffice.enable = lib.mkForce false;
    };

    # Minecraft
    programs.gaming.minecraft.enable = true;
    services.flatpak.packages = [
      "io.mrarm.mcpelauncher"
    ];
  };
}
