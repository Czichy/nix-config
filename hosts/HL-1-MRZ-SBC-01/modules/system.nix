{pkgs, ...}: {
  config.modules.system = {
    # mainUser = "czichy";
    fs.enabledFilesystems = ["btrfs" "vfat" "exfat" "ext4"];
    impermanence = {
      root.enable = true;
      home = {
        enable = true;
        allowOther = true;
      };
    };

    boot = {
      loader = "systemd-boot";
      secureBoot = false;
      enableKernelTweaks = true;
      initrd.enableTweaks = true;
      loadRecommendedModules = true;
      tmpOnTmpfs = false;
      plymouth = {
        enable = true;
        withThemes = false;
      };
    };

    video.enable = false;
    sound.enable = false;
    bluetooth.enable = false;
    printing.enable = false;

    virtualization = {
      enable = true;
      qemu.enable = true;
    };

    networking = {
      optimizeTcp = false;
      tarpit.enable = true;
      nftables.enable = true;
      tailscale = {
        enable = false;
        isServer = true;
        isClient = false;
      };
    };
    agenix.enable = true;

    programs = {
      git.signingKey = "";

      cli.enable = true;
      gui.enable = false;
    };
  };
}
